file_path = 'lib/presentation/screens/checkout/checkout_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Error message in _submitOrder
content = content.replace(
    "res['message'] ?? 'অর্ডার সম্পন্ন করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।'",
    "res['message'] ?? (context.read<LanguageProvider>().isEnglish ? 'Failed to complete order. Please try again.' : 'অর্ডার সম্পন্ন করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।')"
)

# 2. Bangla QR banner
old_bqr_box = """                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('🎉', style: TextStyle(fontSize: 18)),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'বাংলা QR-এ কোনো ক্যাশআউট চার্জ নেই (৳০ ফি / ০% এক্সট্রা)!',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'বিকাশ, নগদ, সেলফিন, রকেট বা যেকোনো ব্যাংক অ্যাপ দিয়ে সরাসরি স্ক্যান করে অতিরিক্ত খরচ ছাড়াই পেমেন্ট করুন।',
                                            style: TextStyle(fontSize: 11, color: Color(0xFF047857), height: 1.35),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),"""

new_bqr_box = """                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('🎉', style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isEn ? 'No Cashout Charge on Bangla QR (৳0 Fee / 0% Extra)!' : 'বাংলা QR-এ কোনো ক্যাশআউট চার্জ নেই (৳০ ফি / ০% এক্সট্রা)!',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isEn
                                                ? 'Scan directly using bKash, Nagad, CellFin, Rocket or any banking app with zero extra fees.'
                                                : 'বিকাশ, নগদ, সেলফিন, রকেট বা যেকোনো ব্যাংক অ্যাপ দিয়ে সরাসরি স্ক্যান করে অতিরিক্ত খরচ ছাড়াই পেমেন্ট করুন।',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF047857), height: 1.35),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),"""

content = content.replace(old_bqr_box, new_bqr_box)

# 3. Bangla QR Details
old_bqr_details = """                                              if (_paymentGateway == 'glowbay_bangla_qr') ...[
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(4)),
                                                      child: const Text('জাতীয় স্ট্যান্ডার্ড', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text('সমন্বিত বাংলা কিউআর', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF065F46))),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text('ব্যাংক: ${paymentSettings.banglaQrBankName}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                                                Text('অ্যাকাউন্ট নাম: ${paymentSettings.banglaQrAccountName}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF101936))),
                                                Text('শাখা: ${paymentSettings.banglaQrBranchName}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                                                const SizedBox(height: 5),
                                                Wrap(
                                                  spacing: 3,
                                                  runSpacing: 3,
                                                  children: ['✓ বিকাশ', '✓ নগদ', '✓ সেলফিন', '✓ রকেট', '✓ কার্ড'].map((app) => Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFA7F3D0))),
                                                    child: Text(app, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                                                  )).toList(),
                                                ),
                                              ] else ...["""

new_bqr_details = """                                              if (_paymentGateway == 'glowbay_bangla_qr') ...[
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(4)),
                                                      child: Text(isEn ? 'National Standard' : 'জাতীয় স্ট্যান্ডার্ড', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(isEn ? 'Unified Bangla QR' : 'সমন্বিত বাংলা কিউআর', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF065F46))),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(isEn ? 'Bank: ${paymentSettings.banglaQrBankName}' : 'ব্যাংক: ${paymentSettings.banglaQrBankName}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                                                Text(isEn ? 'A/C Name: ${paymentSettings.banglaQrAccountName}' : 'অ্যাকাউন্ট নাম: ${paymentSettings.banglaQrAccountName}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF101936))),
                                                Text(isEn ? 'Branch: ${paymentSettings.banglaQrBranchName}' : 'শাখা: ${paymentSettings.banglaQrBranchName}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                                                const SizedBox(height: 5),
                                                Wrap(
                                                  spacing: 3,
                                                  runSpacing: 3,
                                                  children: (isEn ? ['✓ bKash', '✓ Nagad', '✓ CellFin', '✓ Rocket', '✓ Card'] : ['✓ বিকাশ', '✓ নগদ', '✓ সেলফিন', '✓ রকেট', '✓ কার্ড']).map((app) => Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFA7F3D0))),
                                                    child: Text(app, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                                                  )).toList(),
                                                ),
                                              ] else ...["""

