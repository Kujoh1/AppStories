#!/usr/bin/env python3
"""
Story Generator using Gemini 3 Pro via Replicate API
Generates the interactive story "Echoes of the First Dawn" chapter by chapter
"""

import replicate
import os
import time
from pathlib import Path

# Configuration
SCRIPT_DIR = Path(__file__).parent
TOKEN_FILE = SCRIPT_DIR / ".replicate_token"
OUTPUT_DIR = SCRIPT_DIR / "assets" / "stories" / "ink"
DREHBUCH_FILE = OUTPUT_DIR / "Story_05_Drehbuch.md"
DETAIL_FILE_1 = OUTPUT_DIR / "Story_05_Detailplanung.md"
DETAIL_FILE_2 = OUTPUT_DIR / "Story_05_Detailplanung_Teil2.md"

# Already written chapters (by Claude):
# - Story_05.md: Prolog + Kapitel 1-3 (Akt I) - ~50.000 Zeichen
# - Story_05_Teil2.md: Kapitel 4-7 (Akt II) - ~55.000 Zeichen
# Total already written: ~105.000 Zeichen

# Chapters to generate with Gemini (starting from Chapter 8)
CHAPTERS = [
    {
        "id": "kapitel_8",
        "name": "Kapitel 8: Der Verrat",
        "akt": "III",
        "target_chars": 35000,
        "description": "Flucht über das Eis. Okonkwos wahre Agenda. Der Maulwurf wird enthüllt. Neue Verbündete, neue Feinde."
    },
    {
        "id": "kapitel_9",
        "name": "Kapitel 9: Die Kammer der Erinnerung",
        "akt": "III",
        "target_chars": 35000,
        "description": "Die Wächter. Das Ritual. Lena erlebt Kaels vollständige Geschichte. Die wahre Natur der Dunkelheit."
    },
    {
        "id": "kapitel_10",
        "name": "Kapitel 10: Die Dunkelheit",
        "akt": "III",
        "target_chars": 35000,
        "description": "Die Prophezeiung. Ashfords Angriff auf den Tempel. Elias' Opfer. Die Wahl zwischen Standorten."
    },
    {
        "id": "kapitel_11",
        "name": "Kapitel 11: Der Schlüssel",
        "akt": "III",
        "target_chars": 35000,
        "description": "Drei Pfade (Sphinx/Marianengraben/Ashfords Festung). Ashfords Offenbarung. Die Schlüssel-Aktivierung."
    },
    {
        "id": "kapitel_12",
        "name": "Kapitel 12: Weltweite Flucht",
        "akt": "IV",
        "target_chars": 35000,
        "description": "Das globale Rennen. Tibet - der Tempel über den Wolken. Die spirituelle Prüfung. Ashfords Konfrontation."
    },
    {
        "id": "kapitel_13",
        "name": "Kapitel 13: Die Sammlung",
        "akt": "IV",
        "target_chars": 35000,
        "description": "Sibirien. Die Überreste. Zheng's Verrat. Der letzte freie Schlüssel."
    },
    {
        "id": "kapitel_14",
        "name": "Kapitel 14: Die Allianz",
        "akt": "IV",
        "target_chars": 35000,
        "description": "Verbündete sammeln. Marcus' Geständnis. Okonkwos Rückkehr. Die Nacht vor der Schlacht."
    },
    {
        "id": "kapitel_15",
        "name": "Kapitel 15: Die Konfrontation",
        "akt": "IV",
        "target_chars": 35000,
        "description": "Rückkehr zur Aurora. Das Ultimatum. Die Schlacht. Der Kern. Cliffhanger zur letzten Wahl."
    },
    {
        "id": "kapitel_16",
        "name": "Kapitel 16: Das Erwachen der Dunkelheit",
        "akt": "V",
        "target_chars": 35000,
        "description": "Jenseits der Realität. Die wahre Natur der Dunkelheit. Ashfords Fall. Visionen der möglichen Zukünfte."
    },
    {
        "id": "kapitel_17",
        "name": "Kapitel 17: Die letzte Wahl",
        "akt": "V",
        "target_chars": 35000,
        "description": "Die Optionen. Die Stimmen der Verbündeten. Die große Spielerentscheidung."
    },
    {
        "id": "kapitel_18",
        "name": "Kapitel 18: Die Enden",
        "akt": "V",
        "target_chars": 50000,
        "description": "Alle 5 Enden: Neuanfang, Aufbruch, Transzendenz, Dunkelheit, Synthese (geheim)."
    },
]

