with open('lib/presentation/screens/checkout/checkout_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Bangla QR brandTitle
old_bqr = "(gateway == 'glowbay_bangla_qr' ? 'বাংলা QR (সমন্বিত পেমেন্ট)' : 'Bank Transfer QR')"
new_bqr = "(gateway == 'glowbay_bangla_qr' ? (context.read<LanguageProvider>().isEnglish ? 'Bangla QR (Integrated Payment)' : 'বাংলা QR (সমন্বিত পেমেন্ট)') : 'Bank Transfer QR')"
if old_bqr in text:
    text = text.replace(old_bqr, new_bqr)
    print("Fixed bqr brandTitle")

# 2. QR modal number label
old_lbl = """                          gateway == 'glowbay_bkash'
                              ? 'বিকাশ নম্বর'
                              : (gateway == 'glowbay_nagad'
                                  ? 'নগদ নম্বর'
                                  : (gateway == 'glowbay_bangla_qr' ? 'বাংলা QR / ব্যাংক হিসাব নম্বর' : 'অ্যাকাউন্ট নম্বর')),"""
new_lbl = """                          context.read<LanguageProvider>().isEnglish
                              ? (gateway == 'glowbay_bkash'
                                  ? 'bKash Number'
                                  : (gateway == 'glowbay_nagad'
                                      ? 'Nagad Number'
                                      : (gateway == 'glowbay_bangla_qr' ? 'Bangla QR / Bank A/C Number' : 'Account Number')))
                              : (gateway == 'glowbay_bkash'
                                  ? 'বিকাশ নম্বর'
                                  : (gateway == 'glowbay_nagad'
                                      ? 'নগদ নম্বর'
                                      : (gateway == 'glowbay_bangla_qr' ? 'বাংলা QR / ব্যাংক হিসাব নম্বর' : 'অ্যাকাউন্ট নম্বর'))),"""
if old_lbl in text:
    text = text.replace(old_lbl, new_lbl)
    print("Fixed modal number label (LF)")
elif old_lbl.replace('\n', '\r\n') in text:
    text = text.replace(old_lbl.replace('\n', '\r\n'), new_lbl.replace('\n', '\r\n'))
    print("Fixed modal number label (CRLF)")

# 3. Fee callout in gateway selector
old_fee_callout = """                                                      _paymentGateway == 'glowbay_bkash'
                                                          ? 'বিকাশে ১.৮৫% ক্যাশআউট চার্জ প্রযোজ্য (৳${cashoutFee.toStringAsFixed(0)})। '
                                                          : 'নগদে ১.৫% ক্যাশআউট চার্জ প্রযোজ্য (৳${cashoutFee.toStringAsFixed(0)})। ',"""
new_fee_callout = """                                                      isEn
                                                          ? (_paymentGateway == 'glowbay_bkash'
                                                              ? 'bKash 1.85% cashout fee applies (৳${cashoutFee.toStringAsFixed(0)}). '
                                                              : 'Nagad 1.5% cashout fee applies (৳${cashoutFee.toStringAsFixed(0)}). ')
                                                          : (_paymentGateway == 'glowbay_bkash'
                                                              ? 'বিকাশে ১.৮৫% ক্যাশআউট চার্জ প্রযোজ্য (৳${cashoutFee.toStringAsFixed(0)})। '
                                                              : 'নগদে ১.৫% ক্যাশআউট চার্জ প্রযোজ্য (৳${cashoutFee.toStringAsFixed(0)})। '),"""
if old_fee_callout in text:
    text = text.replace(old_fee_callout, new_fee_callout)
    print("Fixed fee callout (LF)")
elif old_fee_callout.replace('\n', '\r\n') in text:
    text = text.replace(old_fee_callout.replace('\n', '\r\n'), new_fee_callout.replace('\n', '\r\n'))
    print("Fixed fee callout (CRLF)")

# 4. Avoid fee tip
old_avoid = "text: 'চার্জ এড়াতে চাইলে বাংলা QR বেছে নিন — ০% ক্যাশআউট চার্জ (৳০ ফি)!',"
new_avoid = "text: isEn ? 'To avoid fees, choose Bangla QR — 0% cashout charge (৳0 fee)!' : 'চার্জ এড়াতে চাইলে বাংলা QR বেছে নিন — ০% ক্যাশআউট চার্জ (৳০ ফি)!',"
if old_avoid in text:
    text = text.replace(old_avoid, new_avoid)
    print("Fixed avoid fee tip")

# 5. Bangla QR Bank / Account details
old_bqr_details = """                                                Text('ব্যাংক: ${paymentSettings.banglaQrBankName}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                                                Text('অ্যাকাউন্ট নাম: ${paymentSettings.banglaQrAccountName}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF101936))),
                                                Text('শাখা: ${paymentSettings.banglaQrBranchName}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),"""
new_bqr_details = """                                                Text(isEn ? 'Bank: ${paymentSettings.banglaQrBankName}' : 'ব্যাংক: ${paymentSettings.banglaQrBankName}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                                                Text(isEn ? 'Account Name: ${paymentSettings.banglaQrAccountName}' : 'অ্যাকাউন্ট নাম: ${paymentSettings.banglaQrAccountName}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF101936))),
                                                Text(isEn ? 'Branch: ${paymentSettings.banglaQrBranchName}' : 'শাখা: ${paymentSettings.banglaQrBranchName}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),"""
if old_bqr_details in text:
    text = text.replace(old_bqr_details, new_bqr_details)
    print("Fixed bqr details (LF)")
elif old_bqr_details.replace('\n', '\r\n') in text:
    text = text.replace(old_bqr_details.replace('\n', '\r\n'), new_bqr_details.replace('\n', '\r\n'))
    print("Fixed bqr details (CRLF)")

# 6. Gateway details bank/account type
old_ac_details = """                                                Text(
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
new_ac_details = """                                                Text(
                                                  _paymentGateway == 'glowbay_bkash'
                                                      ? (isEn ? 'Account Type: bKash ${paymentSettings.bkashType}' : 'অ্যাকাউন্ট টাইপ: bKash ${paymentSettings.bkashType}')
                                                      : (_paymentGateway == 'glowbay_nagad'
                                                          ? (isEn ? 'Account Type: Nagad ${paymentSettings.nagadType}' : 'অ্যাকাউন্ট টাইপ: Nagad ${paymentSettings.nagadType}')
                                                          : (isEn ? 'Bank Name: ${paymentSettings.bankName}' : 'ব্যাংক নাম: ${paymentSettings.bankName}')),
                                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w600),
                                                ),
                                                if (_paymentGateway == 'glowbay_bank') ...[
                                                  const SizedBox(height: 2),
                                                  Text(isEn ? 'Account Name: ${paymentSettings.accountName}' : 'অ্যাকাউন্ট নাম: ${paymentSettings.accountName}',
                                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF101936))),
                                                  Text(isEn ? 'Branch: ${paymentSettings.branchName}' : 'শাখা: ${paymentSettings.branchName}',
                                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                                ],"""
if old_ac_details in text:
    text = text.replace(old_ac_details, new_ac_details)
    print("Fixed account details (LF)")
elif old_ac_details.replace('\n', '\r\n') in text:
    text = text.replace(old_ac_details.replace('\n', '\r\n'), new_ac_details.replace('\n', '\r\n'))
    print("Fixed account details (CRLF)")

# 7. Copied snackbar
old_copy_snack = "content: Text('${_paymentGateway == 'glowbay_bkash' ? 'বিকাশ' : (_paymentGateway == 'glowbay_nagad' ? 'নগদ' : 'অ্যাকাউন্ট')} নম্বর ক্লিপবোর্ডে কপি করা হয়েছে!'),"
new_copy_snack = "content: Text(isEn ? 'Number copied to clipboard!' : '${_paymentGateway == 'glowbay_bkash' ? 'বিকাশ' : (_paymentGateway == 'glowbay_nagad' ? 'নগদ' : 'অ্যাকাউন্ট')} নম্বর ক্লিপবোর্ডে কপি করা হয়েছে!'),"
if old_copy_snack in text:
    text = text.replace(old_copy_snack, new_copy_snack)
    print("Fixed copy snack")

# 8. Enlarge QR
old_enlarge = """                                                    Text(
                                                      'বড় করুন',"""
new_enlarge = """                                                    Text(
                                                      isEn ? 'Enlarge' : 'বড় করুন',"""
if old_enlarge in text:
    text = text.replace(old_enlarge, new_enlarge)
    print("Fixed enlarge (LF)")
elif old_enlarge.replace('\n', '\r\n') in text:
    text = text.replace(old_enlarge.replace('\n', '\r\n'), new_enlarge.replace('\n', '\r\n'))
    print("Fixed enlarge (CRLF)")

# 9. Split pill card
old_split = """                                                Text(
                                                  _paymentPlan == 'advance_50'
                                                      ? (cashoutFee > 0 ? 'প্রদেয় ৫০% অগ্রিম + চার্জ:' : 'প্রদেয় ৫০% অগ্রিম:')
                                                      : (cashoutFee > 0 ? 'প্রদেয় ১০০% ফুল + চার্জ:' : 'প্রদেয় ১০০% ফুল:'),
                                                  style: const TextStyle(fontSize: 11, color: Color(0xFF101936), fontWeight: FontWeight.w600),
                                                ),"""
new_split = """                                                Text(
                                                  _paymentPlan == 'advance_50'
                                                      ? (isEn
                                                          ? (cashoutFee > 0 ? 'Payable (50% Adv + Fee):' : 'Payable (50% Advance):')
                                                          : (cashoutFee > 0 ? 'প্রদেয় ৫০% অগ্রিম + চার্জ:' : 'প্রদেয় ৫০% অগ্রিম:'))
                                                      : (isEn
                                                          ? (cashoutFee > 0 ? 'Payable (100% Full + Fee):' : 'Payable (100% Full):')
                                                          : (cashoutFee > 0 ? 'প্রদেয় ১০০% ফুল + চার্জ:' : 'প্রদেয় ১০০% ফুল:')),
                                                  style: const TextStyle(fontSize: 11, color: Color(0xFF101936), fontWeight: FontWeight.w600),
                                                ),"""
if old_split in text:
    text = text.replace(old_split, new_split)
    print("Fixed split pill (LF)")
elif old_split.replace('\n', '\r\n') in text:
    text = text.replace(old_split.replace('\n', '\r\n'), new_split.replace('\n', '\r\n'))
    print("Fixed split pill (CRLF)")

with open('lib/presentation/screens/checkout/checkout_screen.dart', 'w', encoding='utf-8', newline='') as f:
    f.write(text)

print("Checkout polish done")
