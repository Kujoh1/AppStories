import argparse
import json
import os
import re
import time
import unicodedata
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import requests
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ASSETS_JSON = ROOT / "assets" / "stories" / "ink" / "Story_01_assets.json"
DEFAULT_STORY_MD = ROOT / "assets" / "stories" / "ink" / "Story_01.md"
STYLE_TXT = ROOT / "tools" / "replicate_style.txt"
SECRETS_JSON = ROOT / "secrets" / "replicate.local.json"

# User requirement:
TARGET_W = 1400
TARGET_H = 700
ASPECT_RATIO = "2:1"

# Replicate model slug.
# Verified via GET https://api.replicate.com/v1/models/black-forest-labs/flux-1.1-pro
DEFAULT_MODEL = "black-forest-labs/flux-1.1-pro"

# Replicate REST API
REPLICATE_API = "https://api.replicate.com/v1"

# Fallback style if tools/replicate_style.txt is empty.
# (User can override by pasting their exact style block into tools/replicate_style.txt)
DEFAULT_STYLE = (
    "Sin City graphic novel illustration style, strictly monochrome black-and-white grayscale, inked comic panel, ultra high contrast chiaroscuro, "
    "deep crushed blacks, sharp rim light, thick ink outlines, cross-hatching and halftone texture, gritty film grain, "
    "noir atmosphere, cinematic framing, selective red accent only (very minimal), dramatic shadows"
)


@dataclass(frozen=True)
class AssetTask:
    kind: str  # "BG" or "IMG"
    key: str
    out_path: Path
    prompt: str
    negative_prompt: str
    context: str


TAG_RE = re.compile(r"^#(BG|IMG)\s*:\s*([A-Za-z0-9_]+)\s*$")


def load_style() -> str:
    if not STYLE_TXT.exists():
        return DEFAULT_STYLE
    text = STYLE_TXT.read_text(encoding="utf-8").strip()
    # Strip comment lines
    lines = [ln for ln in text.splitlines() if ln.strip() and not ln.strip().startswith("#")]
    style = "\n".join(lines).strip()
    return style or DEFAULT_STYLE


def load_token() -> str:
    # Prefer env var
    env = os.getenv("REPLICATE_API_TOKEN")
    if env:
        return env.strip()
    if SECRETS_JSON.exists():
        data = json.loads(SECRETS_JSON.read_text(encoding="utf-8"))
        tok = (data.get("REPLICATE_API_TOKEN") or "").strip()
        if tok:
            return tok
    raise RuntimeError(
        "Missing Replicate token. Set REPLICATE_API_TOKEN or put it in secrets/replicate.local.json"
    )


def load_assets_map() -> Dict[str, Dict[str, str]]:
    raise RuntimeError("load_assets_map requires an explicit assets_json_path (use load_assets_map_from).")


def load_assets_map_from(assets_json_path: Path) -> Dict[str, Dict[str, str]]:
    data = json.loads(assets_json_path.read_text(encoding="utf-8"))
    return {"BG": dict(data.get("BG", {})), "IMG": dict(data.get("IMG", {}))}


def read_story_lines_from(story_path: Path) -> List[str]:
    return story_path.read_text(encoding="utf-8").splitlines()


def extract_context_for_key(lines: List[str], kind: str, key: str) -> str:
    """
    Extract a compact context block starting at the tag line (#BG/#IMG:KEY)
    up to the next knot / next major section. Designed for prompting.
    """
    needle = f"#{kind}:{key}"
    start = None
    for i, ln in enumerate(lines):
        if ln.strip() == needle:
            start = i
            break
    if start is None:
        return ""

    # Collect lines after tags, stop at next knot/section marker.
    buf: List[str] = []
    for j in range(start + 1, min(len(lines), start + 80)):
        t = lines[j].strip()
        if not t:
            # allow a little spacing but don't accumulate too much empty
            if buf and buf[-1] == "":
                continue
            buf.append("")
            continue
        if t.startswith("===") or t.startswith("->") or t.startswith("//"):
            break
        if t.startswith("#BG:") or t.startswith("#IMG:") or t.startswith("#MOOD:") or t.startswith("#SFX:"):
            continue
        if t.startswith("~"):
            # ink variable operations
            continue
        if t.startswith("* ["):
            # choices start: stop, the scene text is above
            break
        # remove inline ink formatting a bit
        t = re.sub(r"\*{1,2}([^*]+)\*{1,2}", r"\1", t)
        # remove explicit quoted text to avoid models rendering lettering
        t = re.sub(r"„[^“]{1,120}“", "…", t)
        t = re.sub(r"\"[^\"]{1,120}\"", "…", t)
        buf.append(t)

    # Compact
    text = " ".join([b for b in buf if b]).strip()
    text = re.sub(r"\s+", " ", text)
    return text


