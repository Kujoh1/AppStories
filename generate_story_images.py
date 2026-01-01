#!/usr/bin/env python3
"""
Story Image Generator for Der Frankfurt-Komplex
Uses FLUX Schnell via Replicate API to generate all story images
"""

import replicate
import os
import requests
from pathlib import Path

# Image definitions with prompts
IMAGES = {
    "ffm_skyline_distorted": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, Frankfurt skyline at night viewed through a luxury club window, distorted glittering skyscrapers, neon cyan and magenta lights, atmospheric noir cityscape, wealth and distance perspective",
        "count": 1
    },
    "piano_blood_drop": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, extreme close-up of white piano key with single red blood drop, threatening shadow of father looming in blurred background, cold dramatic lighting, moment of lost humanity",
        "count": 1
    },
    "dead_bird_hand": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, child's hand holding lifeless bird, blurred garden of vacation house in background, clinical cold composition, no compassion only power, death as first lesson",
        "count": 1
    },
    "main_wache_underground": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, vast underground hall, broken blue subway tiles of Frankfurt Hauptwache station, mold covered walls, escalators leading to nowhere, defective fluorescent lights flickering, darkness dominates",
        "count": 1
    },
    "butcher_shadow": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, long menacing shadow on tiled tunnel wall, silhouette of deformed figure with pig mask and meat hook throwing sparks, three frightened figures ducking in foreground, the butcher hunter symbol",
        "count": 1
    },
    "ffm_office_mirror": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, modern Frankfurt office displaced underground, walls made of mirrors infinitely reflecting monitor lights, your portrait on wall with eyes scratched out, nightmare of glass and reflection, constant surveillance feeling",
        "count": 1
    },
    "wagner_family_memorial": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, collage style image showing Thomas smiling in front of his kiosk, Emma and Lena as children laughing, Main bridge in grim gray, newspaper clipping, everything overlaid with red guilty stamp, destruction of family visualized",
        "count": 1
    },
    "victims_file_wall": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, wall full of file folders and photos, Yilmaz family smiling in foreground, dozens more faces in black and white behind, each photo crossed out with red X, gallery of the eliminated, Ludwig's trembling finger pointing at evidence",
        "count": 1
    },
    "torn_portrait": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, torn painting in trash can, recognizable parts of young face, but light in eyes is ripped through, light blue diary with initials nearby, destruction of friendship and trust in single image",
        "count": 1
    },
    "muddy_drawing": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, childish stick figure drawing in mud, colorful crayons smudged, inscription barely readable, gravestones and black car blurred in background, innocence trampled by greed",
        "count": 1
    },
    "hospital_underground": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, sterile but neglected hospital corridor, medical equipment looking like torture instruments, thin film on tiled floor, IV stands with black viscous liquid, neon tubes humming, connection between pain healing and perpetrator's perverted game",
        "count": 1
    },
    "two_syringes": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, extreme close-up two syringes on metal table, one blue one red, both identical both deadly beautiful, Sarah's trembling hands approaching table blurred in background, ultimate choice between life and death",
        "count": 1
    },
    "rising_water_tunnel": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, flooded tunnel under Frankfurt, water chest-high black broth full of garbage, three silhouettes fighting against current, flickering emergency lighting on ceiling, water rising every moment, death by drowning slow cold unstoppable",
        "count": 1
    },
    "stock_exchange_underground": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, macabre version of Frankfurt stock exchange, courses show human lives guilt points survival probabilities, digital ticker boards on walls, cable strands on ceiling like veins, everything tradable even morality",
        "count": 1
    },
    "memory_corridor_pavement": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, wet Frankfurt cobblestones with reflections of neon and blue lights, surreal extended to endless corridor, past is not place but tunnel without exit",
        "count": 1
    },
    "main_tower_summit": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, breathtaking view over Frankfurt at night, lights of city like diamond carpet, but platform surrounded by high fence under electricity, no way down except elevator in middle, wind whipping, freedom or cage",
        "count": 1
    },
    "revolver_choice": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, hand holding revolver, Frankfurt skyline through railing blurred in background, Sarah on knees Marc standing arms crossed, red laser dots of robots, ultimate choice who dies, three people one bullet sixty seconds, visible timer counting down",
        "count": 1
    },
    "elias_sacrifice": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, aerial view silhouette on Main Tower platform surrounded by glittering skyline, body lying peacefully face to sky, city continues glowing indifferently, lonely death at highest point but with dignity",
        "count": 1
    },
    "falling_shadow": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, silhouette falling from Main Tower arms outstretched weightless between illuminated skyscrapers, two hundred meters to impact, city is indifferent, betrayal has its price paid in foreign blood",
        "count": 1
    },
    "ffm_ruins": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, Frankfurt city in ruins symbolic, image of destruction and hopelessness, nobody won in the end, dark apocalyptic mood",
        "count": 1
    },
    "ghosts_of_frankfurt": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, surreal overlay Frankfurt skyline in morning light overlaid by translucent ghosts, Thomas on bridge Lena at station Kristin with cleaning buckets Julian with torn painting Yilmaz family in front of burning restaurant, all looking at lonely figure at Main riverbank, city full of those he destroyed",
        "count": 1
    },
    "underground_living_room": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, improvised living room deep underground, old carpets stack of yellowed books small gas lamp, strangely cozy and absolutely insane at same time, survival in urban bowels",
        "count": 1
    },
    "underground_drones": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, small agile drones with searchlights racing through narrow tunnels, movements jerky and insect-like, emit cold blue light, scanning walls for warmth and movement",
        "count": 1
    },
    "identity_lab": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, high-tech laboratory underground, glass tanks filled with bluish liquid shadowy figures floating inside, light cold and sterile, shocking realization humans treated like data packets",
        "count": 1
    },
    "digital_twin": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, hologram of perfect Elias in suit facing real torn dirty Elias, two versions of same person ideal versus reality, digital self smiles coldly real self frozen in horror, worst nightmare is yourself",
        "count": 1
    },
    "fathers_study": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, perfect reconstruction of stately study, dark wood green leather chairs smell of old money and cigar smoke, oasis of wealth in middle of complex hell, father's portrait triumphant in front of Main Tower construction",
        "count": 1
    },
    "golden_ring": {
        "prompt": "retro comic art, sin city style, vermeide Buchstaben oder Zeichen, extreme close-up heavy golden signet ring in red velvet case, gold old worn dark spot on one edge dried blood from Elias childhood, edge that struck him, legacy of power and cruelty offered like poisoned gift",
        "count": 1
    }
}

