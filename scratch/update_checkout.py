import re

file_path = 'lib/presentation/screens/checkout/checkout_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add import
if "import '../../../logic/language_provider.dart';" not in content:
    content = content.replace(
        "import '../../../logic/order_provider.dart';",
        "import '../../../logic/order_provider.dart';\nimport '../../../logic/language_provider.dart';"
    )

# 2. Update _getEstimatedDeliveryRange to accept [bool isEn = false]
old_delivery_fn = """  // Calculate 10 to 25 Days Estimated Delivery Range in Bengali (Matching checkout_mobile_final.php)
  String _getEstimatedDeliveryRange() {
    final start = DateTime.now().add(const Duration(days: 10));
    final end = DateTime.now().add(const Duration(days: 25));
    const bnMonths = {
      1: 'জানুয়ারি', 2: 'ফেব্রুয়ারি', 3: 'মার্চ', 4: 'এপ্রিল',
      5: 'মে', 6: 'জুন', 7: 'জুলাই', 8: 'আগস্ট',
      9: 'সেপ্টেম্বর', 10: 'অক্টোবর', 11: 'নভেম্বর', 12: 'ডিসেম্বর'
    };
    const bnDigits = {
      '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
      '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯'
    };

    String toBn(int val) => val.toString().split('').map((c) => bnDigits[c] ?? c).join();

    final m1 = bnMonths[start.month] ?? '';
    final m2 = bnMonths[end.month] ?? '';
    final d1 = toBn(start.day);
    final d2 = toBn(end.day);

    return (m1 == m2) ? '$d1 – $d2 $m1' : '$d1 $m1 – $d2 $m2';
  }"""

new_delivery_fn = """  // Calculate 10 to 25 Days Estimated Delivery Range (Bilingual: English / Bengali)
  String _getEstimatedDeliveryRange([bool isEn = false]) {
    final start = DateTime.now().add(const Duration(days: 10));
    final end = DateTime.now().add(const Duration(days: 25));
    if (isEn) {
      const enMonths = {
        1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr',
        5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug',
        9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
      };
      final m1 = enMonths[start.month] ?? '';
      final m2 = enMonths[end.month] ?? '';
      final d1 = start.day.toString();
      final d2 = end.day.toString();
      return (m1 == m2) ? '$d1 – $d2 $m1' : '$d1 $m1 – $d2 $m2';
    }
    const bnMonths = {
      1: 'জানুয়ারি', 2: 'ফেব্রুয়ারি', 3: 'মার্চ', 4: 'এপ্রিল',
      5: 'মে', 6: 'জুন', 7: 'জুলাই', 8: 'আগস্ট',
      9: 'সেপ্টেম্বর', 10: 'অক্টোবর', 11: 'নভেম্বর', 12: 'ডিসেম্বর'
    };
    const bnDigits = {
      '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
      '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯'
    };

    String toBn(int val) => val.toString().split('').map((c) => bnDigits[c] ?? c).join();

    final m1 = bnMonths[start.month] ?? '';
    final m2 = bnMonths[end.month] ?? '';
    final d1 = toBn(start.day);
    final d2 = toBn(end.day);

    return (m1 == m2) ? '$d1 – $d2 $m1' : '$d1 $m1 – $d2 $m2';
  }"""

content = content.replace(old_delivery_fn, new_delivery_fn)

# 3. Update _showImagePickerModal
old_image_picker = """  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'পেমেন্ট স্লিপ / রিসিট আপলোড করুন',
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF101936)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMediaOption(Icons.camera_alt, 'ক্যামেরা (Camera)', () {
                    Navigator.pop(ctx);
                    _pickReceiptImage(ImageSource.camera);
                  }),
                  _buildMediaOption(Icons.photo_library, 'গ্যালারি (Gallery)', () {
                    Navigator.pop(ctx);
                    _pickReceiptImage(ImageSource.gallery);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }"""

