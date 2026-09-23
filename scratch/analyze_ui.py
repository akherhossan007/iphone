import re

def analyze_file(filepath, name):
    print(f"\n================ {name} ================")
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    print(f"Total characters: {len(content)}")
    
    # Find all major section headers or class names
    sections = re.findall(r'<section[^>]*class=["\']([^"\']+)["\']|<div[^>]*class=["\']([^"\']*(?:header|navbar|banner|slider|flash|hero|category|brand|usp|trust|coupon|voucher|product|tabs|feed|bottom|bar)[^"\']*)["\']', content, re.IGNORECASE)
    
    classes_seen = set()
    print("\nKey Sections / Container Classes found:")
    for s in sections:
        c = s[0] or s[1]
        for item in c.split():
            if item not in classes_seen and any(k in item.lower() for k in ['header', 'nav', 'bar', 'banner', 'flash', 'hero', 'brand', 'cat', 'feed', 'tab', 'trust', 'usp', 'card']):
                classes_seen.add(item)
                print(f" - {item}")

analyze_file('scratch/header-mobile.php', 'Mobile Header (header-mobile.php)')
analyze_file('scratch/mobile_home.php', 'Mobile Home (templates/mobile/home.php)')
