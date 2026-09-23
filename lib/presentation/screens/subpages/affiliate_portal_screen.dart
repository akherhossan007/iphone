import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/affiliate_provider.dart';

class AffiliatePortalScreen extends StatefulWidget {
  const AffiliatePortalScreen({super.key});

  @override
  State<AffiliatePortalScreen> createState() => _AffiliatePortalScreenState();
}

class _AffiliatePortalScreenState extends State<AffiliatePortalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AffiliateProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final aff = context.watch<AffiliateProvider>();
    final stats = aff.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Affiliate Creator Hub', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 22, color: Color(0xFF0F172A)),
            tooltip: 'Home',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: aff.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : stats == null
              ? _buildNotAffiliateView(context, aff)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(stats.creatorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentPink,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Rate: ${stats.commissionRate}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Total Earnings', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(stats.totalEarnings, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pending Payout', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                                  Text(stats.pendingPayout, style: const TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.w800, fontSize: 14)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Paid to Date', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                                  Text(stats.paidEarnings, style: const TextStyle(color: AppColors.authenticGreen, fontWeight: FontWeight.w800, fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Referral Link Generator Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Referral Link', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(stats.referralUrl, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: stats.referralUrl));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referral link copied!')));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('COPY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2-Col Stat Grid
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.ads_click, color: AppColors.infoBlue, size: 20),
                              const SizedBox(height: 8),
                              Text('${stats.clicks}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                              const Text('Total Link Clicks', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.shopping_bag_outlined, color: AppColors.authenticGreen, size: 20),
                              const SizedBox(height: 8),
                              Text('${stats.conversions}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                              const Text('Paid Orders', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNotAffiliateView(BuildContext context, AffiliateProvider aff) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentPink,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('GLOWBAY CREATOR CLUB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                ),
                const SizedBox(height: 12),
                const Text('Partner With Us & Earn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 6),
                const Text(
                  'Share authentic skincare recommendations with your audience and earn 5% commission on every delivered order.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Program Benefits', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 10),
          _buildBenefitCard(
            Icons.percent,
            '5% Flat Commission',
            'Earn a guaranteed 5% reward on every single order placed via your unique creator link.',
            AppColors.authenticGreen,
          ),
          const SizedBox(height: 10),
          _buildBenefitCard(
            Icons.insights,
            'Live Performance Tracking',
            'View real-time clicks, conversions, pending payouts, and paid earnings inside this app.',
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 10),
          _buildBenefitCard(
            Icons.account_balance_wallet_outlined,
            'Monthly Automated Payouts',
            'Withdraw directly to your bKash, Nagad, or Bangladeshi bank account on the 1st of every month.',
            AppColors.accentPink,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('https://wa.me/8801948667001?text=Hello%20GlowBay%2C%20I%20would%20like%20to%20apply%20for%20the%20Creator%20Affiliate%20Program.');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
              label: const Text('APPLY FOR CREATOR HUB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => aff.fetchStats(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('CHECK APPROVAL STATUS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.borderSubtle),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(IconData icon, String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 3),
                Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