def build_prompt(style: str, kind: str, key: str, context: str) -> Tuple[str, str]:
    """
    Create a scene-fitting prompt. 'style' is appended to keep it consistent.
    """
    # A small, deterministic per-key hint (helps when context is short).
    key_hint = key.replace("_", " ")

    # Extra hinting for IMG keys so the model produces a meaningful prop shot.
    img_hint = ""
    if kind == "IMG":
        k = key.lower()
        if "phone" in k or "dial" in k or "0217" in k:
            img_hint = "close-up of a smartphone / phone screen glow in darkness, wet reflections, noir lighting"
        elif "chain" in k or "door" in k:
            img_hint = "close-up of a door chain latch on an apartment door, tense framing, shallow depth of field"
        elif "ear" in k:
            img_hint = "close-up silhouette: ear pressed to a wall, texture of plaster, subtle vibration tension"
        elif "cracks" in k or "wall" in k:
            img_hint = "close-up of cracked plaster wall, hairline fractures, ominous shadow"
        elif "shadow" in k:
            img_hint = "abstract shadow line across a wall/floor, dramatic diagonal composition"
        elif "endless_hall" in k or "hall" in k:
            img_hint = "long corridor perspective, repeating doors, oppressive symmetry"
        elif "stairs" in k:
            img_hint = "stairwell spiraling down, repeating steps, unsettling loop"
        elif "key" in k:
            img_hint = "key on palm or on dusty floor, metallic glint, macro shot"
        elif "floor_sit" in k or "sitting" in k:
            # This one frequently triggers false-positive safety filters if we imply a person.
            img_hint = "empty apartment floor scene, discarded coat/blanket on the ground, chair legs nearby, oppressive stillness (no humans, no body parts)"
        elif "notebook" in k or "note" in k:
            img_hint = "open notebook with scribbles but NOT readable, pen nearby, paper texture, noir desk light"
        elif "mirrorfracture" in k or "mirror" in k:
            img_hint = "mirror surface with cracks / fractured reflection without showing a face"
        elif "sink" in k or "hands" in k:
            img_hint = "bathroom sink with water droplets, hands implied by gloves/sleeves only (no skin), stark light"
        elif "bed" in k:
            img_hint = "bed in darkness, rumpled sheets, heavy shadow, ominous quiet"
        elif "window" in k or "rain" in k:
            img_hint = "rainy window close-up, droplets streaking, city blur beyond, cold glow"
        elif "breathing" in k:
            img_hint = "wall surface subtly bulging / breathing illusion, eerie organic texture"
    base = []

    if kind == "BG":
        base.append(
            "wide cinematic establishing shot, environment only, empty environment, no people, no characters, no faces, no readable text"
        )
    else:
        # For overlay images, a character silhouette can be useful (fully clothed), but avoid explicit skin/nudity.
        base.append(
            "wide cinematic close-up prop/scene detail, strictly monochrome black-and-white, may include a fully clothed character silhouette, no explicit nudity, no sexual content, no readable text"
        )

    if context:
        base.append(
            f"Scene description: {context}. Important: do not render any readable text or letters; if the scene involves a note/book/clock display, show it without legible characters."
        )
    else:
        base.append(f"Scene description: {key_hint}")

    if img_hint:
        base.append(f"Visual subject hint: {img_hint}")

    # Strong consistency constraints
    base.append(f"aspect ratio {ASPECT_RATIO}, composition designed for 2:1")

    if style:
        base.append(f"Style: {style}")

    prompt = ". ".join(base).strip()

    negative = (
        "nudity, nude, nsfw, erotic, lingerie, cleavage, nipples, sex, sexual content, porn, fetish, "
        "child, underage, "
        "text, captions, subtitles, watermark, logo, signature, UI, buttons, extra frames, collage, "
        "photo, photographic, photorealistic, DSLR, lens bokeh, ultra-realistic skin pores, "
        "color, colours, colored, colourful, neon, vibrant, saturated, cyan, blue, green, orange, purple, "
        "low quality, blurry, jpeg artifacts, oversaturated, "
        "anime, 3d render"
    )
    return prompt, negative


