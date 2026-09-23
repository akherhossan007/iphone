class AffiliateStatsModel {
  final String creatorName;
  final String referralCode;
  final String referralUrl;
  final String commissionRate;
  final String totalEarnings;
  final String pendingPayout;
  final String paidEarnings;
  final int clicks;
  final int conversions;

  AffiliateStatsModel({
    required this.creatorName,
    required this.referralCode,
    required this.referralUrl,
    required this.commissionRate,
    required this.totalEarnings,
    required this.pendingPayout,
    required this.paidEarnings,
    required this.clicks,
    required this.conversions,
  });

  factory AffiliateStatsModel.fromJson(Map<String, dynamic> json) {
    return AffiliateStatsModel(
      creatorName: json['creator_name'] ?? 'Creator',
      referralCode: json['referral_code'] ?? '',
      referralUrl: json['referral_url'] ?? '',
      commissionRate: json['commission_rate'] ?? '5%',
      totalEarnings: json['total_earnings'] ?? '৳0',
      pendingPayout: json['pending_payout'] ?? '৳0',
      paidEarnings: json['paid_earnings'] ?? '৳0',
      clicks: json['clicks'] ?? 0,
      conversions: json['conversions'] ?? 0,
    );
  }
}
