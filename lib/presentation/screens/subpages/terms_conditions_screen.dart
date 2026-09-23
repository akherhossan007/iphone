import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, size: 20),
            tooltip: 'Open in Browser',
            onPressed: () => launchUrl(
              Uri.parse('https://glowbaybd.com/terms/'),
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
                  colors: [Color(0xFFFF7A00), Color(0xFFFF2374)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF2374).withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GlowBay BD Terms of Service',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Official Customer Agreement & Store Policy',
                          style: TextStyle(color: Colors.white70, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section 1: Authenticity
            _buildTermCard(
              icon: Icons.verified_outlined,
              color: const Color(0xFF10B981),
              title: '1. 100% Authentic Product Guarantee',
              content:
                  'Every product available on GlowBay BD is directly imported and sourced from verified brand stores, pharmacies (Watsons, Guardian), and authorized distributors in Malaysia and Asia. We strictly condemn counterfeit goods.',
            ),
            const SizedBox(height: 12),

            // Section 2: Order Placement & Verification
            _buildTermCard(
              icon: Icons.shopping_bag_outlined,
              color: const Color(0xFF2563EB),
              title: '2. Order Confirmation & Phone Verification',
              content:
                  'When an order is placed, our support team may call the customer on their provided phone number to confirm the delivery address and dispatch schedule. For Cash on Delivery orders, confirmation is mandatory before handover to our courier partners.',
            ),
            const SizedBox(height: 12),

            // Section 3: Delivery Timeline & Charges
            _buildTermCard(
              icon: Icons.local_shipping_outlined,
              color: const Color(0xFFFF7A00),
              title: '3. Delivery Timelines',
              content:
                  '• Inside Dhaka Metro: 24 to 48 hours.\n• Outside Dhaka (All Districts): 48 to 72 hours via Steadfast / Pathao courier network.\nDelivery fees are transparently displayed during checkout.',
            ),
            const SizedBox(height: 12),

            // Section 4: Return & Replacement Policy
            _buildTermCard(
              icon: Icons.assignment_return_outlined,
              color: const Color(0xFFED2165),
              title: '4. Returns & Replacement Policy',
              content:
                  'If you receive a defective, damaged, or incorrect item, please notify us within 24 hours of delivery with an unboxing video. Due to skincare hygiene and health regulations, opened or used cosmetics cannot be returned unless verified as transit damaged.',
            ),
            const SizedBox(height: 12),

            // Section 5: Pricing & Payments
            _buildTermCard(
              icon: Icons.credit_card_outlined,
              color: const Color(0xFF8B5CF6),
              title: '5. Pricing & Payments',
              content:
                  'All prices are listed in Bangladeshi Taka (৳) and include applicable import clearance. Payments can be completed through bKash, Nagad, Direct Bank Transfer, or Cash on Delivery (COD).',
            ),
            const SizedBox(height: 12),

            // Section 6: Customer Support
            _buildTermCard(
              icon: Icons.support_agent_outlined,
              color: const Color(0xFF0EA5E9),
              title: '6. Support & Inquiries',
              content:
                  'For any assistance, contact our dedicated support team via WhatsApp helpline (+601125044155 / +8801624810710) or email support@glowbaybd.com. Support hours are 8:00 AM to 8:00 PM daily.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTermCard({
    required IconData icon,
    required Color color,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