def download_image(url: str, filepath: Path):
    """Download image from URL to filepath"""
    response = requests.get(url)
    response.raise_for_status()
    with open(filepath, 'wb') as f:
        f.write(response.content)
    print(f"✓ Saved: {filepath.name}")

def generate_all_images():
    """Generate all story images using Replicate API"""
    
    # Create output directory
    output_dir = Path("assets/img/story04")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("🎨 Starting image generation for Story 04: Der Frankfurt-Komplex")
    print(f"📁 Output directory: {output_dir}")
    print(f"🖼️  Total images to generate: {len(IMAGES)}\n")
    
    for i, (image_id, config) in enumerate(IMAGES.items(), 1):
        print(f"\n[{i}/{len(IMAGES)}] Generating: {image_id}")
        print(f"Prompt: {config['prompt'][:100]}...")
        
        try:
            # Run the model
            output = replicate.run(
                "black-forest-labs/flux-schnell",
                input={
                    "prompt": config['prompt'],
                    "go_fast": True,
                    "num_outputs": 1,
                    "aspect_ratio": "16:9",
                    "output_format": "png",
                    "output_quality": 90
                }
            )
            
            # Download the generated image
            if output and len(output) > 0:
                image_url = output[0]
                filepath = output_dir / f"{image_id}.png"
                download_image(image_url, filepath)
            else:
                print(f"✗ No output received for {image_id}")
                
        except Exception as e:
            print(f"✗ Error generating {image_id}: {e}")
            continue
    
    print(f"\n\n✅ Generation complete!")
    print(f"📊 Images saved to: {output_dir}")
    print(f"\n💡 Next steps:")
    print(f"   1. Review generated images in {output_dir}")
    print(f"   2. Update Story_04_assets.json with new image paths")
    print(f"   3. Test in the app!")

def load_api_token():
    """Load API token from .replicate_token file or environment variable"""
    
    # Try to load from file first
    token_file = Path(".replicate_token")
    if token_file.exists():
        with open(token_file, 'r') as f:
            for line in f:
                line = line.strip()
                # Skip comments and empty lines
                if line and not line.startswith('#'):
                    if line != "YOUR_TOKEN_HERE":
                        print(f"✓ Loaded API token from {token_file}")
                        return line
    
    # Fall back to environment variable
    token = os.environ.get("REPLICATE_API_TOKEN")
    if token:
        print("✓ Loaded API token from environment variable")
        return token
    
    # No token found
    print("❌ Error: No API token found!")
    print("\n🔑 To set your API token, do ONE of the following:")
    print("\n   Option 1 (Recommended):")
    print("   1. Open .replicate_token file")
    print("   2. Replace 'YOUR_TOKEN_HERE' with your actual token")
    print("   3. Save the file")
    print("\n   Option 2:")
    print("   export REPLICATE_API_TOKEN='your-token-here'")
    print("\n   Get your token at: https://replicate.com/account/api-tokens")
    return None

if __name__ == "__main__":
    # Load and set API token
    token = load_api_token()
    if not token:
        exit(1)
    
    # Set token for replicate library
    os.environ["REPLICATE_API_TOKEN"] = token
    
    generate_all_images()

