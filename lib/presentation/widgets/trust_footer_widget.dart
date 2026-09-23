import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/subpages/about_us_screen.dart';
import '../screens/subpages/faq_screen.dart';
import '../screens/subpages/help_support_screen.dart';
import '../screens/subpages/order_tracking_screen.dart';
import '../screens/subpages/privacy_policy_screen.dart';
import '../screens/subpages/request_product_screen.dart';

class TrustFooterWidget extends StatelessWidget {
  const TrustFooterWidget({super.key});

  void _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.navyBackground,
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 36),
      child: Column(
        children: [
          // Logo & Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: AppColors.primaryGradient,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'GB',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                  children: [
                    TextSpan(text: 'GlowBay'),
                    TextSpan(text: 'BD', style: TextStyle(color: AppColors.accentPink)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '100% Authentic Malaysian Beauty & Wellness • Direct Import',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 18),

          // 4 Trust Badges Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3.2,
            children: const [
              _FooterBadge(icon: Icons.shield_outlined, label: '100% Original', color: AppColors.authenticGreen),
              _FooterBadge(icon: Icons.verified_outlined, label: 'Direct Malaysia Hub', color: Color(0xFF6366F1)),
              _FooterBadge(icon: Icons.local_shipping_outlined, label: 'Fast Courier Delivery', color: Color(0xFFFF8A20)),
              _FooterBadge(icon: Icons.lock_outline, label: '50% Advance Booking', color: AppColors.accentPink),
            ],
          ),
          const SizedBox(height: 20),

          // Direct Help & WhatsApp Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl('https://wa.me/8801948667001?text=Hello%20GlowBayBD,%20I%20need%20help'),
                  icon: const Icon(Icons.chat_bubble_outline, size: 15, color: Colors.white),
                  label: const Text('WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchUrl('tel:+8801948667001'),
                  icon: const Icon(Icons.phone_outlined, size: 15, color: Colors.white),
                  label: const Text('Call Us', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF334155)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Footer Sitemap Navigation Links
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                _FooterLink(
                  title: '🔍 Search Products',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen())),
                ),
                _FooterLink(
                  title: '📦 Track Order',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen())),
                ),
                _FooterLink(
                  title: '🏢 About Us',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
                ),
                _FooterLink(
                  title: '❓ FAQ & Help',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
                ),
                _FooterLink(
                  title: '🔒 Privacy Policy',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                ),
                _FooterLink(
                  title: '🎁 Request Skincare',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestProductScreen())),
                ),
                _FooterLink(
                  title: '📞 Customer Support',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Social Media Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF94A3B8), size: 20),
                onPressed: () => _launchUrl('https://instagram.com/glowbaybd'),
                tooltip: 'Instagram',
              ),
              IconButton(
                icon: const Icon(Icons.facebook, color: Color(0xFF94A3B8), size: 20),
                onPressed: () => _launchUrl('https://facebook.com/glowbaybd'),
                tooltip: 'Facebook',
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Copyright
          const Text(
            '© 2026 GlowBayBD.com • Authentic Skincare Hub',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

class _FooterBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FooterBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 10.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _FooterLink({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
