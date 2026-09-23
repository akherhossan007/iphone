with open('scratch/mobile_home.php', 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Find all HTML sections and their headings / key elements
import re

print("File length:", len(content))

# Look for section tags and major div wrappers
sections = re.findall(r'(<(?:section|div)[^>]+class=["\'][^"\']*(?:gbm-|gb-|hero|flash|concern|channel|bento|brand|tabs|card)[^"\']*["\'][^>]*>)', content)
print(f"Found {len(sections)} major container tags.")
for s in sections[:40]:
    print(s[:120])