new_image_picker = """  void _showImagePickerModal() {
    final isEn = context.read<LanguageProvider>().isEnglish;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEn ? 'Upload Payment Slip / Receipt' : 'পেমেন্ট স্লিপ / রিসিট আপলোড করুন',
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF101936)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMediaOption(Icons.camera_alt, isEn ? 'Camera' : 'ক্যামেরা (Camera)', () {
                    Navigator.pop(ctx);
                    _pickReceiptImage(ImageSource.camera);
                  }),
                  _buildMediaOption(Icons.photo_library, isEn ? 'Gallery' : 'গ্যালারি (Gallery)', () {
                    Navigator.pop(ctx);
                    _pickReceiptImage(ImageSource.gallery);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }"""

content = content.replace(old_image_picker, new_image_picker)

# 4. Update _showQrZoomDialog
old_qr_zoom = """                          Text(
                          gateway == 'glowbay_bkash'
                              ? 'বিকাশ নম্বর'
                              : (gateway == 'glowbay_nagad'
                                  ? 'নগদ নম্বর'
                                  : (gateway == 'glowbay_bangla_qr' ? 'বাংলা QR / ব্যাংক হিসাব নম্বর' : 'অ্যাকাউন্ট নম্বর')),
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),"""

new_qr_zoom = """                          Text(
                          gateway == 'glowbay_bkash'
                              ? (context.read<LanguageProvider>().isEnglish ? 'bKash Number' : 'বিকাশ নম্বর')
                              : (gateway == 'glowbay_nagad'
                                  ? (context.read<LanguageProvider>().isEnglish ? 'Nagad Number' : 'নগদ নম্বর')
                                  : (gateway == 'glowbay_bangla_qr' ? (context.read<LanguageProvider>().isEnglish ? 'Bangla QR / Bank A/C' : 'বাংলা QR / ব্যাংক হিসাব নম্বর') : (context.read<LanguageProvider>().isEnglish ? 'Account Number' : 'অ্যাকাউন্ট নম্বর'))),
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),"""

content = content.replace(old_qr_zoom, new_qr_zoom)

content = content.replace(
    "content: Text('$activeNumber কপি করা হয়েছে! ✓'),",
    "content: Text(context.read<LanguageProvider>().isEnglish ? '$activeNumber copied! ✓' : '$activeNumber কপি করা হয়েছে! ✓'),"
)
content = content.replace(
    "label: const Text('কপি', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),",
    "label: Text(context.read<LanguageProvider>().isEnglish ? 'Copy' : 'কপি', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),"
)
content = content.replace(
    "const TextSpan(text: 'প্রদেয় পরিমাণ: ', style: TextStyle(fontWeight: FontWeight.w600)),",
    "TextSpan(text: context.read<LanguageProvider>().isEnglish ? 'Payable Amount: ' : 'প্রদেয় পরিমাণ: ', style: const TextStyle(fontWeight: FontWeight.w600)),"
)
content = content.replace(
    "'যেকোনো ফোন বা অ্যাপ দিয়ে সরাসরি স্ক্যান করে পেমেন্ট করুন',",
    "context.read<LanguageProvider>().isEnglish ? 'Scan directly with any mobile or banking app to pay' : 'যেকোনো ফোন বা অ্যাপ দিয়ে সরাসরি স্ক্যান করে পেমেন্ট করুন',"
)

