with open('lib/presentation/screens/checkout/checkout_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Line 448
old_448 = """              const Text(
                context.read<LanguageProvider>().isEnglish ? 'Scan directly with any mobile or banking app to pay' : 'যেকোনো ফোন বা অ্যাপ দিয়ে সরাসরি স্ক্যান করে পেমেন্ট করুন',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              ),"""
new_448 = """              Text(
                context.read<LanguageProvider>().isEnglish ? 'Scan directly with any mobile or banking app to pay' : 'যেকোনো ফোন বা অ্যাপ দিয়ে সরাসরি স্ক্যান করে পেমেন্ট করুন',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              ),"""
if old_448 in text:
    text = text.replace(old_448, new_448)
    print("Fixed 448 (LF)")
elif old_448.replace('\n', '\r\n') in text:
    text = text.replace(old_448.replace('\n', '\r\n'), new_448.replace('\n', '\r\n'))
    print("Fixed 448 (CRLF)")
else:
    print("448 NOT found")

# 2. Line 1040
old_1040 = """                                        const Row(
                                          children: [
                                            Icon(Icons.bolt, size: 16, color: Color(0xFFFF2D78)),
                                            SizedBox(width: 4),
                                            Text(
                                              isEn ? 'Pre-Order Home Delivery' : 'প্রি-অর্ডার হোম ডেলিভারি',
                                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF101936)),
                                            ),
                                          ],
                                        ),"""
new_1040 = """                                        Row(
                                          children: [
                                            const Icon(Icons.bolt, size: 16, color: Color(0xFFFF2D78)),
                                            const SizedBox(width: 4),
                                            Text(
                                              isEn ? 'Pre-Order Home Delivery' : 'প্রি-অর্ডার হোম ডেলিভারি',
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF101936)),
                                            ),
                                          ],
                                        ),"""
if old_1040 in text:
    text = text.replace(old_1040, new_1040)
    print("Fixed 1040 (LF)")
elif old_1040.replace('\n', '\r\n') in text:
    text = text.replace(old_1040.replace('\n', '\r\n'), new_1040.replace('\n', '\r\n'))
    print("Fixed 1040 (CRLF)")
else:
    print("1040 NOT found")

# 3. Line 1131
old_1131 = """                            const Text(
                              isEn ? '1. Select Payment Plan:' : '১. পেমেন্ট প্ল্যান বেছে নিন (Select Payment Plan):',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),"""
new_1131 = """                            Text(
                              isEn ? '1. Select Payment Plan:' : '১. পেমেন্ট প্ল্যান বেছে নিন (Select Payment Plan):',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),"""
if old_1131 in text:
    text = text.replace(old_1131, new_1131)
    print("Fixed 1131 (LF)")
elif old_1131.replace('\n', '\r\n') in text:
    text = text.replace(old_1131.replace('\n', '\r\n'), new_1131.replace('\n', '\r\n'))
    print("Fixed 1131 (CRLF)")
else:
    print("1131 NOT found")

# 4. Line 1258
old_1258 = """                            const Text(
                              isEn ? '2. Select Payment Method:' : '২. পেমেন্ট মেথড বেছে নিন (Payment Method):',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),"""
new_1258 = """                            Text(
                              isEn ? '2. Select Payment Method:' : '২. পেমেন্ট মেথড বেছে নিন (Payment Method):',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),"""
if old_1258 in text:
    text = text.replace(old_1258, new_1258)
    print("Fixed 1258 (LF)")
elif old_1258.replace('\n', '\r\n') in text:
    text = text.replace(old_1258.replace('\n', '\r\n'), new_1258.replace('\n', '\r\n'))
    print("Fixed 1258 (CRLF)")
else:
    print("1258 NOT found")

# 5. Lines 1296-1307
old_1296 = """                                          Text(
                                          Text(isEn ? 'No Cashout Charge on Bangla QR (৳0 Fee / 0% Extra)!' : 'বাংলা QR-এ কোনো ক্যাশআউট চার্জ নেই (৳০ ফি / ০% এক্সট্রা)!',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isEn
                                                ? 'Scan directly using bKash, Nagad, CellFin, Rocket or any banking app with zero extra fees.'
                                          Text(isEn ? 'Scan directly using bKash, Nagad, CellFin, Rocket or any banking app with zero extra fees.' : 'বিকাশ, নগদ, সেলফিন, রকেট বা যেকোনো ব্যাংক অ্যাপ দিয়ে সরাসরি স্ক্যান করে অতিরিক্ত খরচ ছাড়াই পেমেন্ট করুন।',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF047857), height: 1.35),
                                          ),"""
new_1296 = """                                          Text(
                                            isEn ? 'No Cashout Charge on Bangla QR (৳0 Fee / 0% Extra)!' : 'বাংলা QR-এ কোনো ক্যাশআউট চার্জ নেই (৳০ ফি / ০% এক্সট্রা)!',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isEn ? 'Scan directly using bKash, Nagad, CellFin, Rocket or any banking app with zero extra fees.' : 'বিকাশ, নগদ, সেলফিন, রকেট বা যেকোনো ব্যাংক অ্যাপ দিয়ে সরাসরি স্ক্যান করে অতিরিক্ত খরচ ছাড়াই পেমেন্ট করুন।',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF047857), height: 1.35),
                                          ),"""
if old_1296 in text:
    text = text.replace(old_1296, new_1296)
    print("Fixed 1296 (LF)")
elif old_1296.replace('\n', '\r\n') in text:
    text = text.replace(old_1296.replace('\n', '\r\n'), new_1296.replace('\n', '\r\n'))
    print("Fixed 1296 (CRLF)")
else:
    print("1296 NOT found")

# 6. Line 1465
old_1465 = """                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.copy_rounded, size: 12, color: Color(0xFF101936)),
                                                        SizedBox(width: 4),
                                                        Text(isEn ? 'Copy' : 'কপি', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936))),
                                                      ],
                                                    ),"""
new_1465 = """                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.copy_rounded, size: 12, color: Color(0xFF101936)),
                                                        const SizedBox(width: 4),
                                                        Text(isEn ? 'Copy' : 'কপি', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936))),
                                                      ],
                                                    ),"""
if old_1465 in text:
    text = text.replace(old_1465, new_1465)
    print("Fixed 1465 (LF)")
elif old_1465.replace('\n', '\r\n') in text:
    text = text.replace(old_1465.replace('\n', '\r\n'), new_1465.replace('\n', '\r\n'))
    print("Fixed 1465 (CRLF)")
else:
    print("1465 NOT found")

with open('lib/presentation/screens/checkout/checkout_screen.dart', 'w', encoding='utf-8', newline='') as f:
    f.write(text)

print("Finished writing fixes")
