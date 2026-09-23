with open('lib/presentation/screens/subpages/address_book_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Add import
if "import '../../../logic/language_provider.dart';" not in code:
    code = "import '../../../logic/language_provider.dart';\n" + code

# 2. _confirmDeleteAddress
old_delete_dialog = """  void _confirmDeleteAddress(Map<String, dynamic> addr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 8),
            Text('ঠিকানা মুছে ফেলবেন?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Text('আপনি কি নিশ্চিত যে "${addr['full_name']}"-এর এই ডেলিভারি ঠিকানাটি স্থায়ীভাবে মুছে ফেলতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _addresses.removeWhere((a) => a['id'] == addr['id']);
                if (_addresses.isNotEmpty && addr['is_default'] == true) {
                  _addresses.first['is_default'] = true;
                }
              });
              await _persistAddresses();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ ডেলিভারি ঠিকানা সফলভাবে মুছে ফেলা হয়েছে!'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('মুছে ফেলুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }"""

new_delete_dialog = """  void _confirmDeleteAddress(Map<String, dynamic> addr) {
    final isEn = context.read<LanguageProvider>().isEnglish;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            Text(isEn ? 'Delete Address?' : 'ঠিকানা মুছে ফেলবেন?', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Text(isEn
            ? 'Are you sure you want to permanently delete this delivery address for "${addr['full_name']}"?'
            : 'আপনি কি নিশ্চিত যে "${addr['full_name']}"-এর এই ডেলিভারি ঠিকানাটি স্থায়ীভাবে মুছে ফেলতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'Cancel' : 'বাতিল', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _addresses.removeWhere((a) => a['id'] == addr['id']);
                if (_addresses.isNotEmpty && addr['is_default'] == true) {
                  _addresses.first['is_default'] = true;
                }
              });
              await _persistAddresses();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEn ? '✓ Delivery address deleted successfully!' : '✓ ডেলিভারি ঠিকানা সফলভাবে মুছে ফেলা হয়েছে!'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isEn ? 'Delete' : 'মুছে ফেলুন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }"""
code = code.replace(old_delete_dialog, new_delete_dialog)

# 3. _openAddAddressModal
old_modal_start = """  void _openAddAddressModal([Map<String, dynamic>? editItem]) {
    final formKey = GlobalKey<FormState>();"""
new_modal_start = """  void _openAddAddressModal([Map<String, dynamic>? editItem]) {
    final isEn = context.read<LanguageProvider>().isEnglish;
    final formKey = GlobalKey<FormState>();"""
code = code.replace(old_modal_start, new_modal_start)

code = code.replace("editItem == null ? 'নতুন ডেলিভারি ঠিকানা যোগ করুন' : 'ঠিকানা পরিবর্তন করুন',",
                    "editItem == null ? (isEn ? 'Add New Delivery Address' : 'নতুন ডেলিভারি ঠিকানা যোগ করুন') : (isEn ? 'Edit Delivery Address' : 'ঠিকানা পরিবর্তন করুন'),")

code = code.replace("_buildInputLabel('গ্রাহকের পূর্ণ নাম (Full Name) *'),",
                    "_buildInputLabel(isEn ? 'Customer Full Name *' : 'গ্রাহকের পূর্ণ নাম (Full Name) *'),")
code = code.replace("_inputDeco('আপনার পূর্ণ নাম লিখুন', Icons.person_outline),",
                    "_inputDeco(isEn ? 'Enter full name' : 'আপনার পূর্ণ নাম লিখুন', Icons.person_outline),")
code = code.replace("validator: (v) => (v == null || v.trim().isEmpty) ? 'পূর্ণ নাম বাধ্যতামূলক *' : null,",
                    "validator: (v) => (v == null || v.trim().isEmpty) ? (isEn ? 'Full name is required *' : 'পূর্ণ নাম বাধ্যতামূলক *') : null,")

code = code.replace("_buildInputLabel('সচল মোবাইল নম্বর *'),",
                    "_buildInputLabel(isEn ? 'Active Mobile Number *' : 'সচল মোবাইল নম্বর *'),")
code = code.replace("_buildInputLabel('হোয়াটসঅ্যাপ নম্বর *'),",
                    "_buildInputLabel(isEn ? 'WhatsApp Number *' : 'হোয়াটসঅ্যাপ নম্বর *'),")
code = code.replace("validator: (v) => (v == null || v.trim().length < 11) ? '১১ ডিজিট বাধ্যতামূলক *' : null,",
                    "validator: (v) => (v == null || v.trim().length < 11) ? (isEn ? '11 digits required *' : '১১ ডিজিট বাধ্যতামূলক *') : null,")

code = code.replace("_buildInputLabel('বিল্ডিং / ফ্ল্যাট নম্বর *'),",
                    "_buildInputLabel(isEn ? 'Building / Flat No. *' : 'বিল্ডিং / ফ্ল্যাট নম্বর *'),")
code = code.replace("validator: (v) => (v == null || v.trim().isEmpty) ? 'বিল্ডিং বাধ্যতামূলক *' : null,",
                    "validator: (v) => (v == null || v.trim().isEmpty) ? (isEn ? 'Building required *' : 'বিল্ডিং বাধ্যতামূলক *') : null,")

code = code.replace("_buildInputLabel('রোড / ব্লক / সেক্টর *'),",
                    "_buildInputLabel(isEn ? 'Road / Block / Sector *' : 'রোড / ব্লক / সেক্টর *'),")
code = code.replace("validator: (v) => (v == null || v.trim().isEmpty) ? 'রোড বাধ্যতামূলক *' : null,",
                    "validator: (v) => (v == null || v.trim().isEmpty) ? (isEn ? 'Road required *' : 'রোড বাধ্যতামূলক *') : null,")

code = code.replace("_buildInputLabel('এলাকা / মহল্লা * (যেমন: Dhanmondi / Mirpur)'),",
                    "_buildInputLabel(isEn ? 'Area / Landmark * (e.g. Dhanmondi / Mirpur)' : 'এলাকা / মহল্লা * (যেমন: Dhanmondi / Mirpur)'),")

code = code.replace("content: Text('✓ ডেলিভারি ঠিকানা সফলভাবে সংরক্ষণ করা হয়েছে!'),",
                    "content: Text(isEn ? '✓ Delivery address saved successfully!' : '✓ ডেলিভারি ঠিকানা সফলভাবে সংরক্ষণ করা হয়েছে!'),")
code = code.replace("child: const Text('ঠিকানা সংরক্ষণ ও নিশ্চিত করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5)),",
                    "child: Text(isEn ? 'Save & Confirm Address' : 'ঠিকানা সংরক্ষণ ও নিশ্চিত করুন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5)),")

# 4. AppBar and screen body
old_appbar = """  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Address Book', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 22, color: Color(0xFF0F172A)),
            tooltip: 'হোম পেজ',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _openAddAddressModal(),
            tooltip: 'নতুন ঠিকানা',
          ),
        ],
      ),"""

new_appbar = """  @override
  Widget build(BuildContext context) {
    final isEn = context.watch<LanguageProvider>().isEnglish;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEn ? 'Saved Address Book' : 'সংরক্ষিত ঠিকানা', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 22, color: Color(0xFF0F172A)),
            tooltip: isEn ? 'Home' : 'হোম পেজ',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _openAddAddressModal(),
            tooltip: isEn ? 'New Address' : 'নতুন ঠিকানা',
          ),
        ],
      ),"""
code = code.replace(old_appbar, new_appbar)

# Empty state
code = code.replace("""                        const Text(
                          'কোনো সংরক্ষিত ঠিকানা নেই',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'নতুন ডেলিভারি ঠিকানা যোগ করতে নিচের বাটনে চাপুন',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),""",
"""                        Text(
                          isEn ? 'No Saved Addresses' : 'কোনো সংরক্ষিত ঠিকানা নেই',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEn ? 'Tap below to add a new delivery address' : 'নতুন ডেলিভারি ঠিকানা যোগ করতে নিচের বাটনে চাপুন',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),""")

code = code.replace("label: const Text('ঠিকানা যোগ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),",
                    "label: Text(isEn ? 'Add Address' : 'ঠিকানা যোগ করুন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),")

# Card buttons
code = code.replace("label: const Text('মুছে ফেলুন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.error)),",
                    "label: Text(isEn ? 'Delete' : 'মুছে ফেলুন', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.error)),")
code = code.replace("label: const Text('এডিট', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),",
                    "label: Text(isEn ? 'Edit' : 'এডিট', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),")
code = code.replace("label: Text(addr['is_default'] == true ? 'ডিফল্ট' : 'ডিফল্ট করুন', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),",
                    "label: Text(addr['is_default'] == true ? (isEn ? 'Default' : 'ডিফল্ট') : (isEn ? 'Set Default' : 'ডিফল্ট করুন'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),")
code = code.replace("label: const Text('+ নতুন ডেলিভারি ঠিকানা যোগ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),",
                    "label: Text(isEn ? '+ Add New Delivery Address' : '+ নতুন ডেলিভারি ঠিকানা যোগ করুন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),")

with open('lib/presentation/screens/subpages/address_book_screen.dart', 'w', encoding='utf-8', newline='') as f:
    f.write(code)

print("AddressBookScreen updated successfully")
