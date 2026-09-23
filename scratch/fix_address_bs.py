with open('lib/presentation/screens/checkout/checkout_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix _openAddressEditBottomSheet
content = content.replace(
"""  void _openAddressEditBottomSheet() {
    showModalBottomSheet(""",
"""  void _openAddressEditBottomSheet() {
    final isEn = context.read<LanguageProvider>().isEnglish;
    showModalBottomSheet("""
)

content = content.replace(
"""                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Color(0xFFFF2D78), size: 20),
                          SizedBox(width: 6),
                          Text(isEn ? 'Update Delivery Address' : 'ডেলিভারি ঠিকানা আপডেট করুন', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF101936))),
                        ],
                      ),""",
"""                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFFFF2D78), size: 20),
                          const SizedBox(width: 6),
                          Text(isEn ? 'Update Delivery Address' : 'ডেলিভারি ঠিকানা আপডেট করুন', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF101936))),
                        ],
                      ),"""
)

with open('lib/presentation/screens/checkout/checkout_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Address bottom sheet fixed")