def _to_ascii_safe(s: str) -> str:
    """
    Flux sometimes behaves oddly with smart quotes / umlauts depending on upstream handling.
    Convert to a conservative ASCII-ish string.
    """
    replacements = {
        "ä": "ae",
        "ö": "oe",
        "ü": "ue",
        "Ä": "Ae",
        "Ö": "Oe",
        "Ü": "Ue",
        "ß": "ss",
        "—": "-",
        "–": "-",
        "„": "\"",
        "“": "\"",
        "’": "'",
        "…": "...",
    }
    for k, v in replacements.items():
        s = s.replace(k, v)
    s = unicodedata.normalize("NFKD", s)
    s = "".join(ch for ch in s if ord(ch) < 128)
    s = re.sub(r"\s+", " ", s).strip()
    return s


def build_tasks(style: str, kinds: List[str], assets_json_path: Path, story_path: Path) -> List[AssetTask]:
    mapping = load_assets_map_from(assets_json_path)
    lines = read_story_lines_from(story_path)

    tasks: List[AssetTask] = []
    for kind in ("BG", "IMG"):
        if kind not in kinds:
            continue
        for key, rel_path in mapping[kind].items():
            out_path = ROOT / rel_path
            ctx = extract_context_for_key(lines, kind, key)
            prompt, negative = build_prompt(style, kind, key, ctx)
            tasks.append(
                AssetTask(
                    kind=kind,
                    key=key,
                    out_path=out_path,
                    prompt=prompt,
                    negative_prompt=negative,
                    context=ctx,
                )
            )
    return tasks


def replicate_create_prediction(token: str, model: str, payload_input: Dict[str, Any]) -> Dict[str, Any]:
    """
    Use the model-specific predictions endpoint to avoid hardcoding a version.
    POST /v1/models/{owner}/{name}/predictions
    """
    if "/" not in model:
        raise ValueError("Model must be like 'owner/name'")
    owner, name = model.split("/", 1)
    url = f"{REPLICATE_API}/models/{owner}/{name}/predictions"
    headers = {"Authorization": f"Token {token}", "Content-Type": "application/json"}
    r = requests.post(url, headers=headers, json={"input": payload_input}, timeout=120)
    if r.status_code >= 400:
        raise RuntimeError(f"Replicate error {r.status_code}: {r.text}")
    return r.json()


def replicate_poll(token: str, prediction: Dict[str, Any], poll_s: float = 1.5, timeout_s: int = 600) -> Dict[str, Any]:
    headers = {"Authorization": f"Token {token}"}
    get_url = prediction.get("urls", {}).get("get")
    if not get_url:
        raise RuntimeError("Prediction response missing urls.get")
    start = time.time()
    while True:
        r = requests.get(get_url, headers=headers, timeout=120)
        if r.status_code >= 400:
            raise RuntimeError(f"Replicate poll error {r.status_code}: {r.text}")
        data = r.json()
        status = data.get("status")
        if status in ("succeeded", "failed", "canceled"):
            return data
        if time.time() - start > timeout_s:
            raise TimeoutError(f"Timed out after {timeout_s}s polling prediction")
        time.sleep(poll_s)


