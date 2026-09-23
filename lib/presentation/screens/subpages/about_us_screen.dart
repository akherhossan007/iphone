import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
          'About GlowBayBD',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 22),
            tooltip: 'Home',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero Brand Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset('assets/images/logo.png', width: 64, height: 64, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                      children: const [
                        TextSpan(text: 'GlowBay'),
                        TextSpan(text: 'BD', style: TextStyle(color: Color(0xFFFF2A6D))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '100% Authentic Malaysian Skincare & Cosmetics',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sourcing Story
            _buildInfoCard(
              icon: Icons.storefront_outlined,
              iconColor: const Color(0xFF3B82F6),
              title: 'Direct Sourcing from Kuala Lumpur',
              content: 'GlowBayBD operates with a dedicated on-ground purchasing team in Kuala Lumpur, Malaysia. We source authentic international and Korean skincare brands (CeraVe, Cetaphil, COSRX, The Ordinary, NIVEA) directly from authorized retail counters and pharmacies (Watson, Guardian, Sephora).',
            ),
            const SizedBox(height: 12),

            // Direct Sourcing Pipeline
            _buildInfoCard(
              icon: Icons.local_shipping_outlined,
              iconColor: const Color(0xFF10B981),
              title: 'Freshness & Authenticity Guaranteed',
              content: 'All GlowBayBD products are hand-picked fresh from authorized brand pharmacies in Kuala Lumpur. Items are packed with extreme care ensuring 100% original quality, seals, and active ingredient efficacy upon reaching your doorstep.',
            ),
            const SizedBox(height: 12),

            // Consumer Protection
            _buildInfoCard(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFFF59E0B),
              title: '100% Money-Back Authenticity',
              content: 'We take counterfeit protection seriously. Every single product sent to our customers comes with original Malaysian batch codes and factory seals intact. If proven unauthentic, we guarantee a 100% instant full refund.',
            ),
            const SizedBox(height: 16),

            // WhatsApp Contact Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse('https://wa.me/601125044155?text=Hello%20GlowBayBD%20Team!');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                label: const Text('Contact Management on WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.5),
          ),
        ],
      ),
    );
  }
}
