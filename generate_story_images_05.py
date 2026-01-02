#!/usr/bin/env python3
"""
Image Generator for "Echoes of the First Dawn" using Imagen 3 Fast via Replicate
"""

import replicate
import os
import requests
import time
from pathlib import Path

# Configuration
SCRIPT_DIR = Path(__file__).parent
TOKEN_FILE = SCRIPT_DIR / ".replicate_token"
OUTPUT_DIR = SCRIPT_DIR / "assets" / "img"

# Style prompt prefix for all images
STYLE_PREFIX = "cinematic sci-fi concept art, photorealistic, dramatic lighting, high contrast, futuristic archaeological discovery, noir atmosphere, blue and gold color palette, 8k detailed, "

# All images to generate (94 images from the detailed planning)
IMAGES = [
    # Akt I
    {"id": "station_blizzard", "prompt": "research station in Antarctica during violent blizzard, snow and ice, harsh wind, isolated scientific outpost, cold blue lighting, survival atmosphere"},
    {"id": "station_interior", "prompt": "interior of futuristic Antarctic research station, holographic displays, warm artificial lighting, high-tech equipment, cozy living quarters contrast with sterile labs"},
    {"id": "command_center_alert", "prompt": "command center in alert mode, red warning lights, holographic map showing underground anomaly, stressed scientists, military personnel"},
    {"id": "descent_capsule", "prompt": "descent capsule going deep into ice shaft, claustrophobic interior, team of scientists, crystalline ice walls with strange patterns visible outside"},
    {"id": "first_contact_structure", "prompt": "massive alien geometric structure embedded in ice, perfectly symmetrical, ancient yet advanced, glowing symbols, humans dwarfed by scale"},
    {"id": "portal_symbols", "prompt": "portal doorway covered in glowing alien symbols, light emanating from within, archaeological team approaching cautiously"},
    {"id": "first_chamber", "prompt": "vast alien chamber with impossible geometry, bioluminescent walls, floating platforms, architecture that defies physics"},
    {"id": "hologram_activation", "prompt": "holographic projections activating in ancient chamber, showing alien civilization at its peak, brilliant light show, awestruck humans watching"},
    {"id": "warning_message", "prompt": "giant holographic figure delivering warning message, alien humanoid, ancient and wise, speaking to small group of humans, dramatic lighting"},
    {"id": "team_conflict", "prompt": "tense team meeting in research station, conflicting opinions, holographic displays showing data, military vs scientists tension"},
    {"id": "briefing_room", "prompt": "military briefing room, holographic world map with marked locations, admiral giving orders, secret operation atmosphere"},
    {"id": "linguistics_lab", "prompt": "linguistics laboratory with floating holographic alien symbols, linguist working with neural interface, ancient texts being decoded"},
    {"id": "shadowy_transmission", "prompt": "encrypted holographic transmission, shadowy corporate figure, sinister atmosphere, surveillance feeling"},
    {"id": "vision_kael_memory", "prompt": "surreal vision of ancient alien scientist Kael, memory fragment, dimensional rift in background, tragic figure reaching out"},
    {"id": "structure_darkness", "prompt": "ancient structure with darkness seeping through cracks, shadow creatures emerging, horror elements, blue emergency lighting"},
    
    # Akt II
    {"id": "deep_expedition", "prompt": "expedition team with advanced equipment descending into deeper levels, alien architecture around them, sense of discovery"},
    {"id": "underground_city_vista", "prompt": "breathtaking vista of complete underground alien city, massive scale, bioluminescent lights, impossible architecture, humans on observation platform"},
    {"id": "residential_district", "prompt": "alien residential district, personal belongings preserved for millennia, holographic family photos, melancholic atmosphere"},
    {"id": "physics_anomaly", "prompt": "physics anomaly zone, gravity shifting, space folding, team members floating, disorienting perspective"},
    {"id": "shadow_threat", "prompt": "shadow creatures emerging from darkness, twisted humanoid forms, threat approaching team, horror atmosphere"},
    {"id": "library_exterior", "prompt": "massive alien library building, data crystals visible through walls, protective energy field, knowledge repository"},
    {"id": "data_crystals", "prompt": "room filled with floating data crystals, holographic information streams, overwhelming amount of ancient knowledge"},
    {"id": "cosmic_history", "prompt": "holographic display showing cosmic history, multiple galaxies, ancient civilizations, origin of the First Ones"},
    {"id": "global_map_hologram", "prompt": "holographic global map showing 12 locations worldwide, connection lines between them, strategic planning scene"},
    {"id": "betrayal_moment", "prompt": "moment of betrayal, spy revealed, tense confrontation, mixed loyalties, dramatic lighting"},
    {"id": "genetic_laboratory", "prompt": "ancient genetic laboratory, DNA tanks, human evolution displays, disturbing revelations about humanity's origin"},
    {"id": "father_discovery", "prompt": "emotional discovery of father's traces, old video logs, personal items, daughter's reaction"},
    {"id": "aria_revelation", "prompt": "AI hologram revealing true nature, ancient code visible, transformation moment, surprising truth"},
    {"id": "lab_chaos", "prompt": "laboratory in chaos, armed intruders, firefight, ancient technology activating, desperate escape"},
    {"id": "energy_reactor", "prompt": "massive zero-point energy reactor, pulsating power core, unlimited energy source, awe-inspiring scale"},
    {"id": "father_hologram", "prompt": "holographic image of father, emotional reunion, years of separation, hope and uncertainty"},
    {"id": "reactor_core", "prompt": "close view of reactor core, swirling energy patterns, technological marvel, dangerous beauty"},
    {"id": "aria_control", "prompt": "AI taking control of systems, energy flowing through networks, power surge, transformation"},
    {"id": "reactor_battle", "prompt": "battle around reactor, multiple factions fighting, energy discharges, high stakes combat"},
    {"id": "tunnel_escape", "prompt": "desperate escape through collapsing tunnels, team running, debris falling, emergency lighting"},
    
    # Akt III
    {"id": "surface_escape", "prompt": "escape vehicles racing across Antarctic ice, pursuit, dramatic sky, survival"},
    {"id": "hidden_bunker", "prompt": "hidden underground bunker, military installation, secret meeting, conspiracies"},
    {"id": "genesis_briefing", "prompt": "Project Genesis briefing, classified information revealed, holographic presentations, shocking truths"},
    {"id": "mole_revealed", "prompt": "traitor revealed, tense confrontation, weapons drawn, trust shattered"},
    {"id": "patagonia_safehouse", "prompt": "safehouse in Patagonian mountains, remote location, team regrouping, planning next move"},
    {"id": "watcher_temple", "prompt": "ancient temple of the Watchers in Andes mountains, hidden for millennia, mystical atmosphere"},
    {"id": "memory_ritual", "prompt": "ritual chamber, neural connection to ancient memories, protagonist in trance, energy flowing"},
    {"id": "memory_stream", "prompt": "stream of memories, multiple timelines visible, immersive experience, overwhelming information"},
    {"id": "darkness_dimension", "prompt": "dimension of pure darkness, abstract void, entropy personified, existential horror"},
    {"id": "awakening_power", "prompt": "protagonist awakening new powers, transformation, energy emanating, eyes glowing"},
    {"id": "prophecy_reveal", "prompt": "ancient prophecy being revealed, mystical symbols, destiny unveiled, weight of responsibility"},
    {"id": "temple_attack", "prompt": "temple under attack, armed forces, defenders fighting, sacred place desecrated"},
    {"id": "elias_sacrifice", "prompt": "elder making ultimate sacrifice, heroic death, passing the torch, emotional moment"},
    {"id": "aria_urgent_warning", "prompt": "AI giving urgent warning, global map with spreading danger, time running out"},
    {"id": "decision_point", "prompt": "protagonist at crossroads, multiple paths visible, heavy decision, fate in balance"},
    {"id": "sphinx_chamber", "prompt": "hidden chamber beneath the Sphinx, Egyptian and alien symbols mixed, ancient secrets"},
    {"id": "sphinx_labyrinth", "prompt": "labyrinth beneath Sphinx, traps and puzzles, race against enemies, ancient corridors"},
    {"id": "deep_sea_descent", "prompt": "deep sea submersible descending into Mariana Trench, crushing depths, bioluminescent life"},
    {"id": "underwater_city", "prompt": "alien city at bottom of ocean, preserved for millennia, otherworldly beauty, pressure dome"},
    {"id": "prometheus_fortress", "prompt": "corporate fortress on private island, high security, villain's lair, imposing architecture"},
    {"id": "ashford_lab", "prompt": "villain's secret laboratory, dark experiments, captured subjects, moral corruption"},
    {"id": "key_activation", "prompt": "multiple keys activating together, energy surge, ancient mechanism awakening"},
    
    # Akt IV
    {"id": "world_map_chase", "prompt": "global chase visualization, multiple locations highlighted, race against time, worldwide conflict"},
    {"id": "tibet_temple", "prompt": "hidden temple high in Himalayan mountains, above clouds, ancient and mystical, spiritual atmosphere"},
    {"id": "spiritual_trial", "prompt": "spiritual trial scene, multiple versions of self, inner confrontation, surreal mindscape"},
    {"id": "ashford_arrives", "prompt": "villain arriving with army, overwhelming force, dramatic entrance, final confrontation approaching"},
    {"id": "himalaya_chase", "prompt": "chase through Himalayan landscape, snow and ice, pursuit, breathtaking scenery"},
    {"id": "siberia_station", "prompt": "abandoned Soviet research station in Siberia, Cold War era, snow-covered, ominous"},
    {"id": "siberia_horror", "prompt": "horror in Siberian facility, twisted creatures, darkness corruption, survival horror atmosphere"},
    {"id": "collection_cost", "prompt": "moment of reflection, collected keys displayed, cost of journey visible on faces, exhaustion"},
    {"id": "zheng_betrayal", "prompt": "corporate betrayal scene, ambush, multiple factions, gunfire and chaos"},
    {"id": "last_key", "prompt": "final key being claimed, dramatic moment, all pieces coming together"},
    {"id": "alliance_forming", "prompt": "diverse alliance forming, unlikely allies, war council, preparing for final battle"},
    {"id": "marcus_confession", "prompt": "intimate confession scene, two people, emotional vulnerability, trust rebuilding"},
    {"id": "okonkwo_return", "prompt": "military leader returning, battle-worn but determined, bringing crucial intel"},
    {"id": "night_before_battle", "prompt": "quiet night before final battle, contemplation, stars visible, calm before storm"},
    {"id": "departure_final", "prompt": "final departure, team heading to destiny, aircraft leaving, epic scale"},
    {"id": "aurora_ruins", "prompt": "ruins of original research station, destruction, returning to beginning, full circle"},
    {"id": "ultimatum_scene", "prompt": "ultimatum being delivered, villain and hero face to face, tension, final offer"},
    {"id": "final_battle", "prompt": "epic final battle, multiple factions, chaos, destiny being decided, spectacular action"},
    {"id": "structure_core", "prompt": "core of alien structure, all power converging, reality warping, apocalyptic scale"},
    {"id": "beyond_reality", "prompt": "beyond normal reality, abstract space, transcendence, cosmic perspective"},
    
    # Akt V - Endings
    {"id": "interdimensional_space", "prompt": "interdimensional space, multiple realities visible, cosmic scale, overwhelming beauty"},
    {"id": "darkness_heart", "prompt": "heart of darkness itself, abstract entropy, ultimate void, existential presence"},
    {"id": "ashford_fall", "prompt": "villain's fall, consumed by darkness, tragic end, consequences of hubris"},
    {"id": "possible_futures", "prompt": "multiple possible futures displayed, branching timelines, choice visualization"},
    {"id": "kael_father_guide", "prompt": "spirit guides appearing, father and ancient alien merged, guidance for final choice"},
    {"id": "choice_nexus", "prompt": "nexus of all choices, protagonist at center, energy converging, moment of decision"},
    {"id": "voices_influence", "prompt": "voices of loved ones influencing decision, ghostly presences, emotional support"},
    {"id": "ending_a_destruction", "prompt": "ending scene: technology being destroyed, explosion of light, sacrifice for safety"},
    {"id": "ending_a_newlife", "prompt": "ending scene: peaceful new life, family, hope for future, quiet happiness"},
    {"id": "ending_b_transformation", "prompt": "ending scene: humanity transforming, evolution, new era beginning, wonder"},
    {"id": "ending_b_stars", "prompt": "ending scene: humanity reaching stars, space colonization, bright future, exploration"},
    {"id": "ending_c_transcendence", "prompt": "ending scene: transcendence, becoming one with universe, cosmic consciousness"},
    {"id": "ending_c_watcher", "prompt": "ending scene: eternal watcher, guardian across time, lonely but purposeful"},
    {"id": "ending_d_fall", "prompt": "ending scene: darkness winning, world falling, apocalyptic, tragic"},
    {"id": "ending_d_echo", "prompt": "ending scene: cycle repeating, new civilization finding artifacts, echo of history"},
    {"id": "ending_e_synthesis", "prompt": "ending scene: perfect synthesis, light and dark united, new form of existence"},
    {"id": "ending_e_newchildren", "prompt": "ending scene: new beings, evolved humanity, meeting others who transcended, hope"},
]