def download_first_output(urls: Any, out_file: Path) -> Path:
    """
    Flux models often return a list of URLs or a single URL.
    """
    if isinstance(urls, list):
        if not urls:
            raise RuntimeError("No outputs returned")
        url = urls[0]
    elif isinstance(urls, str):
        url = urls
    else:
        raise RuntimeError(f"Unexpected output type: {type(urls)}")

    out_file.parent.mkdir(parents=True, exist_ok=True)
    r = requests.get(url, stream=True, timeout=300)
    r.raise_for_status()
    tmp = out_file.with_suffix(out_file.suffix + ".tmp")
    with tmp.open("wb") as f:
        for chunk in r.iter_content(chunk_size=1024 * 256):
            if chunk:
                f.write(chunk)
    tmp.replace(out_file)
    return out_file


def resize_to_1400x700(path: Path) -> None:
    im = Image.open(path).convert("RGB")
    # Preserve aspect by center-crop to 2:1 then resize.
    w, h = im.size
    target_ratio = TARGET_W / TARGET_H
    cur_ratio = w / h
    if abs(cur_ratio - target_ratio) > 1e-3:
        if cur_ratio > target_ratio:
            # too wide => crop width
            new_w = int(h * target_ratio)
            x0 = (w - new_w) // 2
            im = im.crop((x0, 0, x0 + new_w, h))
        else:
            # too tall => crop height
            new_h = int(w / target_ratio)
            y0 = (h - new_h) // 2
            im = im.crop((0, y0, w, y0 + new_h))
    im = im.resize((TARGET_W, TARGET_H), Image.Resampling.LANCZOS)
    im.save(path, quality=92, optimize=True)


