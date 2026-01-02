#!/usr/bin/env python3
"""Replace German quotes with Guillemets (» «)"""

import os

def analyze_quotes(filepath):
    """Analyze what quote characters are in the file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print(f'\n{os.path.basename(filepath)} - Quote Analysis:')
    
    # Check for various quote characters by Unicode code point
    quote_chars = [
        ('\u00BB', 'U+00BB Guillemet right'),
        ('\u00AB', 'U+00AB Guillemet left'),
        ('\u201E', 'U+201E German opening'),
        ('\u201C', 'U+201C Left double'),
        ('\u201D', 'U+201D Right double'),
        ('\u0022', 'U+0022 ASCII double'),
        ('\u2018', 'U+2018 Left single'),
        ('\u2019', 'U+2019 Right single'),
    ]
    
    for char, name in quote_chars:
        count = content.count(char)
        if count > 0:
            print(f'  {name}: {count}')
    
    return content

def fix_quotes(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # In German typography:
    # „ (U+201E) = opening quote
    # " (U+201C) = closing quote (NOT opening!)
    # " (U+201D) = also closing quote
    
    # Replace opening quotes with » (U+00BB)
    content = content.replace('\u201E', '\u00BB')  # German opening „ -> »
    
    # Replace closing quotes with « (U+00AB)
    content = content.replace('\u201C', '\u00AB')  # Left double " -> « (closing in German!)
    content = content.replace('\u201D', '\u00AB')  # Right double " -> «
    
    # Handle ASCII quotes (U+0022) - interpret based on context
    # If we're after a » and haven't seen a « yet, this is closing
    result = []
    in_quote = False
    for char in content:
        if char == '\u00BB':  # Opening guillemet
            in_quote = True
            result.append(char)
        elif char == '\u00AB':  # Closing guillemet
            in_quote = False
            result.append(char)
        elif char == '\u0022':  # ASCII quote
            if in_quote:
                result.append('\u00AB')  # Treat as closing
                in_quote = False
            else:
                result.append('\u00BB')  # Treat as opening
                in_quote = True
        else:
            result.append(char)
    
    content = ''.join(result)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f'\n{os.path.basename(filepath)} - After fix:')
    print(f'  » count: {content.count(chr(0x00BB))}')
    print(f'  « count: {content.count(chr(0x00AB))}')
    print(f'  Changes made: {content != original}')

# Analyze first
analyze_quotes('assets/stories/ink/Story_04.md')

# Fix both story files
fix_quotes('assets/stories/ink/Story_04.md')
fix_quotes('assets/stories/ink/Story_05_final.md')

