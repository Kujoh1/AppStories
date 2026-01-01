#!/usr/bin/env python3
"""
Story Image Generator for Der Frankfurt-Komplex
Uses Imagen-3-Fast via Replicate API to generate all story images
"""

import replicate
import os
import requests
from pathlib import Path

# Base style prompt for all images
BASE_STYLE = "black and white with a subtle hint of red, high‑contrast comic‑noir, graphic novel aesthetics in the style of Sin City, strong inking, hard shadows, dramatic lighting, minimal grayscale shading."

# Image definitions with prompts
IMAGES = {
    "ffm_skyline_distorted": {
        "prompt": "Frankfurt skyline at night viewed through a luxury club window, distorted glittering skyscrapers, neon cyan and magenta lights, atmospheric noir cityscape, wealth and distance perspective",
        "count": 1
    },
    "piano_blood_drop": {
        "prompt": "extreme close-up of white piano key with single red blood drop, threatening shadow of father looming in blurred background, cold dramatic lighting, moment of lost humanity",
        "count": 1
    },
    "dead_bird_hand": {
        "prompt": "child's hand holding lifeless bird, blurred garden of vacation house in background, clinical cold composition, no compassion only power, death as first lesson",
        "count": 1
    },
    "main_wache_underground": {
        "prompt": "vast underground hall, broken blue subway tiles of Frankfurt Hauptwache station, mold covered walls, escalators leading to nowhere, defective fluorescent lights flickering, darkness dominates",
        "count": 1
    },
    "butcher_shadow": {
        "prompt": "long menacing shadow on tiled tunnel wall, silhouette of deformed figure with pig mask and meat hook throwing sparks, three frightened figures ducking in foreground, the butcher hunter symbol",
        "count": 1
    },
    "ffm_office_mirror": {
        "prompt": "modern Frankfurt office displaced underground, walls made of mirrors infinitely reflecting monitor lights, portrait on wall with eyes scratched out, nightmare of glass and reflection, constant surveillance feeling",
        "count": 1
    },
    "wagner_family_memorial": {
        "prompt": "collage style image showing man smiling in front of his kiosk, two children laughing, bridge in grim gray, newspaper clipping, everything overlaid with red guilty stamp, destruction of family visualized",
        "count": 1
    },
    "victims_file_wall": {
        "prompt": "wall full of file folders and photos, family smiling in foreground, dozens more faces behind, each photo crossed out with red X, gallery of the eliminated, trembling finger pointing at evidence",
        "count": 1
    },
    "torn_portrait": {
        "prompt": "torn painting in trash can, recognizable parts of young face, but light in eyes is ripped through, light blue diary with initials nearby, destruction of friendship and trust in single image",
        "count": 1
    },
    "muddy_drawing": {
        "prompt": "childish stick figure drawing in mud, colorful crayons smudged, inscription barely readable, gravestones and black car blurred in background, innocence trampled by greed",
        "count": 1
    },
    "hospital_underground": {
        "prompt": "sterile but neglected hospital corridor, medical equipment looking like torture instruments, thin film on tiled floor, IV stands with black viscous liquid, neon tubes humming, connection between pain healing and perpetrator's perverted game",
        "count": 1
    },
    "two_syringes": {
        "prompt": "extreme close-up two syringes on metal table, one blue one red, both identical both deadly beautiful, trembling hands approaching table blurred in background, ultimate choice between life and death",
        "count": 1
    },
    "rising_water_tunnel": {
        "prompt": "flooded tunnel, water chest-high black broth full of garbage, three silhouettes fighting against current, flickering emergency lighting on ceiling, water rising every moment, death by drowning slow cold unstoppable",
        "count": 1
    },
    "stock_exchange_underground": {
        "prompt": "macabre version of Frankfurt stock exchange, courses show human lives guilt points survival probabilities, digital ticker boards on walls, cable strands on ceiling like veins, everything tradable even morality",
        "count": 1
    },
    "memory_corridor_pavement": {
        "prompt": "wet Frankfurt cobblestones with reflections of neon and blue lights, surreal extended to endless corridor, past is not place but tunnel without exit",
        "count": 1
    },
    "main_tower_summit": {
        "prompt": "breathtaking view over Frankfurt at night, lights of city like diamond carpet, but platform surrounded by high fence under electricity, no way down except elevator in middle, wind whipping, freedom or cage",
        "count": 1
    },
    "revolver_choice": {
        "prompt": "hand holding revolver, Frankfurt skyline through railing blurred in background, woman on knees man standing arms crossed, red laser dots of robots, ultimate choice who dies, three people one bullet sixty seconds, visible timer counting down",
        "count": 1
    },
    "elias_sacrifice": {
        "prompt": "aerial view silhouette on tower platform surrounded by glittering skyline, body lying peacefully face to sky, city continues glowing indifferently, lonely death at highest point but with dignity",
        "count": 1
    },
    "falling_shadow": {
        "prompt": "silhouette falling from tower arms outstretched weightless between illuminated skyscrapers, two hundred meters to impact, city is indifferent, betrayal has its price paid in foreign blood",
        "count": 1
    },
    "ffm_ruins": {
        "prompt": "Frankfurt city in ruins symbolic, image of destruction and hopelessness, nobody won in the end, dark apocalyptic mood",
        "count": 1
    },
    "ghosts_of_frankfurt": {
        "prompt": "surreal overlay Frankfurt skyline in morning light overlaid by translucent ghosts, people on bridge at station with cleaning buckets with torn painting family in front of burning restaurant, all looking at lonely figure at river bank, city full of those he destroyed",
        "count": 1
    },
    "underground_living_room": {
        "prompt": "improvised living room deep underground, old carpets stack of yellowed books small gas lamp, strangely cozy and absolutely insane at same time, survival in urban bowels",
        "count": 1
    },
    "underground_drones": {
        "prompt": "small agile drones with searchlights racing through narrow tunnels, movements jerky and insect-like, emit cold blue light, scanning walls for warmth and movement",
        "count": 1
    },
    "identity_lab": {
        "prompt": "high-tech laboratory underground, glass tanks filled with bluish liquid shadowy figures floating inside, light cold and sterile, shocking realization humans treated like data packets",
        "count": 1
    },
    "digital_twin": {
        "prompt": "hologram of perfect businessman in suit facing real torn dirty man, two versions of same person ideal versus reality, digital self smiles coldly real self frozen in horror, worst nightmare is yourself",
        "count": 1
    },
    "fathers_study": {
        "prompt": "perfect reconstruction of stately study, dark wood green leather chairs smell of old money and cigar smoke, oasis of wealth in middle of complex hell, portrait triumphant in front of tower construction",
        "count": 1
    },
    "golden_ring": {
        "prompt": "extreme close-up heavy golden signet ring in red velvet case, gold old worn dark spot on one edge dried blood, edge that struck someone, legacy of power and cruelty offered like poisoned gift",
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
    
    # Create output directory (directly in assets/img/)
    output_dir = Path("assets/img")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("🎨 Starting image generation for Story 04: Der Frankfurt-Komplex")
    print(f"🤖 Model: Google Imagen-3-Fast")
    print(f"🎭 Style: Sin City Comic-Noir")
    print(f"📁 Output directory: {output_dir}")
    print(f"🖼️  Total images to generate: {len(IMAGES)}\n")
    
    for i, (image_id, config) in enumerate(IMAGES.items(), 1):
        print(f"\n[{i}/{len(IMAGES)}] Generating: {image_id}")
        
        # Combine base style with specific prompt
        full_prompt = f"{BASE_STYLE} {config['prompt']}"
        print(f"Prompt: {full_prompt[:120]}...")
        
        try:
            # Run the Imagen-3-Fast model
            output = replicate.run(
                "google/imagen-3-fast",
                input={
                    "prompt": full_prompt,
                    "aspect_ratio": "16:9",
                    "output_format": "png"
                }
            )
            
            # Download the generated image
            # Imagen output is a URL string
            if output:
                image_url = str(output)
                filepath = output_dir / f"{image_id}.png"
                download_image(image_url, filepath)
            else:
                print(f"✗ No output received for {image_id}")
                
        except Exception as e:
            print(f"✗ Error generating {image_id}: {e}")
            continue
    
    print(f"\n\n✅ Generation complete!")
    print(f"📊 Images saved to: {output_dir}")
    print(f"\n💡 All images are now in Sin City style:")
    print(f"   - Black and white with subtle red accents")
    print(f"   - High-contrast comic-noir aesthetic")
    print(f"   - Strong inking and hard shadows")
    print(f"\n🚀 Ready to test in the app!")

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


