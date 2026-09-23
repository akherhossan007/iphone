with open('scratch/header-mobile.php', 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

body_start = 1845
header_chunk = "".join(lines[body_start + 300:body_start + 600])
print("--- LINES 300-600 OF BODY IN HEADER-MOBILE.PHP ---")
print(header_chunk)
