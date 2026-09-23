import sys

with open('lib/presentation/screens/checkout/checkout_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")

# 1. Fix line 1403 (index 1402)
for i in range(1395, 1415):
    if 'Wrap(' in lines[i]:
        print(f"Wrap found at {i+1}")
        # Look for children
        for j in range(i, i+5):
            if 'children: (isEn ?' in lines[j] and '.map' not in lines[j]:
                print(f"Fixing children at {j+1}")
                lines[j] = lines[j].rstrip('\r\n') + '.map((app) => Container(\n'
                break

# 2. Fix const Row at line 1869 (index 1868)
for i in range(1850, 1885):
    if 'const Row(' in lines[i] and any('Receipt Selected' in lines[k] for k in range(i, min(i+6, len(lines)))):
        print(f"Fixing const Row at {i+1}")
        lines[i] = lines[i].replace('const Row(', 'Row(')

# 3. Fix const Text at line 1904 (index 1903) and 1910 (index 1909)
for i in range(1895, 1925):
    if 'const Text(' in lines[i] and any('Click to select receipt' in lines[k] for k in range(i, min(i+4, len(lines)))):
        print(f"Fixing const Text (Click to select) at {i+1}")
        lines[i] = lines[i].replace('const Text(', 'Text(')
    if 'const Text(' in lines[i] and any('Max 5MB' in lines[k] for k in range(i, min(i+4, len(lines)))):
        print(f"Fixing const Text (Max 5MB) at {i+1}")
        lines[i] = lines[i].replace('const Text(', 'Text(')

with open('lib/presentation/screens/checkout/checkout_screen.dart', 'w', encoding='utf-8', newline='') as f:
    f.writelines(lines)

print("Done writing fixes")
