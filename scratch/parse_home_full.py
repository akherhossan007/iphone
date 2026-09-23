import re
import sys

# Ensure stdout handles emojis
sys.stdout.reconfigure(encoding='utf-8')

with open('scratch/mobile_home.php', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

sections = re.split(r'<section\s+', text)[1:]

print(f"Total sections: {len(sections)}")

for i, s in enumerate(sections):
    sec_content = '<section ' + s
    m_cls = re.search(r'class=["\']([^"\']+)["\']', sec_content)
    cls_name = m_cls.group(1) if m_cls else "no-class"
    
    headings = re.findall(r'<(?:h1|h2|h3|h4|span|div)[^>]*class=["\'][^"\']*(?:title|heading|sec-h|name)[^"\']*["\'][^>]*>(.*?)</', sec_content, re.DOTALL)
    clean_h = [re.sub(r'<[^>]+>', '', h).strip() for h in headings if len(h.strip()) > 0 and len(h.strip()) < 100]
    
    raw_texts = re.findall(r'>([^<]{3,60})<', sec_content)
    clean_texts = [t.strip() for t in raw_texts if t.strip() and not t.strip().startswith('{') and not t.strip().startswith('$')][:6]
    
    print(f"\n--- Section {i+1} [class: {cls_name}] ---")
    if clean_h:
        print(f"  Headings: {clean_h[:3]}")
    print(f"  Snippets: {clean_texts[:5]}")
