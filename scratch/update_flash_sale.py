with open('lib/presentation/screens/catalog/flash_sale_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Add import
if "import '../../../logic/language_provider.dart';" not in code:
    code = "import '../../../logic/language_provider.dart';\n" + code

# 2. Add isEn in build
old_build = """  @override
  Widget build(BuildContext context) {"""
new_build = """  @override
  Widget build(BuildContext context) {
    final isEn = context.watch<LanguageProvider>().isEnglish;"""
code = code.replace(old_build, new_build)

# 3. Tooltip home
code = code.replace("tooltip: 'হোম পেজ'", "tooltip: isEn ? 'Home' : 'হোম পেজ'")

# 4. _buildEmptyState
code = code.replace("_buildEmptyState(context)", "_buildEmptyState(context, isEn)")
code = code.replace("Widget _buildEmptyState(BuildContext context) {", "Widget _buildEmptyState(BuildContext context, bool isEn) {")
code = code.replace("'বর্তমানে কোনো ফ্ল্যাশ ডিল চালু নেই'", "isEn ? 'No Active Flash Deals Right Now' : 'বর্তমানে কোনো ফ্ল্যাশ ডিল চালু নেই'")
code = code.replace("""            const Text(
              'আমাদের পরবর্তী ফ্ল্যাশ সেল ক্যাম্পেইন শীঘ্রই শুরু হবে! স্পেশাল ডিসকাউন্ট ও আন্তর্জাতিক অথেনটিক পণ্য দেখতে আমাদের নিয়মিত ক্যাটালগ এক্সপ্লোর করুন।',""",
"""            Text(
              isEn ? 'Our next flash deal campaign is starting soon! Check our full catalog to explore authentic skincare products.' : 'আমাদের পরবর্তী ফ্ল্যাশ সেল ক্যাম্পেইন শীঘ্রই শুরু হবে! স্পেশাল ডিসকাউন্ট ও আন্তর্জাতিক অথেনটিক পণ্য দেখতে আমাদের নিয়মিত ক্যাটালগ এক্সপ্লোর করুন।',""")
code = code.replace("label: const Text('সকল পণ্য দেখুন'),", "label: Text(isEn ? 'Browse All Products' : 'সকল পণ্য দেখুন'),")

with open('lib/presentation/screens/catalog/flash_sale_screen.dart', 'w', encoding='utf-8', newline='') as f:
    f.write(code)

print("FlashSaleScreen updated successfully")
