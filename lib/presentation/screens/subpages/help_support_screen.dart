import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import 'faq_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Help Center', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // WhatsApp Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD1FAE5)),
            ),
            child: Column(
              children: [
                // 1. Bangladesh Helpline
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
                      child: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BD Helpline 🇧🇩', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
                          const SizedBox(height: 2),
                          const Text('+8801948667001 (8 AM – 11 PM)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _launchUrl('https://wa.me/8801948667001?text=Hello%20GlowBayBD,%20I%20need%20help'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('CHAT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFD1FAE5)),
                // 2. Malaysia HQ Desk
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF25D366).withValues(alpha: 0.8), shape: BoxShape.circle),
                      child: const Icon(Icons.public, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Malaysia HQ 🇲🇾', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
                          const SizedBox(height: 2),
                          const Text('+601125044155 (Import & Sourcing)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _launchUrl('https://wa.me/601125044155?text=Hello%20GlowBay%20HQ,%20I%20have%20an%20inquiry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('HQ DESK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // FAQ Banner Card
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
                      child: const Text('VIEW ALL (8 TOPICS) ›', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildFaqItem('Are all products 100% genuine?', 'Yes, all products are directly imported from authorized brand distributors and pharmacies in Kuala Lumpur, Malaysia with 100% money back guarantee.'),
                _buildFaqItem('How long does delivery take?', 'Pre-order timeline is 10–25 days total (Malaysia sourcing & transit). Once in Dhaka: 24–48 hrs in Dhaka and 3–5 days outside Dhaka via courier.'),
                _buildFaqItem('What is 50% Advance Booking?', 'For imported pre-orders, 50% booking advance confirms product sourcing in Malaysia. Remaining 50% is paid upon delivery (COD).'),
                _buildFaqItem('What is your Return Policy?', 'Opened/used cosmetics cannot be returned. Unopened sealed products can be returned with a 15% restocking fee. Damaged/wrong items get 100% full refund.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(answer, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
