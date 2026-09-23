with open('lib/presentation/screens/checkout/checkout_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

changes = 0

old_str1 = "'বিকাশে ১.৮৫% ক্যাশআউট চার্জ প্রযোজ্য (৳${cashoutFee.toStringAsFixed(0)})। '"
new_str1 = "(isEn ? 'bKash 1.85% fee applies (৳${cashoutFee.toStringAsFixed(0)}). ' : 'বিকাশে ১.৮৫% ক্যাশআউট চার্জ প্রযোজ্য (৳${cashoutFee.toStringAsFixed(0)})। ')"
if old_str1 in text:
    text = text.replace(old_str1, new_str1)
    changes += 1

old_str2 = "'নগদে ১.৫% ক্যাশআউট চার্জ প্রযোজ্য (৳${cashoutFee.toStringAsFixed(0)})। '"
new_str2 = "(isEn ? 'Nagad 1.5% fee applies (৳${cashoutFee.toStringAsFixed(0)}). ' : 'নগদে ১.৫% ক্যাশআউট চার্জ প্রযোজ্য (৳${cashoutFee.toStringAsFixed(0)})। ')"
if old_str2 in text:
    text = text.replace(old_str2, new_str2)
    changes += 1

old_str3 = "text: 'চার্জ এড়াতে চাইলে বাংলা QR বেছে নিন — ০% ক্যাশআউট চার্জ (৳০ ফি)!'"
new_str3 = "text: isEn ? 'To avoid fee, choose Bangla QR — 0% cashout fee (৳0 fee)!' : 'চার্জ এড়াতে চাইলে বাংলা QR বেছে নিন — ০% ক্যাশআউট চার্জ (৳০ ফি)!'"
if old_str3 in text:
    text = text.replace(old_str3, new_str3)
    changes += 1

old_str4 = "Text('ব্যাংক: ${paymentSettings.banglaQrBankName}'"
new_str4 = "Text(isEn ? 'Bank: ${paymentSettings.banglaQrBankName}' : 'ব্যাংক: ${paymentSettings.banglaQrBankName}'"
if old_str4 in text:
    text = text.replace(old_str4, new_str4)
    changes += 1

old_str5 = "Text('অ্যাকাউন্ট নাম: ${paymentSettings.banglaQrAccountName}'"
new_str5 = "Text(isEn ? 'Account Name: ${paymentSettings.banglaQrAccountName}' : 'অ্যাকাউন্ট নাম: ${paymentSettings.banglaQrAccountName}'"
if old_str5 in text:
    text = text.replace(old_str5, new_str5)
    changes += 1

old_str6 = "Text('শাখা: ${paymentSettings.banglaQrBranchName}'"
new_str6 = "Text(isEn ? 'Branch: ${paymentSettings.banglaQrBranchName}' : 'শাখা: ${paymentSettings.banglaQrBranchName}'"
if old_str6 in text:
    text = text.replace(old_str6, new_str6)
    changes += 1

old_str7 = "Text('অ্যাকাউন্ট নাম: ${paymentSettings.accountName}'"
new_str7 = "Text(isEn ? 'Account Name: ${paymentSettings.accountName}' : 'অ্যাকাউন্ট নাম: ${paymentSettings.accountName}'"
if old_str7 in text:
    text = text.replace(old_str7, new_str7)
    changes += 1

old_str8 = "Text('শাখা: ${paymentSettings.branchName}'"
new_str8 = "Text(isEn ? 'Branch: ${paymentSettings.branchName}' : 'শাখা: ${paymentSettings.branchName}'"
if old_str8 in text:
    text = text.replace(old_str8, new_str8)
    changes += 1

old_str9 = "Text(\n                                                      'বড় করুন',"
new_str9 = "Text(\n                                                      isEn ? 'Enlarge' : 'বড় করুন',"
if old_str9 in text:
    text = text.replace(old_str9, new_str9)
    changes += 1
elif "'বড় করুন'" in text:
    text = text.replace("'বড় করুন'", "isEn ? 'Enlarge' : 'বড় করুন'")
    changes += 1

old_str10 = "'প্রদেয় ৫০% অগ্রিম + চার্জ:'"
new_str10 = "(isEn ? 'Payable (50% Adv + Fee):' : 'প্রদেয় ৫০% অগ্রিম + চার্জ:')"
if old_str10 in text:
    text = text.replace(old_str10, new_str10)
    changes += 1

old_str11 = "'প্রদেয় ৫০% অগ্রিম:'"
new_str11 = "(isEn ? 'Payable (50% Adv):' : 'প্রদেয় ৫০% অগ্রিম:')"
if old_str11 in text:
    text = text.replace(old_str11, new_str11)
    changes += 1

old_str12 = "'প্রদেয় ১০০% ফুল + চার্জ:'"
new_str12 = "(isEn ? 'Payable (100% Full + Fee):' : 'প্রদেয় ১০০% ফুল + চার্জ:')"
if old_str12 in text:
    text = text.replace(old_str12, new_str12)
    changes += 1

old_str13 = "'প্রদেয় ১০০% ফুল:'"
new_str13 = "(isEn ? 'Payable (100% Full):' : 'প্রদেয় ১০০% ফুল:')"
if old_str13 in text:
    text = text.replace(old_str13, new_str13)
    changes += 1

print(f"Applied {changes} changes")

with open('lib/presentation/screens/checkout/checkout_screen.dart', 'w', encoding='utf-8', newline='') as f:
    f.write(text)
