import re

file_path = 'lib/presentation/screens/checkout/checkout_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add final isEn inside build()
build_start = """  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();"""

new_build_start = """  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isEn = lang.isEnglish;
    final cart = context.watch<CartProvider>();"""

content = content.replace(build_start, new_build_start)

# 2. Customer name fallback
content = content.replace(
    "_nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'গ্রাহকের নাম',",
    "_nameController.text.trim().isNotEmpty ? _nameController.text.trim() : (isEn ? 'Customer Name' : 'গ্রাহকের নাম'),"
)

# 3. Delivery Method Card
content = content.replace(
    "'প্রি-অর্ডার হোম ডেলিভারি',",
    "isEn ? 'Pre-Order Home Delivery' : 'প্রি-অর্ডার হোম ডেলিভারি',"
)
content = content.replace(
    "'সম্ভাব্য ডেলিভারি: ${_getEstimatedDeliveryRange()}',",
    "'${isEn ? 'Estimated Delivery: ' : 'সম্ভাব্য ডেলিভারি: '}${_getEstimatedDeliveryRange(isEn)}',"
)

old_weight_desc = """                                        Text(
                                          cart.totalWeightKg > 1
                                              ? '${cart.isInsideDhaka ? 'ঢাকার ভিতর' : 'ঢাকার বাইরে'}: ১ম কেজি ৳${cart.isInsideDhaka ? '৮০' : '১৫০'} + বাকি ${(cart.totalWeightKg - 1).ceil()} কেজি × ৳${cart.isInsideDhaka ? '২০' : '৩০'}'
                                              : 'মালয়েশিয়া থেকে সরাসরি সংগ্রহ করে সারাদেশে হোম ডেলিভারি (১০–২৫ কার্যদিবস)',
                                          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.3),
                                        ),"""

new_weight_desc = """                                        Text(
                                          cart.totalWeightKg > 1
                                              ? (isEn
                                                  ? '${cart.isInsideDhaka ? 'Inside Dhaka' : 'Outside Dhaka'}: 1st kg ৳${cart.isInsideDhaka ? '80' : '150'} + rest ${(cart.totalWeightKg - 1).ceil()} kg × ৳${cart.isInsideDhaka ? '20' : '30'}'
                                                  : '${cart.isInsideDhaka ? 'ঢাকার ভিতর' : 'ঢাকার বাইরে'}: ১ম কেজি ৳${cart.isInsideDhaka ? '৮০' : '১৫০'} + বাকি ${(cart.totalWeightKg - 1).ceil()} কেজি × ৳${cart.isInsideDhaka ? '২০' : '৩০'}')
                                              : (isEn
                                                  ? 'Directly sourced from Malaysia, home delivery nationwide (10–25 business days)'
                                                  : 'মালয়েশিয়া থেকে সরাসরি সংগ্রহ করে সারাদেশে হোম ডেলিভারি (১০–২৫ কার্যদিবস)'),
                                          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.3),
                                        ),"""

content = content.replace(old_weight_desc, new_weight_desc)

content = content.replace(
    "'মোট ${cart.totalWeightKg.toStringAsFixed(cart.totalWeightKg.truncateToDouble() == cart.totalWeightKg ? 0 : 1)} কেজি',",
    "isEn ? 'Total ${cart.totalWeightKg.toStringAsFixed(cart.totalWeightKg.truncateToDouble() == cart.totalWeightKg ? 0 : 1)} kg' : 'মোট ${cart.totalWeightKg.toStringAsFixed(cart.totalWeightKg.truncateToDouble() == cart.totalWeightKg ? 0 : 1)} কেজি',"
)

# 4. Step 1: Payment Plan
content = content.replace(
    "'১. পেমেন্ট প্ল্যান বেছে নিন (Select Payment Plan):',",
    "isEn ? '1. Select Payment Plan:' : '১. পেমেন্ট প্ল্যান বেছে নিন (Select Payment Plan):',"
)
content = content.replace(
    "const Text('৫০% অগ্রিম', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFFF2D78))),",
    "Text(isEn ? '50% Advance' : '৫০% অগ্রিম', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFFF2D78))),"
)
content = content.replace(
    "const Text('বাকি ৫০% ডেলিভারির সময় COD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF881337))),",
    "Text(isEn ? 'Remaining 50% on Delivery COD' : 'বাকি ৫০% ডেলিভারির সময় COD', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF881337))),"
)
content = content.replace(
    "child: const Text('পপুলার চয়েস', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),",
    "child: Text(isEn ? 'POPULAR' : 'পপুলার চয়েস', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),"
)

