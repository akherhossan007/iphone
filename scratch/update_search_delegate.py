with open('lib/presentation/screens/catalog/smart_search_delegate.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Replace class definition
old_header = """class SmartSearchDelegate extends SearchDelegate<void> {
  static const List<String> _trendingTerms = [
    'CeraVe',
    'Anua',
    'Sunscreen',
    'Retinol',
    'Niacinamide',
    'Centella',
    'Cetaphil',
    'Torriden',
  ];

  @override
  String get searchFieldLabel => 'Search 100% authentic skincare, brands...';

  @override
  String? get searchFieldLabel => (isEnglishOverride ?? true) ? 'Search authentic skincare, brands...' : 'অথেনটিক স্কিনকেয়ার বা ব্র্যান্ড খুঁজুন...';"""

new_header = """class SmartSearchDelegate extends SearchDelegate<void> {
  final bool? isEnglishOverride;

  SmartSearchDelegate({this.isEnglishOverride});

  bool _isEn(BuildContext context) => isEnglishOverride ?? context.read<LanguageProvider>().isEnglish;

  static const List<String> _trendingTerms = [
    'CeraVe',
    'Anua',
    'Sunscreen',
    'Retinol',
    'Niacinamide',
    'Centella',
    'Cetaphil',
    'Torriden',
  ];

  @override
  String get searchFieldLabel => (isEnglishOverride ?? true) ? 'Search authentic skincare, brands...' : 'অথেনটিক স্কিনকেয়ার বা ব্র্যান্ড খুঁজুন...';"""

code = code.replace(old_header, new_header)

# Fix const Row in zero state
old_row1 = """                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic_rounded, color: Color(0xFFE11D48), size: 18),
                        SizedBox(width: 6),
                        Text(
                          (context.watch<LanguageProvider>().isEnglish) ? 'Voice Search' : 'ভয়েস সার্চ',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),"""

new_row1 = """                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mic_rounded, color: Color(0xFFE11D48), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          (context.watch<LanguageProvider>().isEnglish) ? 'Voice Search' : 'ভয়েস সার্চ',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),"""

old_row2 = """                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB), size: 18),
                        SizedBox(width: 6),
                        Text(
                          (context.watch<LanguageProvider>().isEnglish) ? 'Visual Search' : 'ছবি দিয়ে সার্চ',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),"""

new_row2 = """                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          (context.watch<LanguageProvider>().isEnglish) ? 'Visual Search' : 'ছবি দিয়ে সার্চ',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),"""

code = code.replace(old_row1, new_row1)
code = code.replace(old_row2, new_row2)

with open('lib/presentation/screens/catalog/smart_search_delegate.dart', 'w', encoding='utf-8', newline='') as f:
    f.write(code)

print("SmartSearchDelegate clean fix done")
