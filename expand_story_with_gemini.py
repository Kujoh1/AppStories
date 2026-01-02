#!/usr/bin/env python3
"""
Story Expander using Gemini 3 Pro via Replicate API
Expands existing chapters to reach 700,000 characters target
"""

import replicate
import os
import time
from pathlib import Path

# Configuration
SCRIPT_DIR = Path(__file__).parent
TOKEN_FILE = SCRIPT_DIR / ".replicate_token"
OUTPUT_DIR = SCRIPT_DIR / "assets" / "stories" / "ink"

# Target: 700,000 characters total
# Current: ~330,000 characters
# Need to add: ~370,000 characters (roughly double each chapter)

CHAPTERS_TO_EXPAND = [
    {"file": "Story_05_kapitel_8.md", "name": "Kapitel 8: Der Verrat", "target_addition": 30000},
    {"file": "Story_05_kapitel_9.md", "name": "Kapitel 9: Die Kammer der Erinnerung", "target_addition": 30000},
    {"file": "Story_05_kapitel_10.md", "name": "Kapitel 10: Die Dunkelheit", "target_addition": 30000},
    {"file": "Story_05_kapitel_11.md", "name": "Kapitel 11: Der Schlüssel", "target_addition": 30000},
    {"file": "Story_05_kapitel_12.md", "name": "Kapitel 12: Weltweite Flucht", "target_addition": 30000},
    {"file": "Story_05_kapitel_13.md", "name": "Kapitel 13: Die Sammlung", "target_addition": 30000},
    {"file": "Story_05_kapitel_14.md", "name": "Kapitel 14: Die Allianz", "target_addition": 30000},
    {"file": "Story_05_kapitel_15.md", "name": "Kapitel 15: Die Konfrontation", "target_addition": 30000},
    {"file": "Story_05_kapitel_16.md", "name": "Kapitel 16: Das Erwachen der Dunkelheit", "target_addition": 30000},
    {"file": "Story_05_kapitel_17.md", "name": "Kapitel 17: Die letzte Wahl", "target_addition": 30000},
    {"file": "Story_05_kapitel_18.md", "name": "Kapitel 18: Die Enden", "target_addition": 50000},
]

EXPAND_PROMPT = """Du bist ein preisgekrönter Autor für interaktive Fiction.

AUFGABE: Erweitere das folgende Kapitel erheblich. Füge hinzu:
- Mehr atmosphärische Beschreibungen
- Tiefere Charakterentwicklung
- Zusätzliche Dialoge
- Mehr Spielerentscheidungen mit Variablenänderungen
- Spannungsaufbau und emotionale Momente
- Details zur Welt und Technologie

REGELN:
1. Behalte die bestehende Struktur bei (Ink-Format)
2. Erweitere JEDE Szene um mindestens 50%
3. Füge neue Zwischenszenen ein
4. Mehr #IMG und #MOOD Tags
5. Mindestens 2 zusätzliche Spielerentscheidungen pro Szene
6. Schreibe auf Deutsch, gehobener aber zugänglicher Stil
7. Ziel: {target_addition} zusätzliche Zeichen

VARIABLEN (für Entscheidungen):
- marcus_trust, aria_trust, okonkwo_trust (0-10)
- darkness_connection (0-10)
- father_path, kael_awakened, romance_marcus (true/false)
- keys_collected (1-12)
- walker_alive, reyes_alive (true/false)
- perfect_playthrough (true/false)

AKTUELLES KAPITEL:
{chapter_content}

ERWEITERTES KAPITEL (mindestens {target_addition} Zeichen hinzufügen):
"""


def load_token():
    """Load Replicate API token from file"""
    if not TOKEN_FILE.exists():
        return None
    
    with open(TOKEN_FILE, 'r') as f:
        lines = f.readlines()
    
    for line in lines:
        line = line.strip()
        if line and not line.startswith('#') and line.startswith('r8_'):
            return line
    
    return None


