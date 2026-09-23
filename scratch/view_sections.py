import re

with open('scratch/mobile_home.php', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

# Let's inspect sections 2, 12, 15, 16, 17, 18, 21
sections = re.split(r'<section\s+', text)[1:]

for num in [2, 12, 15, 16, 17, 18, 21]:
    if num - 1 < len(sections):
        s = sections[num - 1]
        print(f"\n================ SECTION {num} ================")
        print(s[:900])