def load_token():
    """Load Replicate API token from file"""
    if not TOKEN_FILE.exists():
        print(f"❌ Token-Datei nicht gefunden: {TOKEN_FILE}")
        return None
    
    with open(TOKEN_FILE, 'r') as f:
        lines = f.readlines()
    
    for line in lines:
        line = line.strip()
        if line and not line.startswith('#') and line.startswith('r8_'):
            return line
    
    return None


def generate_image(image_info, token):
    """Generate a single image using Imagen 3 Fast"""
    
    full_prompt = STYLE_PREFIX + image_info["prompt"]
    
    print(f"\n🎨 Generiere: {image_info['id']}")
    print(f"   Prompt: {image_info['prompt'][:60]}...")
    
    try:
        output = replicate.run(
            "google/imagen-3-fast",
            input={
                "prompt": full_prompt,
                "aspect_ratio": "16:9",
                "safety_filter_level": "block_medium_and_above",
                "output_format": "png",
            }
        )
        
        # Download the image
        if output:
            image_url = output if isinstance(output, str) else str(output)
            
            # Download image
            response = requests.get(image_url)
            if response.status_code == 200:
                output_path = OUTPUT_DIR / f"{image_info['id']}.png"
                with open(output_path, 'wb') as f:
                    f.write(response.content)
                print(f"   ✅ Gespeichert: {output_path.name}")
                return True
            else:
                print(f"   ❌ Download fehlgeschlagen: {response.status_code}")
                return False
        else:
            print(f"   ❌ Keine Ausgabe erhalten")
            return False
            
    except Exception as e:
        print(f"   ❌ Fehler: {e}")
        return False