content = content.replace(
    "Text('১০০% ফুল পে', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _paymentPlan == 'full_100' ? const Color(0xFFFF2D78) : const Color(0xFF0F172A))),",
    "Text(isEn ? '100% Full Pay' : '১০০% ফুল পে', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _paymentPlan == 'full_100' ? const Color(0xFFFF2D78) : const Color(0xFF0F172A))),"
)
content = content.replace(
    "const Text('ডেলিভারির সময় ৳০ (ক্যাশলেস)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),",
    "Text(isEn ? 'Due on Delivery ৳0 (Cashless)' : 'ডেলিভারির সময় ৳০ (ক্যাশলেস)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),"
)
content = content.replace(
    "child: const Text('ক্যাশলেস', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),",
    "child: Text(isEn ? 'CASHLESS' : 'ক্যাশলেস', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),"
)

# 5. Step 2: Payment Gateways
content = content.replace(
    "'২. পেমেন্ট মেথড বেছে নিন (Payment Method):',",
    "isEn ? '2. Select Payment Method:' : '২. পেমেন্ট মেথড বেছে নিন (Payment Method):',"
)
content = content.replace(
    "_buildPayGatewayBtn('glowbay_bkash', 'bKash', 'Send Money', const Color(0xFFD12053), Icons.phone_android, badgeText: '১.৮৫% চার্জ', badgeColor: const Color(0xFFD12053)),",
    "_buildPayGatewayBtn('glowbay_bkash', 'bKash', 'Send Money', const Color(0xFFD12053), Icons.phone_android, badgeText: isEn ? '1.85% Fee' : '১.৮৫% চার্জ', badgeColor: const Color(0xFFD12053)),"
)
content = content.replace(
    "_buildPayGatewayBtn('glowbay_nagad', 'Nagad (নগদ)', 'Send Money', const Color(0xFFF7941D), Icons.account_balance_wallet, badgeText: '১.৫% চার্জ', badgeColor: const Color(0xFFF7941D)),",
    "_buildPayGatewayBtn('glowbay_nagad', isEn ? 'Nagad' : 'Nagad (নগদ)', 'Send Money', const Color(0xFFF7941D), Icons.account_balance_wallet, badgeText: isEn ? '1.5% Fee' : '১.৫% চার্জ', badgeColor: const Color(0xFFF7941D)),"
)
content = content.replace(
    "_buildPayGatewayBtn('glowbay_bangla_qr', 'বাংলা QR (সমন্বিত)', 'বিকাশ/নগদ/সেলফিন', const Color(0xFF059669), Icons.qr_code_2_rounded, badgeText: '০% ফি (ফ্রি! 🎉)', badgeColor: const Color(0xFF059669)),",
    "_buildPayGatewayBtn('glowbay_bangla_qr', isEn ? 'Bangla QR' : 'বাংলা QR (সমন্বিত)', isEn ? 'bKash/Nagad/CellFin' : 'বিকাশ/নগদ/সেলফিন', const Color(0xFF059669), Icons.qr_code_2_rounded, badgeText: isEn ? '0% Fee (Free! 🎉)' : '০% ফি (ফ্রি! 🎉)', badgeColor: const Color(0xFF059669)),"
)
content = content.replace(
    "_buildPayGatewayBtn('glowbay_bank', 'Islami Bank', 'Bank Deposit', const Color(0xFF15803D), Icons.account_balance, badgeText: '০% চার্জ', badgeColor: const Color(0xFF15803D)),",
    "_buildPayGatewayBtn('glowbay_bank', 'Islami Bank', 'Bank Deposit', const Color(0xFF15803D), Icons.account_balance, badgeText: isEn ? '0% Fee' : '০% চার্জ', badgeColor: const Color(0xFF15803D)),"
)

# Bangla QR banner
old_bqr_banner = """                                            Text(
                                              'বাংলা QR-এ কোনো ক্যাশআউট চার্জ নেই (৳০ ফি / ০% এক্সট্রা)!',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'বিকাশ, নগদ, সেলফিন, রকেট বা যেকোনো ব্যাংক অ্যাপ দিয়ে সরাসরি স্ক্যান করে অতিরিক্ত খরচ ছাড়াই পেমেন্ট করুন।',
                                              style: TextStyle(fontSize: 11, color: Color(0xFF047857), height: 1.35),
                                            ),"""

new_bqr_banner = """                                            Text(
                                              isEn ? 'No Cashout Charge on Bangla QR (৳0 Fee / 0% Extra)!' : 'বাংলা QR-এ কোনো ক্যাশআউট চার্জ নেই (৳০ ফি / ০% এক্সট্রা)!',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              isEn
                                                  ? 'Scan directly using bKash, Nagad, CellFin, Rocket or any banking app with zero extra fees.'
                                                  : 'বিকাশ, নগদ, সেলফিন, রকেট বা যেকোনো ব্যাংক অ্যাপ দিয়ে সরাসরি স্ক্যান করে অতিরিক্ত খরচ ছাড়াই পেমেন্ট করুন।',
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF047857), height: 1.35),
                                            ),"""

