#!/usr/bin/env python3
"""
Generate single image for Story 04
"""

import replicate
import os
import requests
from pathlib import Path

# Base style prompt
BASE_STYLE = "black and white with a subtle hint of red, high‑contrast comic‑noir, graphic novel aesthetics in the style of Sin City, strong inking, hard shadows, dramatic lighting, minimal grayscale shading."

# New image
IMAGE_ID = "awakening_bunker"
IMAGE_PROMPT = "view from dark concrete floor looking up through narrow light slit towards distorted Frankfurt skyline, skyline appears like mocking grin, prison atmosphere, first person perspective lying on ground, cold isolation, moment of awakening in hell, claustrophobic brutal awakening"

def download_image(url: str, filepath: Path):
    """Download image from URL to filepath"""
    response = requests.get(url)
    response.raise_for_status()
    with open(filepath, 'wb') as f:
        f.write(response.content)
    print(f"✓ Saved: {filepath.name}")

def generate_image():
    """Generate single image using Replicate API"""
    
    output_dir = Path("assets/img")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("🎨 Generating new image: awakening_bunker")
    print(f"🤖 Model: Google Imagen-3-Fast")
    print(f"🎭 Style: Sin City Comic-Noir\n")
    
    # Combine base style with specific prompt
    full_prompt = f"{BASE_STYLE} {IMAGE_PROMPT}"
    print(f"Prompt: {full_prompt}\n")
    
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
        if output:
            image_url = str(output)
            filepath = output_dir / f"{IMAGE_ID}.png"
            download_image(image_url, filepath)
            print(f"\n✅ Generation complete!")
            print(f"📊 Image saved to: {filepath}")
        else:
            print(f"✗ No output received")
            
    except Exception as e:
        print(f"✗ Error generating image: {e}")

def load_api_token():
    """Load API token from .replicate_token file or environment variable"""
    
    token_file = Path(".replicate_token")
    if token_file.exists():
        with open(token_file, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    if line != "YOUR_TOKEN_HERE":
                        print(f"✓ Loaded API token from {token_file}\n")
                        return line
    
    token = os.environ.get("REPLICATE_API_TOKEN")
    if token:
        print("✓ Loaded API token from environment variable\n")
        return token
    
    print("❌ Error: No API token found!")
    return None

if __name__ == "__main__":
    token = load_api_token()
    if not token:
        exit(1)
    
    os.environ["REPLICATE_API_TOKEN"] = token
    generate_image()