def expand_chapter(chapter_info, token):
    """Expand a single chapter using Gemini 3 Pro"""
    
    chapter_path = OUTPUT_DIR / chapter_info["file"]
    
    if not chapter_path.exists():
        print(f"   ❌ Datei nicht gefunden: {chapter_path}")
        return None
    
    with open(chapter_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_length = len(content)
    print(f"   Original: {original_length:,} Zeichen")
    
    prompt = EXPAND_PROMPT.format(
        target_addition=chapter_info["target_addition"],
        chapter_content=content
    )
    
    try:
        output = replicate.run(
            "google/gemini-3-pro",
            input={
                "prompt": prompt,
                "max_tokens": 32000,
                "temperature": 0.8,
            }
        )
        
        result = "".join(output)
        new_length = len(result)
        added = new_length - original_length
        
        print(f"   Erweitert: {new_length:,} Zeichen (+{added:,})")
        
        return result
        
    except Exception as e:
        print(f"   ❌ Fehler: {e}")
        return None


def main():
    """Main function to expand all chapters"""
    
    print("=" * 60)
    print("📚 ECHOES OF THE FIRST DAWN - Story Erweiterung")
    print("   Using Gemini 3 Pro via Replicate API")
    print("   Ziel: 700.000 Zeichen")
    print("=" * 60)
    
    # Load token
    token = load_token()
    if not token:
        print("❌ Kein Token gefunden!")
        return
    
    os.environ["REPLICATE_API_TOKEN"] = token
    print(f"   Token geladen: {token[:10]}...")
    
    # Calculate current total
    total_current = 0
    for f in OUTPUT_DIR.glob("Story_05*.md"):
        if "Drehbuch" not in f.name and "Detailplanung" not in f.name:
            total_current += f.stat().st_size
    
    print(f"\n📊 Aktueller Stand: {total_current:,} Zeichen")
    print(f"   Ziel: 700.000 Zeichen")
    print(f"   Benötigt: +{700000 - total_current:,} Zeichen")
    
    # Expand chapters
    expanded_total = 0
    
    for i, chapter in enumerate(CHAPTERS_TO_EXPAND):
        print(f"\n{'=' * 40}")
        print(f"Kapitel {i+1}/{len(CHAPTERS_TO_EXPAND)}: {chapter['name']}")
        print(f"{'=' * 40}")
        
        expanded = expand_chapter(chapter, token)
        
        if expanded:
            # Save expanded version
            expanded_path = OUTPUT_DIR / chapter["file"].replace(".md", "_expanded.md")
            with open(expanded_path, 'w', encoding='utf-8') as f:
                f.write(expanded)
            
            expanded_total += len(expanded)
            print(f"   💾 Gespeichert: {expanded_path.name}")
        
        # Delay
        if i < len(CHAPTERS_TO_EXPAND) - 1:
            print("   ⏳ Warte 3 Sekunden...")
            time.sleep(3)
    
    # Create final combined file
    print("\n" + "=" * 60)
    print("📖 Erstelle finale kombinierte Datei...")
    
    # Read original Akt I + II
    combined = ""
    for part in ["Story_05.md", "Story_05_Teil2.md"]:
        part_path = OUTPUT_DIR / part
        if part_path.exists():
            with open(part_path, 'r', encoding='utf-8') as f:
                combined += f.read() + "\n\n"
    
    # Add expanded chapters
    for chapter in CHAPTERS_TO_EXPAND:
        expanded_path = OUTPUT_DIR / chapter["file"].replace(".md", "_expanded.md")
        if expanded_path.exists():
            with open(expanded_path, 'r', encoding='utf-8') as f:
                combined += f.read() + "\n\n"
    
    combined += "\n-> END"
    
    # Save
    final_path = OUTPUT_DIR / "Story_05_final.md"
    with open(final_path, 'w', encoding='utf-8') as f:
        f.write(combined)
    
    print(f"\n✅ FERTIG!")
    print(f"   Finale Datei: {final_path}")
    print(f"   Gesamtlänge: {len(combined):,} Zeichen")


if __name__ == "__main__":
    main()