content = content.replace(old_bqr_banner, new_bqr_banner)

# bKash / Nagad fee tip banner
old_fee_tip = """                                              TextSpan(
                                                text: _paymentGateway == 'glowbay_bkash'
                                                    ? 'বিকাশে ১.৮৫% ক্যাশআউট চার্জ প্রযোজ্য (৳${cashoutFee.toStringAsFixed(0)})। '
                                                    : 'নগদে ১.৫% ক্যাশআউট চার্জ প্রযোজ্য (৳${cashoutFee.toStringAsFixed(0)})। ',
                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              const TextSpan(
                                                text: 'চার্জ বাঁচাতে চান? বাংলা QR বেছে নিন — ০% অতিরিক্ত চার্জ (৳০ ফি)!',
                                                style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                                              ),"""

new_fee_tip = """                                              TextSpan(
                                                text: isEn
                                                    ? '${_paymentGateway == 'glowbay_bkash' ? 'bKash 1.85%' : 'Nagad 1.5%'} cashout fee applies (৳${cashoutFee.toStringAsFixed(0)}). '
                                                    : (_paymentGateway == 'glowbay_bkash'
                                                        ? 'বিকাশে ১.৮৫% ক্যাশআউট চার্জ প্রযোজ্য (৳${cashoutFee.toStringAsFixed(0)})। '
                                                        : 'নগদে ১.৫% ক্যাশআউট চার্জ প্রযোজ্য (৳${cashoutFee.toStringAsFixed(0)})। '),
                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              TextSpan(
                                                text: isEn
                                                    ? 'Want to save fees? Choose Bangla QR — 0% extra charge (৳0 fee)!'
                                                    : 'চার্জ বাঁচাতে চান? বাংলা QR বেছে নিন — ০% অতিরিক্ত চার্জ (৳০ ফি)!',
                                                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                                              ),"""

content = content.replace(old_fee_tip, new_fee_tip)

# Bangla QR details panel
old_bqr_details = """                                                   Container(
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
                                                  children: ['✓ বিকাশ', '✓ নগদ', '✓ সেলফিন', '✓ রকেট', '✓ কার্ড'].map((app) => Container("""

new_bqr_details = """                                                   Container(
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
                                                  children: (isEn ? ['✓ bKash', '✓ Nagad', '✓ CellFin', '✓ Rocket', '✓ Card'] : ['✓ বিকাশ', '✓ নগদ', '✓ সেলফিন', '✓ রকেট', '✓ কার্ড']).map((app) => Container("""

content = content.replace(old_bqr_details, new_bqr_details)

# Account Type text
old_acc_type = """                                              Text(
                                                  _paymentGateway == 'glowbay_bkash'
                                                      ? 'অ্যাকাউন্ট টাইপ: bKash ${paymentSettings.bkashType}'
                                                      : (_paymentGateway == 'glowbay_nagad'
                                                          ? 'অ্যাকাউন্ট টাইপ: Nagad ${paymentSettings.nagadType}'
                                                          : 'ব্যাংক নাম: ${paymentSettings.bankName}'),
                                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w600),
                                                ),
                                                if (_paymentGateway == 'glowbay_bank') ...[
                                                  const SizedBox(height: 2),
                                                  Text('অ্যাকাউন্ট নাম: ${paymentSettings.accountName}',
                                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF101936))),
                                                  Text('শাখা: ${paymentSettings.branchName}',
                                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                                ],"""

new_acc_type = """                                              Text(
                                                  isEn
                                                      ? (_paymentGateway == 'glowbay_bkash'
                                                          ? 'Account Type: bKash ${paymentSettings.bkashType}'
                                                          : (_paymentGateway == 'glowbay_nagad'
                                                              ? 'Account Type: Nagad ${paymentSettings.nagadType}'
                                                              : 'Bank Name: ${paymentSettings.bankName}'))
                                                      : (_paymentGateway == 'glowbay_bkash'
                                                          ? 'অ্যাকাউন্ট টাইপ: bKash ${paymentSettings.bkashType}'
                                                          : (_paymentGateway == 'glowbay_nagad'
                                                              ? 'অ্যাকাউন্ট টাইপ: Nagad ${paymentSettings.nagadType}'
                                                              : 'ব্যাংক নাম: ${paymentSettings.bankName}')),
                                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w600),
                                                ),
                                                if (_paymentGateway == 'glowbay_bank') ...[
                                                  const SizedBox(height: 2),
                                                  Text(isEn ? 'A/C Name: ${paymentSettings.accountName}' : 'অ্যাকাউন্ট নাম: ${paymentSettings.accountName}',
                                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF101936))),
                                                  Text(isEn ? 'Branch: ${paymentSettings.branchName}' : 'শাখা: ${paymentSettings.branchName}',
                                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                                ],"""