# System prompt for Gemini
SYSTEM_PROMPT = """Du bist ein preisgekrönter Autor für interaktive Fiction im Ink-Format.

DEINE AUFGABE:
Schreibe ein Kapitel einer interaktiven Science-Fiction-Geschichte im Ink-Format.

STIL:
- Atmosphärisch, spannend, emotional
- Deutsche Sprache, gehobener aber zugänglicher Stil
- Lebendige Beschreibungen, packende Dialoge
- Noir-Elemente, kosmischer Horror, menschliche Beziehungen

INK-FORMAT REGELN:
1. Verwende === knoten_name === für Szenen
2. Verwende #IMG bildname für Bildtags
3. Verwende #MOOD stimmung für Stimmungstags (noir, still)
4. Verwende * [Wahltext] für Spielerentscheidungen
5. Verwende -> knoten_name für Sprünge
6. Verwende ~ variable = wert für Variablenänderungen
7. Verwende {bedingung: text} für bedingte Texte

VARIABLEN (bereits definiert):
- marcus_trust (0-10)
- aria_trust (0-10)
- okonkwo_trust (0-10)
- darkness_connection (0-10)
- father_path (true/false)
- keys_collected (1-12)
- walker_alive (true/false)
- reyes_alive (true/false)
- kael_awakened (true/false)
- romance_marcus (true/false)
- perfect_playthrough (true/false)

WICHTIG:
- Mindestens 3-4 Spielerentscheidungen pro Kapitel
- Entscheidungen sollen Variablen beeinflussen
- Jede Szene beginnt mit passendem #IMG und #MOOD Tag
- Schreibe MINDESTENS die angegebene Zeichenzahl
- Die Geschichte soll spannend und fesselnd sein
- Charaktere sollen Tiefe haben
- Dialoge sollen natürlich klingen
"""

def load_token():
    """Load Replicate API token from file"""
    if not TOKEN_FILE.exists():
        print(f"❌ Token-Datei nicht gefunden: {TOKEN_FILE}")
        print("Erstelle die Datei und füge deinen Replicate API Token ein.")
        return None
    
    with open(TOKEN_FILE, 'r') as f:
        lines = f.readlines()
    
    # Find the actual token (line starting with r8_)
    token = None
    for line in lines:
        line = line.strip()
        if line and not line.startswith('#') and line.startswith('r8_'):
            token = line
            break
    
    if not token or token == "YOUR_TOKEN_HERE":
        print("❌ Bitte füge deinen Replicate API Token in die Datei ein.")
        return None
    
    print(f"   Token geladen: {token[:10]}...")
    return token


def load_context():
    """Load the story outline and details for context"""
    context_parts = []
    
    # Load main outline
    if DREHBUCH_FILE.exists():
        with open(DREHBUCH_FILE, 'r', encoding='utf-8') as f:
            context_parts.append("=== HAUPTDREHBUCH ===\n" + f.read())
    
    # Load detailed planning
    if DETAIL_FILE_1.exists():
        with open(DETAIL_FILE_1, 'r', encoding='utf-8') as f:
            context_parts.append("\n=== DETAILPLANUNG AKT I-II ===\n" + f.read())
    
    if DETAIL_FILE_2.exists():
        with open(DETAIL_FILE_2, 'r', encoding='utf-8') as f:
            context_parts.append("\n=== DETAILPLANUNG AKT III-V ===\n" + f.read())
    
    return "\n".join(context_parts)


def load_existing_chapters():
    """Load already written chapters (by Claude) for context"""
    existing = ""
    
    # Load Akt I (Prolog + Kapitel 1-3)
    akt1_file = OUTPUT_DIR / "Story_05.md"
    if akt1_file.exists():
        with open(akt1_file, 'r', encoding='utf-8') as f:
            existing += f.read()
        print(f"   Geladen: Story_05.md ({len(existing)} Zeichen)")
    
    # Load Akt II (Kapitel 4-7)
    akt2_file = OUTPUT_DIR / "Story_05_Teil2.md"
    if akt2_file.exists():
        with open(akt2_file, 'r', encoding='utf-8') as f:
            content = f.read()
            existing += "\n\n" + content
        print(f"   Geladen: Story_05_Teil2.md ({len(content)} Zeichen)")
    
    return existing