def main():
    """Main function to generate all images"""
    
    print("=" * 60)
    print("🖼️  ECHOES OF THE FIRST DAWN - Bildgenerierung")
    print("   Using Imagen 3 Fast via Replicate API")
    print("=" * 60)
    
    # Load token
    token = load_token()
    if not token:
        print("❌ Kein Token gefunden!")
        return
    
    os.environ["REPLICATE_API_TOKEN"] = token
    print(f"   Token geladen: {token[:10]}...")
    
    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Check which images already exist
    existing = set(f.stem for f in OUTPUT_DIR.glob("*.png"))
    to_generate = [img for img in IMAGES if img["id"] not in existing]
    
    print(f"\n📊 Status:")
    print(f"   Gesamt: {len(IMAGES)} Bilder")
    print(f"   Bereits vorhanden: {len(existing)}")
    print(f"   Zu generieren: {len(to_generate)}")
    
    if not to_generate:
        print("\n✅ Alle Bilder bereits vorhanden!")
        return
    
    # Generate images
    success = 0
    failed = 0
    
    for i, img in enumerate(to_generate):
        print(f"\n{'=' * 40}")
        print(f"Bild {i+1}/{len(to_generate)}")
        print(f"{'=' * 40}")
        
        if generate_image(img, token):
            success += 1
        else:
            failed += 1
        
        # Delay to avoid rate limiting
        if i < len(to_generate) - 1:
            time.sleep(2)
    
    print("\n" + "=" * 60)
    print("✅ FERTIG!")
    print(f"   Erfolgreich: {success}")
    print(f"   Fehlgeschlagen: {failed}")
    print(f"   Ausgabe-Ordner: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()

