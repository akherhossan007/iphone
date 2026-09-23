with open('lib/presentation/screens/checkout/checkout_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Line numbers are 1-based, index is 0-based
# Let's find the Bangla QR banner:
for i, line in enumerate(lines):
    if "'বাংলা QR-এ কোনো ক্যাশআউট চার্জ নেই" in line:
        # replace the Text widget
        lines[i] = "                                          Text(isEn ? 'No Cashout Charge on Bangla QR (৳0 Fee / 0% Extra)!' : 'বাংলা QR-এ কোনো ক্যাশআউট চার্জ নেই (৳০ ফি / ০% এক্সট্রা)!',\n"
    if "'বিকাশ, নগদ, সেলফিন, রকেট বা যেকোনো ব্যাংক অ্যাপ" in line:
        lines[i] = "                                          Text(isEn ? 'Scan directly using bKash, Nagad, CellFin, Rocket or any banking app with zero extra fees.' : 'বিকাশ, নগদ, সেলফিন, রকেট বা যেকোনো ব্যাংক অ্যাপ দিয়ে সরাসরি স্ক্যান করে অতিরিক্ত খরচ ছাড়াই পেমেন্ট করুন।',\n"

    # Bangla QR details:
    if "child: const Text('জাতীয় স্ট্যান্ডার্ড'" in line:
        lines[i] = "                                                    child: Text(isEn ? 'National Standard' : 'জাতীয় স্ট্যান্ডার্ড', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),\n"
    if "const Text('সমন্বিত বাংলা কিউআর'" in line:
        lines[i] = "                                                    Text(isEn ? 'Unified Bangla QR' : 'সমন্বিত বাংলা কিউআর', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF065F46))),\n"
    if "children: ['✓ বিকাশ', '✓ নগদ', '✓ সেলফিন', '✓ রকেট', '✓ কার্ড']" in line:
        lines[i] = "                                                children: (isEn ? ['✓ bKash', '✓ Nagad', '✓ CellFin', '✓ Rocket', '✓ Card'] : ['✓ বিকাশ', '✓ নগদ', '✓ সেলফিন', '✓ রকেট', '✓ কার্ড'])\n"

    # Steps header:
    if "? '📋 ডিপোজিটের নির্দেশনা:'" in line:
        lines[i] = "                                              ? (isEn ? '📋 Bank Deposit Instructions:' : '📋 ডিপোজিটের নির্দেশনা:')\n"
    if ": (_paymentGateway == 'glowbay_bangla_qr' ? '📋 বাংলা QR পেমেন্ট করার ধাপ:' : '📋 পেমেন্টের ধাপসমূহ:')" in line:
        lines[i] = "                                              : (_paymentGateway == 'glowbay_bangla_qr' ? (isEn ? '📋 Bangla QR Payment Steps:' : '📋 বাংলা QR পেমেন্ট করার ধাপ:') : (isEn ? '📋 Payment Steps:' : '📋 পেমেন্টের ধাপসমূহ:')),\n"

    # Steps for bKash:
    if "_buildPayStep('১', 'বিকাশ অ্যাপে" in line:
        lines[i] = "                                          _buildPayStep(isEn ? '1' : '১', isEn ? 'Send Money ৳${totalPayableWithFee.toStringAsFixed(0)} via bKash App.${cashoutFee > 0 ? \" (Inc. cashout fee)\" : \"\"}' : 'বিকাশ অ্যাপে Send Money করে ৳${totalPayableWithFee.toStringAsFixed(0)} পাঠান।${cashoutFee > 0 ? \" (ক্যাশআউট চার্জসহ)\" : \"\"}', const Color(0xFFD12053)),\n"
    if "_buildPayStep('২', 'নিচের বক্সে আপনার বিকাশ নম্বর" in line:
        lines[i] = "                                          _buildPayStep(isEn ? '2' : '২', isEn ? 'Enter your bKash number & TrxID below.' : 'নিচের বক্সে আপনার বিকাশ নম্বর ও TrxID লিখুন।', const Color(0xFFD12053)),\n"
    if "_buildPayStep('৩', 'পেমেন্ট রিসিটের স্ক্রিনশট আপলোড করুন।', const Color(0xFFD12053))" in line:
        lines[i] = "                                          _buildPayStep(isEn ? '3' : '৩', isEn ? 'Upload a screenshot of payment receipt.' : 'পেমেন্ট রিসিটের স্ক্রিনশট আপলোড করুন।', const Color(0xFFD12053)),\n"

    # Steps for Nagad:
    if "_buildPayStep('১', 'নগদ অ্যাপে" in line:
        lines[i] = "                                          _buildPayStep(isEn ? '1' : '১', isEn ? 'Send Money ৳${totalPayableWithFee.toStringAsFixed(0)} via Nagad App.${cashoutFee > 0 ? \" (Inc. cashout fee)\" : \"\"}' : 'নগদ অ্যাপে Send Money করে ৳${totalPayableWithFee.toStringAsFixed(0)} পাঠান।${cashoutFee > 0 ? \" (ক্যাশআউট চার্জসহ)\" : \"\"}', const Color(0xFFF7941D)),\n"
    if "_buildPayStep('২', 'নিচের বক্সে আপনার নগদ নম্বর" in line:
        lines[i] = "                                          _buildPayStep(isEn ? '2' : '২', isEn ? 'Enter your Nagad number & TrxID below.' : 'নিচের বক্সে আপনার নগদ নম্বর ও TrxID লিখুন।', const Color(0xFFF7941D)),\n"
    if "_buildPayStep('৩', 'পেমেন্ট রিসিটের স্ক্রিনশট আপলোড করুন।', const Color(0xFFF7941D))" in line:
        lines[i] = "                                          _buildPayStep(isEn ? '3' : '৩', isEn ? 'Upload a screenshot of payment receipt.' : 'পেমেন্ট রিসিটের স্ক্রিনশট আপলোড করুন।', const Color(0xFFF7941D)),\n"

    # Steps for Bangla QR:
    if "_buildPayStep('১', 'বিকাশ, নগদ, সেলফিন বা ব্যাংক অ্যাপের \"বাংলা QR" in line:
        lines[i] = "                                          _buildPayStep(isEn ? '1' : '১', isEn ? 'Scan via \"Bangla QR / QR Pay\" in bKash, Nagad, CellFin or Bank app & pay ৳${totalPayableWithFee.toStringAsFixed(0)} (0% Fee).' : 'বিকাশ, নগদ, সেলফিন বা ব্যাংক অ্যাপের \"বাংলা QR / QR Pay\" দিয়ে স্ক্যান করে ৳${totalPayableWithFee.toStringAsFixed(0)} পাঠান। (০% ফি, কোনো চার্জ নেই)', const Color(0xFF059669)),\n"
    if "_buildPayStep('২', 'নিচের বক্সে আপনার প্রেরক নম্বর ও TrxID / রেফারেন্স" in line:
        lines[i] = "                                          _buildPayStep(isEn ? '2' : '২', isEn ? 'Enter your sender number & TrxID / Reference below.' : 'নিচের বক্সে আপনার প্রেরক নম্বর ও TrxID / রেফারেন্স লিখুন।', const Color(0xFF059669)),\n"
    if "_buildPayStep('৩', 'পেমেন্ট সফল হওয়ার স্ক্রিনশট বা রিসিট" in line:
        lines[i] = "                                          _buildPayStep(isEn ? '3' : '৩', isEn ? 'Upload a screenshot or photo of payment confirmation.' : 'পেমেন্ট সফল হওয়ার স্ক্রিনশট বা রিসিট আপলোড করুন।', const Color(0xFF059669)),\n"

    # Steps for Bank:
    if "_buildPayStep('১', 'ইসলামী ব্যাংকে" in line:
        lines[i] = "                                          _buildPayStep(isEn ? '1' : '১', isEn ? 'Deposit/transfer ৳${totalPayableWithFee.toStringAsFixed(0)} to Islami Bank A/C.' : 'ইসলামী ব্যাংকে ৳${totalPayableWithFee.toStringAsFixed(0)} ডিপোজিট/ট্রান্সফার করুন।', const Color(0xFF15803D)),\n"
    if "_buildPayStep('২', 'ডিপোজিট রেফারেন্স নম্বর নিচে" in line:
        lines[i] = "                                          _buildPayStep(isEn ? '2' : '২', isEn ? 'Enter deposit reference number below.' : 'ডিপোজিট রেফারেন্স নম্বর নিচে লিখুন।', const Color(0xFF15803D)),\n"
    if "_buildPayStep('৩', 'ব্যাংক স্লিপ/রিসিটের ছবি" in line:
        lines[i] = "                                          _buildPayStep(isEn ? '3' : '৩', isEn ? 'Upload a photo of bank deposit slip/receipt.' : 'ব্যাংক স্লিপ/রিসিটের ছবি আপলোড করুন।', const Color(0xFF15803D)),\n"

    # QR code failed:
    if "const Text('QR কোড লোড হয়নি'" in line:
        lines[i] = "                        Text(context.read<LanguageProvider>().isEnglish ? 'QR code failed to load' : 'QR কোড লোড হয়নি', style: const TextStyle(fontSize: 11, color: Colors.grey)),\n"

with open('lib/presentation/screens/checkout/checkout_screen.dart', 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("Exact lines updated successfully")