content = content.replace(old_acc_type, new_acc_type)

# SnackBar copy
old_copy_snack = """                                                        SnackBar(
                                                          content: Text('${_paymentGateway == 'glowbay_bkash' ? 'বিকাশ' : (_paymentGateway == 'glowbay_nagad' ? 'নগদ' : (_paymentGateway == 'glowbay_bangla_qr' ? 'বাংলা QR হিসাব' : 'ব্যাংক'))} নম্বর কপি করা হয়েছে! ✓'),
                                                          backgroundColor: const Color(0xFF10B981),
                                                          duration: const Duration(seconds: 2),
                                                        ),"""

new_copy_snack = """                                                        SnackBar(
                                                          content: Text(isEn
                                                              ? '${_paymentGateway == 'glowbay_bkash' ? 'bKash' : (_paymentGateway == 'glowbay_nagad' ? 'Nagad' : (_paymentGateway == 'glowbay_bangla_qr' ? 'Bangla QR Account' : 'Bank'))} number copied! ✓'
                                                              : '${_paymentGateway == 'glowbay_bkash' ? 'বিকাশ' : (_paymentGateway == 'glowbay_nagad' ? 'নগদ' : (_paymentGateway == 'glowbay_bangla_qr' ? 'বাংলা QR হিসাব' : 'ব্যাংক'))} নম্বর কপি করা হয়েছে! ✓'),
                                                          backgroundColor: const Color(0xFF10B981),
                                                          duration: const Duration(seconds: 2),
                                                        ),"""

content = content.replace(old_copy_snack, new_copy_snack)

content = content.replace(
    "Text('কপি', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936))),",
    "Text(isEn ? 'Copy' : 'কপি', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936))),"
)

content = content.replace(
    "Text(\n                                                      'বড় করুন',",
    "Text(\n                                                      isEn ? 'Enlarge' : 'বড় করুন',"
)

# Split pill card
old_split_pill = """                                              Text(
                                                  _paymentPlan == 'advance_50'
                                                      ? (cashoutFee > 0 ? 'প্রদেয় ৫০% অগ্রিম + চার্জ:' : 'প্রদেয় ৫০% অগ্রিম:')
                                                      : (cashoutFee > 0 ? 'প্রদেয় ১০০% ফুল + চার্জ:' : 'প্রদেয় ১০০% ফুল:'),
                                                  style: const TextStyle(fontSize: 11, color: Color(0xFF101936), fontWeight: FontWeight.w600),
                                                ),"""

new_split_pill = """                                              Text(
                                                  _paymentPlan == 'advance_50'
                                                      ? (isEn
                                                          ? (cashoutFee > 0 ? 'Payable 50% Advance + Fee:' : 'Payable 50% Advance:')
                                                          : (cashoutFee > 0 ? 'প্রদেয় ৫০% অগ্রিম + চার্জ:' : 'প্রদেয় ৫০% অগ্রিম:'))
                                                      : (isEn
                                                          ? (cashoutFee > 0 ? 'Payable 100% Full + Fee:' : 'Payable 100% Full:')
                                                          : (cashoutFee > 0 ? 'প্রদেয় ১০০% ফুল + চার্জ:' : 'প্রদেয় ১০০% ফুল:')),
                                                  style: const TextStyle(fontSize: 11, color: Color(0xFF101936), fontWeight: FontWeight.w600),
                                                ),"""

content = content.replace(old_split_pill, new_split_pill)

content = content.replace(
    "Text(\n                                                    '(চার্জ: ৳${cashoutFee.toStringAsFixed(0)})',",
    "Text(\n                                                    isEn ? '(Fee: ৳${cashoutFee.toStringAsFixed(0)})' : '(চার্জ: ৳${cashoutFee.toStringAsFixed(0)})',"
)

content = content.replace(
    "const Text('ডেলিভারির সময়:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),",
    "Text(isEn ? 'Due on Delivery:' : 'ডেলিভারির সময়:', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),"
)

# Step by Step Payment Instructions
old_steps_hdr = """                                          Text(
                                            _paymentGateway == 'glowbay_bank'
                                                ? '📋 ডিপোজিটের নির্দেশনা:'
                                                : (_paymentGateway == 'glowbay_bangla_qr' ? '📋 বাংলা QR পেমেন্ট করার ধাপ:' : '📋 পেমেন্টের ধাপসমূহ:'),
                                            style: TextStyle("""

new_steps_hdr = """                                          Text(
                                            _paymentGateway == 'glowbay_bank'
                                                ? (isEn ? '📋 Bank Deposit Instructions:' : '📋 ডিপোজিটের নির্দেশনা:')
                                                : (_paymentGateway == 'glowbay_bangla_qr'
                                                    ? (isEn ? '📋 Bangla QR Payment Steps:' : '📋 বাংলা QR পেমেন্ট করার ধাপ:')
                                                    : (isEn ? '📋 Payment Steps:' : '📋 পেমেন্টের ধাপসমূহ:')),
                                            style: TextStyle("""

