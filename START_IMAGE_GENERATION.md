# 🚀 Bilder generieren - Schnellstart

## Schritt 1: Token einfügen

1. Öffne die Datei **`.replicate_token`**
2. Ersetze `YOUR_TOKEN_HERE` mit deinem echten Token
3. Speichere die Datei

**Wo bekomme ich den Token?**
→ https://replicate.com/account/api-tokens

## Schritt 2: Script ausführen

```bash
cd /Users/johanneskuch/Documents/GIT/AppStories/AppStories
pip3 install -r requirements_image_gen.txt
python3 generate_story_images.py
```

## Das war's! 🎉

Das Script:
- ✅ Liest automatisch den Token aus `.replicate_token`
- ✅ Generiert alle 28 Bilder
- ✅ Speichert sie in `assets/img/story04/`
- ✅ Dauert ca. 5-10 Minuten
- ✅ Kostet ca. 8 Cent

## Während es läuft:

Du siehst so etwas:
```
🎨 Starting image generation for Story 04: Der Frankfurt-Komplex
📁 Output directory: assets/img/story04
🖼️  Total images to generate: 28

[1/28] Generating: ffm_skyline_distorted
Prompt: retro comic art, sin city style, Frankfurt skyline at night...
✓ Saved: ffm_skyline_distorted.png

[2/28] Generating: piano_blood_drop
...
```

## Fertig?

Dann findest du alle Bilder hier:
```
assets/img/story04/
├── ffm_skyline_distorted.png
├── piano_blood_drop.png
├── dead_bird_hand.png
├── ... (28 Bilder total)
```

## Probleme?

**Script findet Token nicht:**
→ Prüfe, ob `.replicate_token` wirklich `YOUR_TOKEN_HERE` ersetzt wurde

**"No module named replicate":**
→ Führe aus: `pip3 install -r requirements_image_gen.txt`

**Bilder sehen nicht gut aus:**
→ Die Prompts können in `generate_story_images.py` angepasst werden

## Nächste Schritte

Nach der Generierung:
1. Bilder prüfen
2. `Story_04_assets.json` erstellen (falls noch nicht vorhanden)
3. In der App testen

Viel Erfolg! 🎨✨


