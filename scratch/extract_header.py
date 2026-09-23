import re

with open('scratch/header-mobile.php', 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

body_start = -1
for i, line in enumerate(lines):
    if '<body' in line:
        body_start = i
        break

print(f"Body starts at line {body_start + 1}")
if body_start != -1:
    header_chunk = "".join(lines[body_start:body_start + 300])
    print("\n--- FIRST 300 LINES OF BODY IN HEADER-MOBILE.PHP ---")
    print(header_chunk)
