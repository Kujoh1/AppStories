# 🎨 Story 04 Image Generation Guide

Dieses Script generiert automatisch alle 28 Bilder für "Der Frankfurt-Komplex" mit FLUX Schnell AI.

## 📋 Voraussetzungen

1. **Replicate API Token**
   - Gehe zu: https://replicate.com/account/api-tokens
   - Erstelle einen API Token (kostenloser Account reicht für Tests)
   - Kopiere den Token

2. **Python Packages**
   ```bash
   pip install -r requirements_image_gen.txt
   ```

## 🚀 Verwendung

### Schritt 1: API Token setzen
```bash
export REPLICATE_API_TOKEN='dein-token-hier'
```

### Schritt 2: Script ausführen
```bash
cd /Users/johanneskuch/Documents/GIT/AppStories/AppStories
python3 generate_story_images.py
```

### Schritt 3: Warten
Das Script generiert alle 28 Bilder nacheinander. Das dauert ca. 5-10 Minuten.

## 📂 Output

Alle Bilder werden gespeichert in:
```
assets/img/story04/
├── ffm_skyline_distorted.png
├── piano_blood_drop.png
├── dead_bird_hand.png
├── main_wache_underground.png
├── butcher_shadow.png
├── ... (28 Bilder insgesamt)
```

## 🎭 Generierte Bilder

| Bild | Beschreibung | Szene |
|------|-------------|-------|
| `ffm_skyline_distorted` | Frankfurt Skyline verzerrt | Prolog |
| `piano_blood_drop` | Bluttropfen auf Klavier | Kindheit Flashback |
| `dead_bird_hand` | Toter Vogel in Hand | Kindheit Flashback |
| `wagner_family_memorial` | Wagner Familie Collage | Psychotest |
| `victims_file_wall` | Opfer-Akten Wand | Ludwig's Akten |
| `torn_portrait` | Zerrissenes Portrait | Julian Flashback |
| `muddy_drawing` | Strichmännchen im Matsch | Peter Flashback |
| `main_wache_underground` | Hauptwache Tunnel | Ebene 1 |
| `butcher_shadow` | Schlächter Schatten | Ebene 1 |
| `ffm_office_mirror` | Spiegel-Büro | Nach Ventilator |
| `hospital_underground` | Krankenhaus | Ebene 2 |
| `two_syringes` | Zwei Spritzen | Ebene 2 |
| `rising_water_tunnel` | Flutender Tunnel | Flucht |
| `stock_exchange_underground` | Makabre Börse | Kontrollzentrum |
| `memory_corridor_pavement` | Pflaster-Korridor | Erinnerungen |
| `underground_living_room` | Ludwigs Versteck | Nebenstory 1 |
| `underground_drones` | Jagd-Drohnen | Nebenstory 1 |
| `identity_lab` | Klonlabor | Nebenstory 2 |
| `digital_twin` | Digitaler Zwilling | Nebenstory 2 |
| `fathers_study` | Vaters Arbeitszimmer | Nebenstory 3 |
| `golden_ring` | Goldener Siegelring | Nebenstory 3 |
| `main_tower_summit` | Main Tower Gipfel | Finale |
| `revolver_choice` | Revolver Entscheidung | Finale |
| `elias_sacrifice` | Elias' Opfer | Ende 1 |
| `falling_shadow` | Fallender Schatten | Ende 2 |
| `ffm_ruins` | Frankfurt in Trümmern | Ende 3 |
| `ghosts_of_frankfurt` | Geister der Stadt | Epilog |

## 💰 Kosten

FLUX Schnell ist sehr günstig:
- ~$0.003 pro Bild
- 28 Bilder = ca. $0.08 (8 Cent) gesamt

## ⚙️ Stil-Parameter

Alle Bilder verwenden:
- **Stil**: Retro Comic Art, Sin City Style
- **Format**: 16:9
- **Qualität**: 90% PNG
- **Sprache**: Keine Buchstaben/Zeichen im Bild
- **Beschleunigung**: `go_fast=True` aktiviert

## 🔧 Anpassungen

Um Prompts zu ändern, editiere `generate_story_images.py`:
```python
IMAGES = {
    "image_id": {
        "prompt": "retro comic art, sin city style, deine Beschreibung...",
        "count": 1
    }
}
```

## 📝 Nächste Schritte

Nach der Generierung:

1. **Bilder prüfen** in `assets/img/story04/`
2. **Story_04_assets.json erstellen** mit Pfaden:
   ```json
   {
     "ffm_skyline_distorted": "assets/img/story04/ffm_skyline_distorted.png",
     ...
   }
   ```
3. **In der App testen**

## ❓ Troubleshooting

**"REPLICATE_API_TOKEN not set"**
→ Token mit `export REPLICATE_API_TOKEN='...'` setzen

**"Image generation failed"**
→ Prüfe Internet-Verbindung und API Token Gültigkeit

**"Out of credits"**
→ Füge Credits hinzu auf https://replicate.com/account/billing

## 📚 Weitere Infos

- FLUX Schnell Docs: https://replicate.com/black-forest-labs/flux-schnell
- Replicate API Docs: https://replicate.com/docs

