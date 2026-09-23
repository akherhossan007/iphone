import re

with open('scratch/mobile_home.php', 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Let's find all headings (h1, h2, h3, h4, titles) and major sections
matches = re.findall(r'(<section[^>]*>.*?)(?=<section|\Z)', content, re.DOTALL)
print(f"Total <section> tags found: {len(matches)}")
for i, m in enumerate(matches):
    first_line = m.strip().split('\n')[0][:120]
    titles = re.findall(r'<(?:h2|h3|h4|span|div)[^>]*class=["\'][^"\']*(?:title|heading|sec-h|name)[^"\']*["\'][^>]*>(.*?)</', m, re.DOTALL)
    clean_titles = [re.sub(r'<[^>]+>', '', t).strip() for t in titles if len(t.strip()) > 0 and len(t.strip()) < 80]
    print(f"\nSection {i+1}: {first_line}")
    if clean_titles:
        print(f"  Titles/Headers: {clean_titles[:5]}")