content = content.replace(old_steps_hdr, new_steps_hdr)

old_steps_content = """                                          if (_paymentGateway == 'glowbay_bkash') ...[
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

new_steps_content = """                                          if (_paymentGateway == 'glowbay_bkash') ...[
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

content = content.replace(old_steps_content, new_steps_content)

content = content.replace(
    "SnackBar(content: Text('${_paymentGateway == 'glowbay_bkash' ? 'bKash' : 'Nagad'} অ্যাপ ওপেন করা যায়নি। অনুগ্রহ করে ম্যানুয়ালি ওপেন করুন।')),",
    "SnackBar(content: Text(isEn ? 'Could not open ${_paymentGateway == 'glowbay_bkash' ? 'bKash' : 'Nagad'} app. Please open manually.' : '${_paymentGateway == 'glowbay_bkash' ? 'bKash' : 'Nagad'} অ্যাপ ওপেন করা যায়নি। অনুগ্রহ করে ম্যানুয়ালি ওপেন করুন।')),"
)

content = content.replace(
    "_paymentGateway == 'glowbay_bkash' ? 'bKash অ্যাপ ওপেন করুন' : 'Nagad অ্যাপ ওপেন করুন',",
    "isEn ? 'Open ${_paymentGateway == 'glowbay_bkash' ? 'bKash' : 'Nagad'} App' : (_paymentGateway == 'glowbay_bkash' ? 'bKash অ্যাপ ওপেন করুন' : 'Nagad অ্যাপ ওপেন করুন'),"
)

# Inputs: Sender & TrxID
old_sender_lbl = """                                  Text(
                                    _paymentGateway == 'glowbay_bkash'
                                        ? 'আপনার বিকাশ নম্বর (যে নম্বর থেকে টাকা পাঠিয়েছেন) *'
                                        : (_paymentGateway == 'glowbay_nagad'
                                            ? 'আপনার নগদ নম্বর (যে নম্বর থেকে টাকা পাঠিয়েছেন) *'
                                            : (_paymentGateway == 'glowbay_bangla_qr'
                                                ? 'আপনার প্রেরক ফোন নম্বর / ব্যাংক অ্যাকাউন্ট নম্বর *'
                                                : 'ডিপোজিট রেফারেন্স / প্রেরক অ্যাকাউন্ট নাম *')),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936)),
                                  ),"""

new_sender_lbl = """                                  Text(
                                    isEn
                                        ? (_paymentGateway == 'glowbay_bkash'
                                            ? 'Your bKash Number (Used for Payment) *'
                                            : (_paymentGateway == 'glowbay_nagad'
                                                ? 'Your Nagad Number (Used for Payment) *'
                                                : (_paymentGateway == 'glowbay_bangla_qr'
                                                    ? 'Sender Phone / Bank Account Number *'
                                                    : 'Deposit Reference / Sender A/C Name *')))
                                        : (_paymentGateway == 'glowbay_bkash'
                                            ? 'আপনার বিকাশ নম্বর (যে নম্বর থেকে টাকা পাঠিয়েছেন) *'
                                            : (_paymentGateway == 'glowbay_nagad'
                                                ? 'আপনার নগদ নম্বর (যে নম্বর থেকে টাকা পাঠিয়েছেন) *'
                                                : (_paymentGateway == 'glowbay_bangla_qr'
                                                    ? 'আপনার প্রেরক ফোন নম্বর / ব্যাংক অ্যাকাউন্ট নম্বর *'
                                                    : 'ডিপোজিট রেফারেন্স / প্রেরক অ্যাকাউন্ট নাম *'))),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936)),
                                  ),"""

content = content.replace(old_sender_lbl, new_sender_lbl)

old_trx_lbl = """                                  Text(
                                    _paymentGateway == 'glowbay_bkash'
                                        ? 'বিকাশ Transaction ID (TrxID) *'
                                        : (_paymentGateway == 'glowbay_nagad'
                                            ? 'নগদ Transaction ID (TrxID) *'
                                            : (_paymentGateway == 'glowbay_bangla_qr'
                                                ? 'Transaction ID (TrxID) / রেফারেন্স নম্বর *'
                                                : 'ব্যাংক Transaction ID / Slip Ref *')),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936)),
                                  ),"""

new_trx_lbl = """                                  Text(
                                    isEn
                                        ? (_paymentGateway == 'glowbay_bkash'
                                            ? 'bKash Transaction ID (TrxID) *'
                                            : (_paymentGateway == 'glowbay_nagad'
                                                ? 'Nagad Transaction ID (TrxID) *'
                                                : (_paymentGateway == 'glowbay_bangla_qr'
                                                    ? 'Transaction ID (TrxID) / Reference *'
                                                    : 'Bank Transaction ID / Slip Ref *')))
                                        : (_paymentGateway == 'glowbay_bkash'
                                            ? 'বিকাশ Transaction ID (TrxID) *'
                                            : (_paymentGateway == 'glowbay_nagad'
                                                ? 'নগদ Transaction ID (TrxID) *'
                                                : (_paymentGateway == 'glowbay_bangla_qr'
                                                    ? 'Transaction ID (TrxID) / রেফারেন্স নম্বর *'
                                                    : 'ব্যাংক Transaction ID / Slip Ref *'))),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936)),
                                  ),"""

content = content.replace(old_trx_lbl, new_trx_lbl)

# Receipt upload
content = content.replace(
    "'পেমেন্ট রিসিটের স্ক্রিনশট আপলোড করুন * (বাধ্যতামূলক)',",
    "isEn ? 'Upload Payment Receipt Screenshot * (Mandatory)' : 'পেমেন্ট রিসিটের স্ক্রিনশট আপলোড করুন * (বাধ্যতামূলক)',"
)
content = content.replace(
    "Text('রিসিট নির্বাচিত হয়েছে ✓', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),",
    "Text(isEn ? 'Receipt Selected ✓' : 'রিসিট নির্বাচিত হয়েছে ✓', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),"
)
content = content.replace(
    "'রিসিটের স্ক্রিনশট নির্বাচন করতে ক্লিক করুন (JPG, PNG)',",
    "isEn ? 'Click to select receipt screenshot (JPG, PNG)' : 'রিসিটের স্ক্রিনশট নির্বাচন করতে ক্লিক করুন (JPG, PNG)',"
)
content = content.replace(
    "'(সর্বোচ্চ 5MB)',",
    "isEn ? '(Max 5MB)' : '(সর্বোচ্চ 5MB)',"
)

# CARD 6: TOTALS BREAKDOWN
content = content.replace(
    "'অর্ডারের মূল্য বিবরণী (Order Summary)',",
    "isEn ? 'Order Price Details (Order Summary)' : 'অর্ডারের মূল্য বিবরণী (Order Summary)',"
)
content = content.replace(
    "'পণ্যের মূল্য / Subtotal (${activeItems.length} টি আইটেম)',",
    "isEn ? 'Product Subtotal (${activeItems.length} Items)' : 'পণ্যের মূল্য / Subtotal (${activeItems.length} টি আইটেম)',"
)
content = content.replace(
    "'ডেলিভারি চার্জ (${isInsideDhaka ? 'ঢাকা' : 'ঢাকার বাইরে'} • ${totalWeightKg.toStringAsFixed(totalWeightKg.truncateToDouble() == totalWeightKg ? 0 : 1)} kg)',",
    "isEn ? 'Delivery Charge (${isInsideDhaka ? 'Dhaka' : 'Outside Dhaka'} • ${totalWeightKg.toStringAsFixed(totalWeightKg.truncateToDouble() == totalWeightKg ? 0 : 1)} kg)' : 'ডেলিভারি চার্জ (${isInsideDhaka ? 'ঢাকা' : 'ঢাকার বাইরে'} • ${totalWeightKg.toStringAsFixed(totalWeightKg.truncateToDouble() == totalWeightKg ? 0 : 1)} kg)',"
)
content = content.replace(
    "'ভাউচার ডিসকাউন্ট (Voucher)',",
    "isEn ? 'Voucher Discount' : 'ভাউচার ডিসকাউন্ট (Voucher)',"
)
content = content.replace(
    "'অর্ডারের সর্বমোট মূল্য (Total Order Value):',",
    "isEn ? 'Total Order Value:' : 'অর্ডারের সর্বমোট মূল্য (Total Order Value):',"
)

content = content.replace(
    "_paymentPlan == 'advance_50'\n                                       ? 'পেমেন্ট ব্রেকডাউন (৫০% অগ্রিম প্ল্যান)'\n                                       : 'পেমেন্ট ব্রেকডাউন (১০০% সম্পূর্ণ পরিশোধ)',",
    "_paymentPlan == 'advance_50' ? (isEn ? 'Payment Breakdown (50% Advance Plan)' : 'পেমেন্ট ব্রেকডাউন (৫০% অগ্রিম প্ল্যান)') : (isEn ? 'Payment Breakdown (100% Full Payment)' : 'পেমেন্ট ব্রেকডাউন (১০০% সম্পূর্ণ পরিশোধ)'),"
)
content = content.replace(
    "_paymentPlan == 'advance_50' ? '৫০% অগ্রিম মূল টাকা' : '১০০% ফুল পে মূল টাকা',",
    "_paymentPlan == 'advance_50' ? (isEn ? '50% Advance Base Amount' : '৫০% অগ্রিম মূল টাকা') : (isEn ? '100% Full Pay Base Amount' : '১০০% ফুল পে মূল টাকা'),"
)
content = content.replace(
    "'${_paymentGateway == 'glowbay_bkash' ? 'বিকাশ' : 'নগদ'} ক্যাশআউট ফি (${cashoutFeePct.toStringAsFixed(2)}%)',",
    "isEn ? '${_paymentGateway == 'glowbay_bkash' ? 'bKash' : 'Nagad'} Cashout Fee (${cashoutFeePct.toStringAsFixed(2)}%)' : '${_paymentGateway == 'glowbay_bkash' ? 'বিকাশ' : 'নগদ'} ক্যাশআউট ফি (${cashoutFeePct.toStringAsFixed(2)}%)',"
)
content = content.replace(
    "'বাংলা QR ক্যাশআউট চার্জ (০% ফি)',",
    "isEn ? 'Bangla QR Cashout Fee (0% Fee)' : 'বাংলা QR ক্যাশআউট চার্জ (০% ফি)',"
)
content = content.replace(
    "'৳০ (ফ্রি! 🎉)',",
    "isEn ? '৳0 (Free! 🎉)' : '৳০ (ফ্রি! 🎉)',"
)
content = content.replace(
    "'ব্যাংক ডিপোজিট চার্জ',",
    "isEn ? 'Bank Deposit Charge' : 'ব্যাংক ডিপোজিট চার্জ',"
)
content = content.replace(
    "'৳০ (ফ্রি)',",
    "isEn ? '৳0 (Free)' : '৳০ (ফ্রি)',"
)

content = content.replace(
    "'👉 আজ পরিশোধ করতে হবে:',",
    "isEn ? '👉 Payable Today:' : '👉 আজ পরিশোধ করতে হবে:',"
)
old_pay_today_sub = """                                      Text(
                                        _paymentPlan == 'advance_50'
                                            ? (cashoutFee > 0 ? '(৫০% অগ্রিম + ক্যাশআউট চার্জ)' : '(৫০% অগ্রিম)')
                                            : (cashoutFee > 0 ? '(১০০% ফুল + ক্যাশআউট চার্জ)' : '(১০০% সম্পূর্ণ পরিশোধ)'),
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF9F1239), fontWeight: FontWeight.w600),
                                      ),"""

new_pay_today_sub = """                                      Text(
                                        _paymentPlan == 'advance_50'
                                            ? (isEn
                                                ? (cashoutFee > 0 ? '(50% Advance + Cashout Fee)' : '(50% Advance)')
                                                : (cashoutFee > 0 ? '(৫০% অগ্রিম + ক্যাশআউট চার্জ)' : '(৫০% অগ্রিম)'))
                                            : (isEn
                                                ? (cashoutFee > 0 ? '(100% Full + Cashout Fee)' : '(100% Full Payment)')
                                                : (cashoutFee > 0 ? '(১০০% ফুল + ক্যাশআউট চার্জ)' : '(১০০% সম্পূর্ণ পরিশোধ)')),
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF9F1239), fontWeight: FontWeight.w600),
                                      ),"""

content = content.replace(old_pay_today_sub, new_pay_today_sub)

content = content.replace(
    "_paymentPlan == 'advance_50' ? '📦 ডেলিভারির সময় কুরিয়ারকে প্রদেয়:' : '📦 ডেলিভারির সময় প্রদেয়:',",
    "_paymentPlan == 'advance_50' ? (isEn ? '📦 Due on Delivery to Courier:' : '📦 ডেলিভারির সময় কুরিয়ারকে প্রদেয়:') : (isEn ? '📦 Due on Delivery:' : '📦 ডেলিভারির সময় প্রদেয়:'),"
)
content = content.replace(
    "_paymentPlan == 'advance_50' ? '৳${due50.toStringAsFixed(0)}' : '৳০ (ক্যাশলেস 🎉)',",
    "_paymentPlan == 'advance_50' ? '৳${due50.toStringAsFixed(0)}' : (isEn ? '৳0 (Cashless 🎉)' : '৳০ (ক্যাশলেস 🎉)'),"
)

# Bottom bar
old_bottom_total = """                Text(
                  _paymentPlan == 'advance_50'
                      ? (cashoutFee > 0 ? 'Total Payable (৫০% অগ্রিম + চার্জ):' : 'Total Payable (৫০% অগ্রিম):')
                      : (cashoutFee > 0 ? 'Total Payable (১০০% ফুল + চার্জ):' : 'Total Payable (১০০% ফুল):'),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                ),"""

new_bottom_total = """                Text(
                  _paymentPlan == 'advance_50'
                      ? (isEn
                          ? (cashoutFee > 0 ? 'Total Payable (50% Advance + Fee):' : 'Total Payable (50% Advance):')
                          : (cashoutFee > 0 ? 'Total Payable (৫০% অগ্রিম + চার্জ):' : 'Total Payable (৫০% অগ্রিম):'))
                      : (isEn
                          ? (cashoutFee > 0 ? 'Total Payable (100% Full + Fee):' : 'Total Payable (100% Full):')
                          : (cashoutFee > 0 ? 'Total Payable (১০০% ফুল + চার্জ):' : 'Total Payable (১০০% ফুল):')),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                ),"""

content = content.replace(old_bottom_total, new_bottom_total)

content = content.replace(
    "_paymentPlan == 'advance_50' ? 'অর্ডার সম্পন্ন করুন (৫০% অগ্রিম)' : 'অর্ডার সম্পন্ন করুন (১০০% ফুল)',",
    "_paymentPlan == 'advance_50' ? (isEn ? 'Place Order (50% Advance)' : 'অর্ডার সম্পন্ন করুন (৫০% অগ্রিম)') : (isEn ? 'Place Order (100% Full Pay)' : 'অর্ডার সম্পন্ন করুন (১০০% ফুল)'),"
)

# Address edit modal sheet
content = content.replace(
    "Text('ডেলিভারি ঠিকানা আপডেট করুন', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF101936))),",
    "Text(isEn ? 'Update Delivery Address' : 'ডেলিভারি ঠিকানা আপডেট করুন', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF101936))),"
)
content = content.replace(
    "decoration: _inputDeco('গ্রাহকের পূর্ণ নাম (Full Name) *', Icons.person_outline),",
    "decoration: _inputDeco(isEn ? 'Customer Full Name *' : 'গ্রাহকের পূর্ণ নাম (Full Name) *', Icons.person_outline),"
)
content = content.replace(
    "decoration: _inputDeco('মোবাইল নম্বর *', Icons.phone_outlined),",
    "decoration: _inputDeco(isEn ? 'Mobile Phone *' : 'মোবাইল নম্বর *', Icons.phone_outlined),"
)
content = content.replace(
    "decoration: _inputDeco('হোয়াটসঅ্যাপ নম্বর *', Icons.chat_outlined),",
    "decoration: _inputDeco(isEn ? 'WhatsApp Number *' : 'হোয়াটসঅ্যাপ নম্বর *', Icons.chat_outlined),"
)
content = content.replace(
    "decoration: _inputDeco('বিল্ডিং / ফ্ল্যাট *', Icons.apartment_outlined),",
    "decoration: _inputDeco(isEn ? 'Building / Flat *' : 'বিল্ডিং / ফ্ল্যাট *', Icons.apartment_outlined),"
)
content = content.replace(
    "decoration: _inputDeco('রোড / ব্লক *', Icons.signpost_outlined),",
    "decoration: _inputDeco(isEn ? 'Road / Block *' : 'রোড / ব্লক *', Icons.signpost_outlined),"
)
content = content.replace(
    "decoration: _inputDeco('এলাকা / মহল্লা * (যেমন: Dhanmondi / Mirpur)', Icons.explore_outlined),",
    "decoration: _inputDeco(isEn ? 'Area / Landmark * (e.g. Dhanmondi / Mirpur)' : 'এলাকা / মহল্লা * (যেমন: Dhanmondi / Mirpur)', Icons.explore_outlined),"
)
content = content.replace(
    "decoration: _inputDeco('বিভাগ (Division) *', Icons.map_outlined),",
    "decoration: _inputDeco(isEn ? 'Division *' : 'বিভাগ (Division) *', Icons.map_outlined),"
)
content = content.replace(
    "decoration: _inputDeco('জেলা *', Icons.location_city_outlined),",
    "decoration: _inputDeco(isEn ? 'District *' : 'জেলা *', Icons.location_city_outlined),"
)
content = content.replace(
    "decoration: _inputDeco('থানা / উপজেলা *', Icons.place_outlined),",
    "decoration: _inputDeco(isEn ? 'Thana / Upazila *' : 'থানা / উপজেলা *', Icons.place_outlined),"
)
content = content.replace(
    "decoration: _inputDeco('পোস্টকোড * (যেমন: 1216)', Icons.markunread_mailbox_outlined),",
    "decoration: _inputDeco(isEn ? 'Postcode * (e.g. 1216)' : 'পোস্টকোড * (যেমন: 1216)', Icons.markunread_mailbox_outlined),"
)
content = content.replace(
    "child: const Text('সংরক্ষণ ও ব্যবহার করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),",
    "child: Text(isEn ? 'Save & Use Address' : 'সংরক্ষণ ও ব্যবহার করুন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),"
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Batch 2 completed successfully")
