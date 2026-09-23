class VoucherModel {
  final String code;
  final String title;
  final String discount;
  final String minSpend;
  final String expiry;
  final String badge;

  VoucherModel({
    required this.code,
    required this.title,
    required this.discount,
    required this.minSpend,
    required this.expiry,
    required this.badge,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      discount: json['discount'] ?? '',
      minSpend: json['min_spend'] ?? '',
      expiry: json['expiry'] ?? '',
      badge: json['badge'] ?? 'Promo',
    );
  }
}