content = content.replace(old_bqr_details, new_bqr_details)

# 4. Step by step instructions
old_steps_block = """                                         if (_paymentGateway == 'glowbay_bkash') ...[
                                           _buildPayStep('১', 'বিকাশ অ্যাপে Send Money করে ৳${totalPayableWithFee.toStringAsFixed(0)} পাঠান।${cashoutFee > 0 ? " (ক্যাশআউট চার্জসহ)" : ""}', const Color(0xFFD12053)),
                                           _buildPayStep('২', 'নিচের বক্সে আপনার বিকাশ নম্বর ও TrxID লিখুন।', const Color(0xFFD12053)),
                                           _buildPayStep('৩', 'পেমেন্ট রিসিটের স্ক্রিনশট আপলোড করুন।', const Color(0xFFD12053)),
                                         ] else if (_paymentGateway == 'glowbay_nagad') ...[
                                           _buildPayStep('১', 'নগদ অ্যাপে Send Money করে ৳${totalPayableWithFee.toStringAsFixed(0)} পাঠান।${cashoutFee > 0 ? " (ক্যাশআউট চার্জসহ)" : ""}', const Color(0xFFF7941D)),
                                           _buildPayStep('২', 'নিচের বক্সে আপনার নগদ নম্বর ও TrxID লিখুন।', const Color(0xFFF7941D)),
                                           _buildPayStep('৩', 'পেমেন্ট রিসিটের স্ক্রিনশট আপলোড করুন।', const Color(0xFFF7941D)),
                                         ] else if (_paymentGateway == 'glowbay_bangla_qr') ...[
                                           _buildPayStep('১', 'বিকাশ, নগদ, সেলফিন বা ব্যাংক অ্যাপের "বাংলা QR / QR Pay" দিয়ে স্ক্যান করে ৳${totalPayableWithFee.toStringAsFixed(0)} পাঠান। (০% ফি, কোনো চার্জ নেই)', const Color(0xFF059669)),
                                           _buildPayStep('২', 'নিচের বক্সে আপনার প্রেরক নম্বর ও TrxID / রেফারেন্স লিখুন।', const Color(0xFF059669)),
                                           _buildPayStep('৩', 'পেমেন্ট সফল হওয়ার স্ক্রিনশট বা রিসিট আপলোড করুন।', const Color(0xFF059669)),
                                         ] else ...[
                                           _buildPayStep('১', 'ইসলামী ব্যাংকে ৳${totalPayableWithFee.toStringAsFixed(0)} ডিপোজিট/ট্রান্সফার করুন।', const Color(0xFF15803D)),
                                           _buildPayStep('২', 'ডিপোজিট রেফারেন্স নম্বর নিচে লিখুন।', const Color(0xFF15803D)),
                                           _buildPayStep('৩', 'ব্যাংক স্লিপ/রিসিটের ছবি আপলোড করুন।', const Color(0xFF15803D)),
                                         ],"""