def generate_chapter(chapter_info, context, previous_chapters=""):
    """Generate a single chapter using Gemini 3 Pro"""
    
    prompt = f"""
{SYSTEM_PROMPT}

=== KONTEXT: DIE GESAMTE GESCHICHTE ===
{context}

=== BEREITS GESCHRIEBENE KAPITEL (für Konsistenz) ===
{previous_chapters[-50000:] if previous_chapters else "Dies ist der Anfang der Geschichte."}

=== DEINE AUFGABE ===
Schreibe jetzt: {chapter_info['name']} (Akt {chapter_info['akt']})

Beschreibung: {chapter_info['description']}

Ziel-Zeichenzahl: MINDESTENS {chapter_info['target_chars']} Zeichen

Beginne das Kapitel mit:
=== {chapter_info['id']} ===

Schreibe das komplette Kapitel im Ink-Format. Sei kreativ, spannend und detailliert!
"""

    print(f"\n📝 Generiere: {chapter_info['name']}...")
    print(f"   Ziel: {chapter_info['target_chars']} Zeichen")
    
    try:
        output = replicate.run(
            "google/gemini-3-pro",
            input={
                "prompt": prompt,
                "max_tokens": 16000,  # Maximum for detailed output
                "temperature": 0.8,   # Creative but coherent
            }
        )
        
        # Collect streaming output
        result = ""
        for item in output:
            result += item
        
        print(f"   ✅ Generiert: {len(result)} Zeichen")
        return result
        
    except Exception as e:
        print(f"   ❌ Fehler: {e}")
        return None


def main():
    """Main function to generate the remaining chapters"""
    
    print("=" * 60)
    print("🌟 ECHOES OF THE FIRST DAWN - Story Generator")
    print("   Using Gemini 3 Pro via Replicate API")
    print("   Fortsetzung ab Kapitel 8 (Akt III)")
    print("=" * 60)
    
    # Load token
    token = load_token()
    if not token:
        return
    
    os.environ["REPLICATE_API_TOKEN"] = token
    
    # Load context
    print("\n📚 Lade Drehbuch und Detailplanung...")
    context = load_context()
    print(f"   Kontext geladen: {len(context)} Zeichen")
    
    # Load existing chapters (written by Claude)
    print("\n📖 Lade bereits geschriebene Kapitel (Akt I + II)...")
    existing_chapters = load_existing_chapters()
    print(f"   Bereits geschrieben: {len(existing_chapters):,} Zeichen")
    
    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Generate remaining chapters
    all_new_chapters = ""
    generated_files = []
    
    print(f"\n🚀 Generiere {len(CHAPTERS)} verbleibende Kapitel mit Gemini 3 Pro...")
    
    for i, chapter in enumerate(CHAPTERS):
        print(f"\n{'=' * 40}")
        print(f"Kapitel {i+1}/{len(CHAPTERS)}: {chapter['name']}")
        print(f"{'=' * 40}")
        
        # Use existing + newly generated as context
        full_context = existing_chapters + all_new_chapters
        
        # Generate chapter
        chapter_text = generate_chapter(chapter, context, full_context)
        
        if chapter_text:
            all_new_chapters += "\n\n" + chapter_text
            
            # Save individual chapter file
            chapter_file = OUTPUT_DIR / f"Story_05_{chapter['id']}.md"
            with open(chapter_file, 'w', encoding='utf-8') as f:
                f.write(chapter_text)
            generated_files.append(chapter_file)
            
            print(f"   💾 Gespeichert: {chapter_file.name}")
        
        # Small delay to avoid rate limiting
        if i < len(CHAPTERS) - 1:
            print("   ⏳ Warte 2 Sekunden...")
            time.sleep(2)
    
    # Create Teil 3 file with new chapters
    print("\n" + "=" * 60)
    print("📖 Speichere Akt III-V...")
    
    teil3_file = OUTPUT_DIR / "Story_05_Teil3.md"
    with open(teil3_file, 'w', encoding='utf-8') as f:
        f.write("# ECHOES OF THE FIRST DAWN\n")
        f.write("## Teil 3: Akt III-V (generiert mit Gemini 3 Pro)\n\n")
        f.write(all_new_chapters)
    
    print(f"   💾 Gespeichert: {teil3_file.name}")
    
    # Combine ALL chapters into one complete file
    print("\n📖 Kombiniere alle Kapitel (Akt I-V)...")
    
    combined_file = OUTPUT_DIR / "Story_05_complete.md"
    
    with open(combined_file, 'w', encoding='utf-8') as f:
        f.write(existing_chapters)
        f.write("\n\n// ═══════════════════════════════════════════════════════════════")
        f.write("\n// AKT III-V (generiert mit Gemini 3 Pro)")
        f.write("\n// ═══════════════════════════════════════════════════════════════\n")
        f.write(all_new_chapters)
        f.write("\n\n-> END")
    
    total_chars = len(existing_chapters) + len(all_new_chapters)
    
    print(f"\n✅ FERTIG!")
    print(f"   Bereits geschrieben (Claude): {len(existing_chapters):,} Zeichen")
    print(f"   Neu generiert (Gemini): {len(all_new_chapters):,} Zeichen")
    print(f"   GESAMT: {total_chars:,} Zeichen")
    print(f"   Komplette Datei: {combined_file}")
    print(f"   Neue Kapitel: {len(generated_files)}")
    
    print("\n📋 Generierte Dateien:")
    for f in generated_files:
        print(f"   - {f.name}")


if __name__ == "__main__":
    main()

