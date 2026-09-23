import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/voucher_model.dart';
import '../../../data/services/api_service.dart';

class VouchersWalletScreen extends StatefulWidget {
  const VouchersWalletScreen({super.key});

  @override
  State<VouchersWalletScreen> createState() => _VouchersWalletScreenState();
}

class _VouchersWalletScreenState extends State<VouchersWalletScreen> {
  final ApiService _api = ApiService();
  List<VoucherModel> _vouchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  void _loadVouchers() async {
    final list = await _api.getVouchers();
    if (mounted) {
      setState(() {
        _vouchers = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('Vouchers & Rewards', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 22),
            tooltip: 'Home',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _vouchers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.confirmation_number_outlined, size: 48, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Active Vouchers',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Check back soon for new discounts and exclusive promotional vouchers!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vouchers.length,
                  itemBuilder: (context, index) {
                    final v = _vouchers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.confirmation_number_outlined, color: AppColors.primary, size: 20),
                                const SizedBox(height: 4),
                                Text(
                                  v.discount,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentPink.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    v.badge,
                                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.accentPink),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(v.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text('Min spend ${v.minSpend} • Exp: ${v.expiry}', style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: v.code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Voucher "${v.code}" copied!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('COPY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10.5)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