new_steps_block = """                                         if (_paymentGateway == 'glowbay_bkash') ...[
                                           _buildPayStep(isEn ? '1' : '১', isEn ? 'Send Money ৳${totalPayableWithFee.toStringAsFixed(0)} via bKash App.${cashoutFee > 0 ? " (Inc. cashout fee)" : ""}' : 'বিকাশ অ্যাপে Send Money করে ৳${totalPayableWithFee.toStringAsFixed(0)} পাঠান।${cashoutFee > 0 ? " (ক্যাশআউট চার্জসহ)" : ""}', const Color(0xFFD12053)),
                                           _buildPayStep(isEn ? '2' : '২', isEn ? 'Enter your bKash number & TrxID below.' : 'নিচের বক্সে আপনার বিকাশ নম্বর ও TrxID লিখুন।', const Color(0xFFD12053)),
                                           _buildPayStep(isEn ? '3' : '৩', isEn ? 'Upload a screenshot of payment receipt.' : 'পেমেন্ট রিসিটের স্ক্রিনশট আপলোড করুন।', const Color(0xFFD12053)),
                                         ] else if (_paymentGateway == 'glowbay_nagad') ...[
                                           _buildPayStep(isEn ? '1' : '১', isEn ? 'Send Money ৳${totalPayableWithFee.toStringAsFixed(0)} via Nagad App.${cashoutFee > 0 ? " (Inc. cashout fee)" : ""}' : 'নগদ অ্যাপে Send Money করে ৳${totalPayableWithFee.toStringAsFixed(0)} পাঠান।${cashoutFee > 0 ? " (ক্যাশআউট চার্জসহ)" : ""}', const Color(0xFFF7941D)),
                                           _buildPayStep(isEn ? '2' : '২', isEn ? 'Enter your Nagad number & TrxID below.' : 'নিচের বক্সে আপনার নগদ নম্বর ও TrxID লিখুন।', const Color(0xFFF7941D)),
                                           _buildPayStep(isEn ? '3' : '৩', isEn ? 'Upload a screenshot of payment receipt.' : 'পেমেন্ট রিসিটের স্ক্রিনশট আপলোড করুন।', const Color(0xFFF7941D)),
                                         ] else if (_paymentGateway == 'glowbay_bangla_qr') ...[
                                           _buildPayStep(isEn ? '1' : '১', isEn ? 'Scan via "Bangla QR / QR Pay" in bKash, Nagad, CellFin or Bank app & pay ৳${totalPayableWithFee.toStringAsFixed(0)} (0% Fee).' : 'বিকাশ, নগদ, সেলফিন বা ব্যাংক অ্যাপের "বাংলা QR / QR Pay" দিয়ে স্ক্যান করে ৳${totalPayableWithFee.toStringAsFixed(0)} পাঠান। (০% ফি, কোনো চার্জ নেই)', const Color(0xFF059669)),
                                           _buildPayStep(isEn ? '2' : '২', isEn ? 'Enter your sender number & TrxID / Reference below.' : 'নিচের বক্সে আপনার প্রেরক নম্বর ও TrxID / রেফারেন্স লিখুন।', const Color(0xFF059669)),
                                           _buildPayStep(isEn ? '3' : '৩', isEn ? 'Upload a screenshot or photo of payment confirmation.' : 'পেমেন্ট সফল হওয়ার স্ক্রিনশট বা রিসিট আপলোড করুন।', const Color(0xFF059669)),
                                         ] else ...[
                                           _buildPayStep(isEn ? '1' : '১', isEn ? 'Deposit/transfer ৳${totalPayableWithFee.toStringAsFixed(0)} to Islami Bank A/C.' : 'ইসলামী ব্যাংকে ৳${totalPayableWithFee.toStringAsFixed(0)} ডিপোজিট/ট্রান্সফার করুন।', const Color(0xFF15803D)),
                                           _buildPayStep(isEn ? '2' : '২', isEn ? 'Enter deposit reference number below.' : 'ডিপোজিট রেফারেন্স নম্বর নিচে লিখুন।', const Color(0xFF15803D)),
                                           _buildPayStep(isEn ? '3' : '৩', isEn ? 'Upload a photo of bank deposit slip/receipt.' : 'ব্যাংক স্লিপ/রিসিটের ছবি আপলোড করুন।', const Color(0xFF15803D)),
                                         ],"""

content = content.replace(old_steps_block, new_steps_block)

# 5. Payment Breakdown title
old_breakdown_title = """                                Text(
                                  _paymentPlan == 'advance_50'
                                      ? 'পেমেন্ট ব্রেকডাউন (৫০% অগ্রিম প্ল্যান)'
                                      : 'পেমেন্ট ব্রেকডাউন (১০০% সম্পূর্ণ পরিশোধ)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFFF2D78),
                                  ),
                                ),"""

new_breakdown_title = """                                Text(
                                  _paymentPlan == 'advance_50'
                                      ? (isEn ? 'Payment Breakdown (50% Advance Plan)' : 'পেমেন্ট ব্রেকডাউন (৫০% অগ্রিম প্ল্যান)')
                                      : (isEn ? 'Payment Breakdown (100% Full Payment)' : 'পেমেন্ট ব্রেকডাউন (১০০% সম্পূর্ণ পরিশোধ)'),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFFF2D78),
                                  ),
                                ),"""

content = content.replace(old_breakdown_title, new_breakdown_title)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Remaining checkout fixes completed")
