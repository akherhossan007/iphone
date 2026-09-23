class PaymentSettingsModel {
  final String bkashNumber;
  final String bkashType;
  final bool bkashEnabled;
  final bool bkashEnableCashoutFee;
  final double bkashCashoutFeePct;
  final String bkashInstruction;

  final String nagadNumber;
  final String nagadType;
  final bool nagadEnabled;
  final bool nagadEnableCashoutFee;
  final double nagadCashoutFeePct;
  final String nagadInstruction;

  final String bankName;
  final String accountName;
  final String accountNo;
  final String branchName;
  final bool bankEnabled;
  final String bankInstruction;

  // Bangla QR (Islami Bank)
  final bool banglaQrEnabled;
  final String banglaQrTitle;
  final String banglaQrBankName;
  final String banglaQrAccountName;
  final String banglaQrAccountNo;
  final String banglaQrBranchName;
  final String banglaQrMerchantId;
  final String banglaQrTerminalId;
  final String banglaQrImageUrl;
  final List<String> banglaQrSupportedApps;
  final String banglaQrInstruction;

  const PaymentSettingsModel({
    this.bkashNumber = '01624810710',
    this.bkashType = 'Personal',
    this.bkashEnabled = true,
    this.bkashEnableCashoutFee = true,
    this.bkashCashoutFeePct = 1.85,
    this.bkashInstruction = 'Please send money to this bKash number and enter TrxID below.',
    this.nagadNumber = '01624810710',
    this.nagadType = 'Personal',
    this.nagadEnabled = true,
    this.nagadEnableCashoutFee = true,
    this.nagadCashoutFeePct = 1.5,
    this.nagadInstruction = 'Please send money to this Nagad number and enter TrxID below.',
    this.bankName = 'Islami Bank Bangladesh PLC',
    this.accountName = 'GlowBay BD',
    this.accountNo = '20501510100431002',
    this.branchName = 'Amin Bazar, Dhaka',
    this.bankEnabled = true,
    this.bankInstruction = 'Please deposit or transfer to the account above and enter receipt details.',
    this.banglaQrEnabled = true,
    this.banglaQrTitle = 'বাংলা কিউআর - ইসলামী ব্যাংক (Bangla QR)',
    this.banglaQrBankName = 'Islami Bank Bangladesh PLC',
    this.banglaQrAccountName = 'GlowBay BD',
    this.banglaQrAccountNo = '20501510100431002',
    this.banglaQrBranchName = 'Amin Bazar, Dhaka',
    this.banglaQrMerchantId = '',
    this.banglaQrTerminalId = '',
    this.banglaQrImageUrl = '',
    this.banglaQrSupportedApps = const ['bKash', 'Nagad', 'Rocket', 'Upay', 'Cellfin', 'VISA', 'Mastercard'],
    this.banglaQrInstruction = 'বিকাশ, নগদ, সেলফিন বা যেকোনো ব্যাংক অ্যাপ দিয়ে কিউআর স্ক্যান করে পেমেন্ট করুন।',
  });

  factory PaymentSettingsModel.fromJson(Map<String, dynamic> json) {
    final bkash = json['bkash'] is Map<String, dynamic> ? json['bkash'] as Map<String, dynamic> : {};
    final nagad = json['nagad'] is Map<String, dynamic> ? json['nagad'] as Map<String, dynamic> : {};
    final bank = json['bank'] is Map<String, dynamic> ? json['bank'] as Map<String, dynamic> : {};
    final bqr = json['bangla_qr'] is Map<String, dynamic> ? json['bangla_qr'] as Map<String, dynamic> : {};

    List<String> parseApps(dynamic list) {
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
      return const ['bKash', 'Nagad', 'Rocket', 'Upay', 'Cellfin', 'VISA', 'Mastercard'];
    }

    return PaymentSettingsModel(
      bkashNumber: (bkash['number']?.toString().isNotEmpty == true)
          ? bkash['number'].toString()
          : '01624810710',
      bkashType: bkash['type']?.toString() ?? 'Personal',
      bkashEnabled: bkash['is_active'] != false,
      bkashEnableCashoutFee: bkash['enable_cashout_fee'] != false,
      bkashCashoutFeePct: double.tryParse(bkash['cashout_fee_pct']?.toString() ?? '1.85') ?? 1.85,
      bkashInstruction: bkash['instruction']?.toString() ??
          'Please send money to this bKash number and enter TrxID below.',
      nagadNumber: (nagad['number']?.toString().isNotEmpty == true)
          ? nagad['number'].toString()
          : '01624810710',
      nagadType: nagad['type']?.toString() ?? 'Personal',
      nagadEnabled: nagad['is_active'] != false,
      nagadEnableCashoutFee: nagad['enable_cashout_fee'] != false,
      nagadCashoutFeePct: double.tryParse(nagad['cashout_fee_pct']?.toString() ?? '1.5') ?? 1.5,
      nagadInstruction: nagad['instruction']?.toString() ??
          'Please send money to this Nagad number and enter TrxID below.',
      bankName: bank['bank_name']?.toString() ?? 'Islami Bank Bangladesh PLC',
      accountName: bank['account_name']?.toString() ?? 'GlowBay BD',
      accountNo: (bank['account_no']?.toString().isNotEmpty == true)
          ? bank['account_no'].toString()
          : '20501510100431002',
      branchName: bank['branch_name']?.toString() ?? 'Amin Bazar, Dhaka',
      bankEnabled: bank['is_active'] != false,
      bankInstruction: bank['instruction']?.toString() ??
          'Please deposit or transfer to the account above and enter receipt details.',
      banglaQrEnabled: bqr['is_active'] != false,
      banglaQrTitle: bqr['title']?.toString() ?? 'বাংলা কিউআর - ইসলামী ব্যাংক (Bangla QR)',
      banglaQrBankName: bqr['bank_name']?.toString() ?? 'Islami Bank Bangladesh PLC',
      banglaQrAccountName: bqr['account_name']?.toString() ?? 'GlowBay BD',
      banglaQrAccountNo: bqr['account_no']?.toString() ?? '20501510100431002',
      banglaQrBranchName: bqr['branch_name']?.toString() ?? 'Amin Bazar, Dhaka',
      banglaQrMerchantId: bqr['merchant_id']?.toString() ?? '',
      banglaQrTerminalId: bqr['terminal_id']?.toString() ?? '',
      banglaQrImageUrl: bqr['qr_image_url']?.toString() ?? '',
      banglaQrSupportedApps: parseApps(bqr['supported_apps']),
      banglaQrInstruction: bqr['instruction']?.toString() ??
          'বিকাশ, নগদ, সেলফিন বা যেকোনো ব্যাংক অ্যাপ দিয়ে কিউআর স্ক্যান করে পেমেন্ট করুন।',
    );
  }

  factory PaymentSettingsModel.initial() => const PaymentSettingsModel();

  String getBkashTitle(bool isEn) => isEn ? 'bKash' : 'বিকাশ (bKash)';
  String getNagadTitle(bool isEn) => isEn ? 'Nagad' : 'নগদ (Nagad)';
  String getBankTitle(bool isEn) => isEn ? 'Bank Transfer' : 'ব্যাংক ট্রান্সফার';
  String getCodTitle(bool isEn) => isEn ? 'Cash on Delivery (50% Advance)' : 'ক্যাশ অন ডেলিভারি (৫০% অগ্রিম)';

  String getBkashInstruction(bool isEn) {
    if (isEn) {
      return (bkashInstruction.contains('আমাদের') || bkashInstruction.contains('বিকাশ নম্বরে'))
          ? 'Please send money to this bKash number and enter TrxID below.'
          : bkashInstruction;
    } else {
      return (bkashInstruction.contains('Please send money'))
          ? 'আমাদের বিকাশ নম্বরে সেন্ড মানি করুন এবং নিচে TrxID দিন।'
          : bkashInstruction;
    }
  }

  String getNagadInstruction(bool isEn) {
    if (isEn) {
      return (nagadInstruction.contains('আমাদের') || nagadInstruction.contains('নগদ নম্বরে'))
          ? 'Please send money to this Nagad number and enter TrxID below.'
          : nagadInstruction;
    } else {
      return (nagadInstruction.contains('Please send money'))
          ? 'আমাদের নগদ নম্বরে সেন্ড মানি করুন এবং নিচে TrxID দিন।'
          : nagadInstruction;
    }
  }

  String getBankInstruction(bool isEn) {
    if (isEn) {
      return (bankInstruction.contains('উপরে উল্লেখিত'))
          ? 'Please deposit or transfer to the account above and enter receipt details.'
          : bankInstruction;
    } else {
      return (bankInstruction.contains('Please deposit'))
          ? 'উপরে উল্লেখিত ব্যাংক অ্যাকাউন্টে ডিপোজিট করে রসিদের তথ্য দিন।'
          : bankInstruction;
    }
  }

  String getBanglaQrTitle(bool isEn) {
    if (isEn) {
      return (banglaQrTitle.contains('বাংলা') || banglaQrTitle.contains('কিউআর'))
          ? 'Bangla QR - Islami Bank PLC'
          : banglaQrTitle;
    } else {
      return (!banglaQrTitle.contains('বাংলা'))
          ? 'বাংলা কিউআর - ইসলামী ব্যাংক (Bangla QR)'
          : banglaQrTitle;
    }
  }

  String getBanglaQrInstruction(bool isEn) {
    if (isEn) {
      return (banglaQrInstruction.contains('বিকাশ') || banglaQrInstruction.contains('স্ক্যান'))
          ? 'Scan the Bangla QR code using bKash, Nagad, Cellfin or any banking app to pay.'
          : banglaQrInstruction;
    } else {
      return (banglaQrInstruction.contains('Scan the Bangla QR'))
          ? 'বিকাশ, নগদ, সেলফিন বা যেকোনো ব্যাংক অ্যাপ দিয়ে কিউআর স্ক্যান করে পেমেন্ট করুন।'
          : banglaQrInstruction;
    }
  }
}