# 5. Update _submitOrder validations and dialogs
content = content.replace(
    "const SnackBar(content: Text('অনুগ্রহ করে প্রয়োজনীয় সব ফিল্ড সঠিকভাবে পূরণ করুন *'), backgroundColor: AppColors.error),",
    "SnackBar(content: Text(context.read<LanguageProvider>().isEnglish ? 'Please fill all required fields correctly *' : 'অনুগ্রহ করে প্রয়োজনীয় সব ফিল্ড সঠিকভাবে পূরণ করুন *'), backgroundColor: AppColors.error),"
)
content = content.replace(
    "const SnackBar(content: Text('আপনার কোনো আইটেম সিলেক্ট করা নেই!'), backgroundColor: AppColors.error)",
    "SnackBar(content: Text(context.read<LanguageProvider>().isEnglish ? 'No items selected for checkout!' : 'আপনার কোনো আইটেম সিলেক্ট করা নেই!'), backgroundColor: AppColors.error)"
)
content = content.replace(
    "const SnackBar(content: Text('যে নম্বর থেকে টাকা পাঠিয়েছেন তা সঠিকভাবে লিখুন (১১ ডিজিট) *'), backgroundColor: AppColors.error),",
    "SnackBar(content: Text(context.read<LanguageProvider>().isEnglish ? 'Enter the 11-digit phone number you paid from *' : 'যে নম্বর থেকে টাকা পাঠিয়েছেন তা সঠিকভাবে লিখুন (১১ ডিজিট) *'), backgroundColor: AppColors.error),"
)
content = content.replace(
    "const SnackBar(content: Text('সঠিক Transaction ID (TrxID) বা ব্যাংক রেফারেন্স প্রদান করুন *'), backgroundColor: AppColors.error),",
    "SnackBar(content: Text(context.read<LanguageProvider>().isEnglish ? 'Enter a valid Transaction ID (TrxID) or Bank Reference *' : 'সঠিক Transaction ID (TrxID) বা ব্যাংক রেফারেন্স প্রদান করুন *'), backgroundColor: AppColors.error),"
)
content = content.replace(
    "const SnackBar(content: Text('অনুগ্রহ করে পেমেন্ট রিসিটের স্ক্রিনশট আপলোড করুন (বাধ্যতামূলক) *'), backgroundColor: AppColors.error),",
    "SnackBar(content: Text(context.read<LanguageProvider>().isEnglish ? 'Please upload your payment receipt screenshot *' : 'অনুগ্রহ করে পেমেন্ট রিসিটের স্ক্রিনশট আপলোড করুন (বাধ্যতামূলক) *'), backgroundColor: AppColors.error),"
)

# Order placed dialog:
old_order_dialog = """            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 26),
                SizedBox(width: 10),
                Expanded(child: Text('অর্ডার সফলভাবে সম্পন্ন হয়েছে!')),
              ],
            ),
            content: Text(
              'ধন্যবাদ! আপনার প্রি-অর্ডারটি (#$orderId) সিস্টেমে সংরক্ষিত হয়েছে। আমাদের ঢাকা অফিস ও মালয়েশিয়া টিম ভেরিফিকেশন শেষে প্রসেসিং শুরু করবে।',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),"""

new_order_dialog = """            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 26),
                const SizedBox(width: 10),
                Expanded(child: Text(context.read<LanguageProvider>().isEnglish ? 'Order Placed Successfully!' : 'অর্ডার সফলভাবে সম্পন্ন হয়েছে!')),
              ],
            ),
            content: Text(
              context.read<LanguageProvider>().isEnglish
                  ? 'Thank you! Your pre-order (#$orderId) has been registered. Our Dhaka and Kuala Lumpur teams will verify and start processing immediately.'
                  : 'ধন্যবাদ! আপনার প্রি-অর্ডারটি (#$orderId) সিস্টেমে সংরক্ষিত হয়েছে। আমাদের ঢাকা অফিস ও মালয়েশিয়া টিম ভেরিফিকেশন শেষে প্রসেসিং শুরু করবে।',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),"""

content = content.replace(old_order_dialog, new_order_dialog)

# _showLoginPrompt:
old_login_prompt = """                      Text(
                        'লগইন প্রয়োজন (Login Required)',
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'অর্ডার নিশ্চিত করতে অ্যাকাউন্ট প্রয়োজন',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'GlowBayBD-তে প্রি-অর্ডার সম্পূর্ণ করতে এবং লাইভ পার্সেল ট্র্যাকিং দেখতে অনুগ্রহ করে লগইন করুন।',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),"""

new_login_prompt = """                      Text(
                        context.read<LanguageProvider>().isEnglish ? 'Login Required' : 'লগইন প্রয়োজন (Login Required)',
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.read<LanguageProvider>().isEnglish ? 'Account needed to confirm order' : 'অর্ডার নিশ্চিত করতে অ্যাকাউন্ট প্রয়োজন',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              context.read<LanguageProvider>().isEnglish
                  ? 'Please log in to complete your pre-order and view live parcel tracking on GlowBay.'
                  : 'GlowBayBD-তে প্রি-অর্ডার সম্পূর্ণ করতে এবং লাইভ পার্সেল ট্র্যাকিং দেখতে অনুগ্রহ করে লগইন করুন।',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),"""

content = content.replace(old_login_prompt, new_login_prompt)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Batch 1 completed successfully")