def is_placeholder_asset(path: Path) -> bool:
    # crude heuristic: our generated placeholders have an "ACT" label in the bottom-left (red)
    # but we don't want to read pixels here; keep it simple: treat missing as placeholder.
    return not path.exists()


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument(
        "--assets-json",
        default=str(DEFAULT_ASSETS_JSON),
        help="Path to *_assets.json (e.g. assets/stories/ink/Story_02_assets.json)",
    )
    ap.add_argument(
        "--story",
        default=str(DEFAULT_STORY_MD),
        help="Path to Ink .md story file (for scene-context extraction).",
    )
    ap.add_argument(
        "--kinds",
        default="IMG",
        help='Comma-separated kinds to generate: "IMG", "BG", or "BG,IMG". Default: IMG (overlay images only).',
    )
    ap.add_argument("--dry-run", action="store_true", help="Only output prompt plan, do not call Replicate.")
    ap.add_argument("--overwrite", action="store_true", help="Overwrite existing images.")
    ap.add_argument("--limit", type=int, default=0, help="Generate only first N tasks (0 = all).")
    ap.add_argument(
        "--start-at",
        default="",
        help="Start generation at the first task whose key matches this value (useful to resume after a failure).",
    )
    args = ap.parse_args()

    assets_json_path = Path(args.assets_json)
    story_path = Path(args.story)
    if not assets_json_path.exists() or not story_path.exists():
        raise SystemExit(f"Missing assets or story file: {assets_json_path} / {story_path}")

    style = load_style()
    # Tell user whether we're using their custom style or the fallback.
    if STYLE_TXT.exists():
        raw = STYLE_TXT.read_text(encoding="utf-8")
        has_custom = any(ln.strip() and not ln.strip().startswith("#") for ln in raw.splitlines())
        if not has_custom:
            print("NOTE: tools/replicate_style.txt has no custom style lines; using built-in Sin City fallback style.")

    kinds = [k.strip().upper() for k in args.kinds.split(",") if k.strip()]
    for k in kinds:
        if k not in ("BG", "IMG"):
            raise SystemExit(f"Invalid --kinds value: {k}. Use BG and/or IMG.")

    tasks = build_tasks(style, kinds, assets_json_path=assets_json_path, story_path=story_path)
    if args.start_at:
        start_idx = next((i for i, t in enumerate(tasks) if t.key == args.start_at), None)
        if start_idx is None:
            raise SystemExit(f"--start-at key not found: {args.start_at}")
        tasks = tasks[start_idx:]

    plan = [
        {
            "kind": t.kind,
            "key": t.key,
            "path": str(t.out_path.relative_to(ROOT)),
            "prompt": t.prompt,
            "negative_prompt": t.negative_prompt,
            "context": t.context,
        }
        for t in tasks
    ]

    # Write a plan next to tools/, named after the story file
    safe_name = story_path.stem.lower()
    out_plan = ROOT / "tools" / f"replicate_prompt_plan_{safe_name}.json"
    out_plan.write_text(json.dumps(plan, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Wrote prompt plan: {out_plan}")

    if args.dry_run:
        print("Dry-run complete (no API calls).")
        return

    token = load_token()
    to_run = tasks[: args.limit] if args.limit and args.limit > 0 else tasks

    for idx, t in enumerate(to_run, start=1):
        if t.out_path.exists() and not args.overwrite:
            print(f"[{idx}/{len(to_run)}] SKIP exists: {t.out_path}")
            continue

        # Best-effort input schema for black-forest-labs/flux-1.1-pro:
        # - aspect_ratio supports a fixed enum set; for 2:1 we must use "custom" and supply width/height.
        payload = {
            "prompt": _to_ascii_safe(t.prompt),
            "negative_prompt": _to_ascii_safe(t.negative_prompt),
            "aspect_ratio": "custom",
            "width": TARGET_W,
            "height": TARGET_H,
            "output_format": "jpg" if t.out_path.suffix.lower() in (".jpg", ".jpeg") else "png",
            # Allow mild safety relaxation while still safe; helps reduce false positives.
            "safety_tolerance": 2,
            # Deterministic-ish retries if needed
            "seed": int(time.time()) % 100000,
        }

        print(f"[{idx}/{len(to_run)}] GEN {t.kind}:{t.key} -> {t.out_path.relative_to(ROOT)}")
        def _try(run_payload: dict, label: str) -> dict:
            pred = replicate_create_prediction(token, args.model, run_payload)
            done_ = replicate_poll(token, pred)
            if done_.get("status") == "succeeded":
                return done_
            err_ = (done_.get("error") or "").lower()
            if "nsfw" in err_ or "safety" in err_:
                raise ValueError("nsfw")
            raise RuntimeError(f"failed: {done_}")

        # Try up to 3 times on NSFW false positives, progressively stripping any human cues.
        done = None
        try:
            done = _try(payload, "base")
        except ValueError:
            retry1 = dict(payload)
            retry1["seed"] = (payload["seed"] + 1337) % 100000
            retry1["safety_tolerance"] = 3
            retry1["prompt"] = payload["prompt"] + " IMPORTANT: empty interior still life, absolutely no humans, no body parts, no skin."
            retry1["negative_prompt"] = payload["negative_prompt"] + ", human, person, body, hand, skin, feet, face"
            print(f"[{idx}/{len(to_run)}] RETRY1 (nsfw-guard) {t.key}")
            try:
                done = _try(retry1, "retry1")
            except ValueError:
                retry2 = dict(payload)
                retry2["seed"] = (payload["seed"] + 4242) % 100000
                retry2["safety_tolerance"] = 4
                # Nuke the context/hint entirely (some words may be causing false positives)
                retry2["prompt"] = _to_ascii_safe(
                    f"wide cinematic close-up of an empty apartment interior still life, "
                    f"abandoned objects on the floor (coat/blanket), no humans, no body parts, "
                    f"no skin, no faces. aspect ratio {ASPECT_RATIO}, composition designed for 2:1. "
                    f"Style: {DEFAULT_STYLE}"
                )
                retry2["negative_prompt"] = _to_ascii_safe(
                    payload["negative_prompt"] + ", human, person, body, hand, skin, feet, face"
                )
                print(f"[{idx}/{len(to_run)}] RETRY2 (nsfw-guard hard) {t.key}")
                done = _try(retry2, "retry2")
        except RuntimeError as e:
            raise RuntimeError(f"Prediction failed for {t.key}: {e}") from e
        output = done.get("output")
        download_first_output(output, t.out_path)
        resize_to_1400x700(t.out_path)
        print(f"Saved {t.out_path.relative_to(ROOT)} ({TARGET_W}x{TARGET_H})")


if __name__ == "__main__":
    main()


