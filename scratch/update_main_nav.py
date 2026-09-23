with open('lib/presentation/screens/main_nav_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Add import
if "import '../../logic/language_provider.dart';" not in code:
    code = "import '../../logic/language_provider.dart';\n" + code

# 2. Update _openVisualSearch
old_open_vs = """  void _openVisualSearch() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ভিজ্যুয়াল স্কিনকেয়ার সার্চ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'ছবি তুলে বা গ্যালারি থেকে যেকোনো বিউটি প্রোডাক্ট খুঁজুন',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),"""

new_open_vs = """  void _openVisualSearch() {
    final isEn = context.read<LanguageProvider>().isEnglish;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEn ? 'Visual Skincare Search' : 'ভিজ্যুয়াল স্কিনকেয়ার সার্চ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEn ? 'Search any beauty product by taking a photo or from gallery' : 'ছবি তুলে বা গ্যালারি থেকে যেকোনো বিউটি প্রোডাক্ট খুঁজুন',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),"""
code = code.replace(old_open_vs, new_open_vs)

code = code.replace("""                            const Text(
                              'ছবি তুলুন',""", """                            Text(
                              isEn ? 'Take Photo' : 'ছবি তুলুন',""")

code = code.replace("""                            const Text(
                              'গ্যালারি থেকে নিন',""", """                            Text(
                              isEn ? 'From Gallery' : 'গ্যালারি থেকে নিন',""")

# 3. Bottom nav items dynamic label
old_bnav = """            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bolt_outlined),
                activeIcon: Icon(Icons.bolt),
                label: 'Flash Deals',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.verified_outlined),
                activeIcon: Icon(Icons.verified),
                label: 'Brands',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping_outlined),
                activeIcon: Icon(Icons.local_shipping),
                label: 'Track Order',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Account',
              ),
            ],"""

new_bnav = """            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: context.watch<LanguageProvider>().isEnglish ? 'Home' : 'হোম',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bolt_outlined),
                activeIcon: const Icon(Icons.bolt),
                label: context.watch<LanguageProvider>().isEnglish ? 'Flash Deals' : 'ফ্ল্যাশ ডিল',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.verified_outlined),
                activeIcon: const Icon(Icons.verified),
                label: context.watch<LanguageProvider>().isEnglish ? 'Brands' : 'ব্র্যান্ড',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.local_shipping_outlined),
                activeIcon: const Icon(Icons.local_shipping),
                label: context.watch<LanguageProvider>().isEnglish ? 'Track Order' : 'ট্র্যাকিং',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: context.watch<LanguageProvider>().isEnglish ? 'Account' : 'অ্যাকাউন্ট',
              ),
            ],"""
code = code.replace(old_bnav, new_bnav)

with open('lib/presentation/screens/main_nav_screen.dart', 'w', encoding='utf-8', newline='') as f:
    f.write(code)

print("MainNavScreen updated successfully")
