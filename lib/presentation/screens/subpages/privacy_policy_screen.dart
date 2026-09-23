import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: Text(
          'Privacy Policy & Legal Terms',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 22),
            tooltip: 'Home',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser, size: 20),
            tooltip: 'Open in Browser',
            onPressed: () => launchUrl(
              Uri.parse('https://glowbaybd.com/privacy-policy/'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/images/logo.png', width: 48, height: 48, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GlowBayBD Consumer Charter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('Official Terms & Policies (Live Synchronized)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section 1: 100% Authenticity Guarantee
            _buildPolicyCard(
              icon: Icons.verified_user_outlined,
              color: AppColors.authenticGreen,
              title: '1. 100% Authentic Malaysian Sourced Guarantee',
              content: 'All skincare & cosmetics on GlowBayBD are sourced directly from authorized pharmacies and brand stores in Kuala Lumpur, Malaysia. We provide a 100% full money-back guarantee if any product is proven counterfeit.',
            ),
            const SizedBox(height: 12),

            // Section 2: 50% Advance & Direct Import Delivery Timeline
            _buildPolicyCard(
              icon: Icons.local_shipping_outlined,
              color: const Color(0xFF3B82F6),
              title: '2. Pre-Order & Direct Import (10–25 Days)',
              content: 'To secure fresh authentic international stock, items are sourced directly from authorized brand stores in Kuala Lumpur and dispatched to Dhaka. A 50% booking advance confirms order sourcing. Total delivery timeline is 10–25 days. After arrival in Dhaka: delivery is 24–48 hours inside Dhaka and 3–5 days outside Dhaka via courier. Remaining 50% is payable via Cash on Delivery (COD).',
            ),
            const SizedBox(height: 12),

            // Section 3: Order Cancellation Rules
            _buildPolicyCard(
              icon: Icons.cancel_outlined,
              color: const Color(0xFFEF4444),
              title: '3. Order Cancellation Policy',
              content: '• Before sourcing in Malaysia: 100% Full Refund (Zero fee).\n• After product has been sourced: 15% administrative & handling charge is deducted.\n• After courier dispatch: Order cannot be cancelled (standard return policy applies).',
            ),
            const SizedBox(height: 12),

            // Section 4: Return, Refund & No-Exchange Policy
            _buildPolicyCard(
              icon: Icons.replay,
              color: const Color(0xFFF59E0B),
              title: '4. Returns, Refunds & No-Exchange Rules',
              content: '• Opened or used cosmetics cannot be returned due to international hygiene regulations.\n• Unopened, seal-intact returns are accepted with a 15% restocking fee (customer covers return shipping).\n• GlowBayBD error or transit damage: 100% Full Refund + Return shipping borne by GlowBayBD (unboxing video recommended).\n• No direct exchanges — refunds are processed within 3–7 business days.',
            ),
            const SizedBox(height: 12),

            // Section 5: Data Privacy & Security
            _buildPolicyCard(
              icon: Icons.lock_outline,
              color: AppColors.accentPink,
              title: '5. Data Privacy & Customer Protection',
              content: 'GlowBayBD uses SSL/TLS encryption for all transactions. Your personal info (name, phone, delivery address) is never sold or shared with external parties. Helpdesk hours: 8:00 AM – 8:00 PM BST (WhatsApp: +601125044155).',
            ),
            const SizedBox(height: 12),

            // Section 6: Account Deletion
            _buildPolicyCard(
              icon: Icons.delete_forever_outlined,
              color: AppColors.error,
              title: '6. Account Deletion Rights (Google Play Policy)',
              content: 'Users can permanently delete their account, saved addresses, and profile data at any time via the "Delete My Account" option in VIP Settings.',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard({
    required IconData icon,
    required Color color,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.45)),
        ],
      ),
    );
  }
}
