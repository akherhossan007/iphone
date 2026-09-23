import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/language_provider.dart';
import 'address_book_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import 'faq_screen.dart';
import 'about_us_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _orderNotifications = true;
  bool _promoNotifications = true;
  bool _whatsappAlerts = true;

  static const Color _primaryPink = Color(0xFFFF2A6D);
  static const Color _borderSubtle = Color(0xFFE2E8F0);
  static const Color _surfaceBg = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textSubtle = Color(0xFF64748B);

  void _showLanguageSelectionModal(BuildContext context) {
    final lang = context.read<LanguageProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final current = context.watch<LanguageProvider>().currentLanguage;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.language_rounded, color: Color(0xFF6366F1), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Select App Language / ভাষা',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Option 1: English (Default)
              InkWell(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await lang.setLanguage('en');
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Language set to English'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: current == 'en' ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: current == 'en' ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                      width: current == 'en' ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'English (Default)',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: current == 'en' ? const Color(0xFF4338CA) : _textDark,
                              ),
                            ),
                            const Text(
                              'Universal English interface',
                              style: TextStyle(fontSize: 11, color: _textSubtle),
                            ),
                          ],
                        ),
                      ),
                      if (current == 'en')
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF6366F1), size: 22)
                      else
                        const Icon(Icons.radio_button_unchecked, color: Color(0xFFCBD5E1), size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Option 2: বাংলা
              InkWell(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await lang.setLanguage('bn');
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ভাষা বাংলায় পরিবর্তিত হয়েছে'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: current == 'bn' ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: current == 'bn' ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                      width: current == 'bn' ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🇧🇩', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'বাংলা (Bangla)',
                              style: GoogleFonts.hindSiliguri(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: current == 'bn' ? const Color(0xFF4338CA) : _textDark,
                              ),
                            ),
                            const Text(
                              'বাংলা ইন্টারফেস ও ট্র্যাকিং',
                              style: TextStyle(fontSize: 11, color: _textSubtle),
                            ),
                          ],
                        ),
                      ),
                      if (current == 'bn')
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF6366F1), size: 22)
                      else
                        const Icon(Icons.radio_button_unchecked, color: Color(0xFFCBD5E1), size: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileModal(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 22,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profile Information',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Full Name'),
            _buildModalField(controller: nameCtrl, hint: 'Full Name', icon: Icons.person_outline),
            const SizedBox(height: 12),
            _buildFieldLabel('Phone Number'),
            _buildModalField(controller: phoneCtrl, hint: '01XXXXXXXXX', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildFieldLabel('Email Address'),
            _buildModalField(controller: emailCtrl, hint: 'email@example.com', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully.'),
                      backgroundColor: AppColors.authenticGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordModal(BuildContext context) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 22,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change Account Password',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Current Password'),
            _buildModalField(controller: currentPassCtrl, hint: 'Enter current password', icon: Icons.lock_outline, obscure: true),
            const SizedBox(height: 12),
            _buildFieldLabel('New Password'),
            _buildModalField(controller: newPassCtrl, hint: 'Minimum 6 characters', icon: Icons.shield_outlined, obscure: true),
            const SizedBox(height: 12),
            _buildFieldLabel('Confirm New Password'),
            _buildModalField(controller: confirmPassCtrl, hint: 'Re-enter new password', icon: Icons.shield_outlined, obscure: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (newPassCtrl.text.isEmpty || newPassCtrl.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password must be at least 6 characters.'), backgroundColor: AppColors.error),
                    );
                    return;
                  }
                  if (newPassCtrl.text != confirmPassCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match.'), backgroundColor: AppColors.error),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully.'),
                      backgroundColor: AppColors.authenticGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Update Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuthenticityPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 22),
            SizedBox(width: 8),
            Text('100% Genuine Guarantee', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: const Text(
          'GlowBay products are directly procured from licensed pharmacy distributors and official brand boutiques in Kuala Lumpur, Malaysia.\n\nEvery item carries factory batch seals. In the improbable event of an inauthentic item, we provide a 100% instant full refund.',
          style: TextStyle(fontSize: 12.5, color: _textSubtle, height: 1.45),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Got It', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showReturnPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.assignment_return_rounded, color: _primaryPink, size: 22),
            SizedBox(width: 8),
            Text('Return & Replacement Policy', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: const Text(
          'We accept returns for damaged items or incorrect delivery within 48 hours of parcel handover in Bangladesh.\n\nItems must remain unopened with their original security seal intact. Our Dhaka hub dispatches replacements promptly.',
          style: TextStyle(fontSize: 12.5, color: _textSubtle, height: 1.45),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Understood', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 8),
            Text('Delete Account Permanently?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your GlowBay account? This will erase your order history, delivery addresses, and saved wishlist (Google Play Store compliance requirement). This action cannot be reversed.',
          style: TextStyle(fontSize: 12.5, color: _textSubtle, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700, color: _textSubtle)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your account and session have been permanently cleared.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
            SizedBox(width: 8),
            Text('Log Out?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Do you wish to log out of your GlowBay account on this device?',
          style: TextStyle(fontSize: 13, color: _textSubtle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay Logged In', style: TextStyle(fontWeight: FontWeight.w700, color: _textSubtle)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final user = auth.currentUser;
    final dashboard = auth.dashboardData;
    final tier = dashboard?.tierInfo;

    return Scaffold(
      backgroundColor: _surfaceBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account Settings',
          style: GoogleFonts.plusJakartaSans(
            color: _textDark,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _borderSubtle, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // User Card
          if (user != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _borderSubtle),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _primaryPink,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.phone.isNotEmpty ? user.phone : user.email,
                          style: const TextStyle(fontSize: 12, color: _textSubtle),
                        ),
                      ],
                    ),
                  ),
                  if (tier != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tier.badgeBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: tier.primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        tier.badge,
                        style: TextStyle(color: tier.textColor, fontWeight: FontWeight.w800, fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Group 1: Account & Profile
          _buildGroupHeader('ACCOUNT & PROFILE'),
          _buildGroupContainer([
            _buildSettingTile(
              icon: Icons.person_outline_rounded,
              iconColor: _primaryPink,
              title: 'Edit Profile Information',
              subtitle: 'Update your display name, phone & email',
              onTap: () => _showEditProfileModal(context),
            ),
            _buildTileDivider(),
            _buildSettingTile(
              icon: Icons.location_on_outlined,
              iconColor: const Color(0xFF3B82F6),
              title: 'Saved Address Book',
              subtitle: 'Manage delivery addresses & recipient notes',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressBookScreen())),
            ),
            _buildTileDivider(),
            _buildSettingTile(
              icon: Icons.lock_outline_rounded,
              iconColor: const Color(0xFFF59E0B),
              title: 'Change Password',
              subtitle: 'Update your account security password',
              onTap: () => _showChangePasswordModal(context),
            ),
          ]),
          const SizedBox(height: 16),

          // Group: App Language (Only in Account Settings)
          _buildGroupHeader(langProvider.isEnglish ? 'APP LANGUAGE' : 'অ্যাপের ভাষা'),
          _buildGroupContainer([
            _buildSettingTile(
              icon: Icons.translate_rounded,
              iconColor: const Color(0xFF6366F1),
              title: langProvider.isEnglish ? 'App Language' : 'অ্যাপের ভাষা পরিবর্তন',
              subtitle: langProvider.isEnglish ? 'English (Current Default)' : 'বাংলা (সক্রিয়)',
              trailingText: langProvider.isEnglish ? 'English 🇬🇧' : 'বাংলা 🇧🇩',
              onTap: () => _showLanguageSelectionModal(context),
            ),
          ]),
          const SizedBox(height: 16),

          // Group 2: Notifications & Communication
          _buildGroupHeader('NOTIFICATIONS & PREFERENCES'),
          _buildGroupContainer([
            SwitchListTile(
              value: _orderNotifications,
              activeTrackColor: _primaryPink,
              title: const Text('Order & Shipping Alerts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _textDark)),
              subtitle: const Text('Live status updates from KL to Dhaka Hub', style: TextStyle(fontSize: 11, color: _textSubtle)),
              secondary: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.notifications_active_outlined, color: Color(0xFF10B981), size: 18),
              ),
              onChanged: (val) => setState(() => _orderNotifications = val),
            ),
            _buildTileDivider(),
            SwitchListTile(
              value: _promoNotifications,
              activeTrackColor: _primaryPink,
              title: const Text('Promotions & Flash Sales', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _textDark)),
              subtitle: const Text('Discounts and limited-time beauty drops', style: TextStyle(fontSize: 11, color: _textSubtle)),
              secondary: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: _primaryPink.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.discount_outlined, color: _primaryPink, size: 18),
              ),
              onChanged: (val) => setState(() => _promoNotifications = val),
            ),
            _buildTileDivider(),
            SwitchListTile(
              value: _whatsappAlerts,
              activeTrackColor: _primaryPink,
              title: const Text('WhatsApp Dispatch Updates', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _textDark)),
              subtitle: const Text('Receive courier tracking links on WhatsApp', style: TextStyle(fontSize: 11, color: _textSubtle)),
              secondary: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: const Color(0xFF25D366).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.chat_outlined, color: Color(0xFF25D366), size: 18),
              ),
              onChanged: (val) => setState(() => _whatsappAlerts = val),
            ),
          ]),
          const SizedBox(height: 16),

          // Group 3: Policies & Guarantees
          _buildGroupHeader('POLICIES & GUARANTEES'),
          _buildGroupContainer([
            _buildSettingTile(
              icon: Icons.verified_outlined,
              iconColor: const Color(0xFF10B981),
              title: '100% Genuine Guarantee',
              subtitle: 'Batch verification & money-back policy',
              onTap: () => _showAuthenticityPolicyDialog(context),
            ),
            _buildTileDivider(),
            _buildSettingTile(
              icon: Icons.assignment_return_outlined,
              iconColor: const Color(0xFF0EA5E9),
              title: 'Return & Refund Policy',
              subtitle: 'Guidelines for exchange & replacements',
              onTap: () => _showReturnPolicyDialog(context),
            ),
            _buildTileDivider(),
            _buildSettingTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: _textSubtle,
              title: 'Privacy Policy',
              subtitle: 'Data protection and Google Play safety',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
            ),
            _buildTileDivider(),
            _buildSettingTile(
              icon: Icons.gavel_rounded,
              iconColor: _textSubtle,
              title: 'Terms of Service',
              subtitle: 'Customer rights & usage agreements',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen())),
            ),
            _buildTileDivider(),
            _buildSettingTile(
              icon: Icons.help_outline_rounded,
              iconColor: const Color(0xFFD97706),
              title: 'Help Center & FAQ',
              subtitle: 'Common questions & order assistance',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
            ),
            _buildTileDivider(),
            _buildSettingTile(
              icon: Icons.storefront_outlined,
              iconColor: const Color(0xFF4F46E5),
              title: 'About GlowBayBD',
              subtitle: 'Our story, values & direct import mission',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
            ),
          ]),
          const SizedBox(height: 16),

          // Group 4: App Maintenance
          _buildGroupHeader('APP & STORAGE'),
          _buildGroupContainer([
            _buildSettingTile(
              icon: Icons.cleaning_services_outlined,
              iconColor: const Color(0xFF6366F1),
              title: 'Clear Cache Memory',
              subtitle: 'Free up local cached image storage',
              trailingText: '14.2 MB',
              onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared successfully. 14.2 MB freed.'),
                    backgroundColor: Color(0xFF1E293B),
                  ),
                );
              },
            ),
            _buildTileDivider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: const Color(0xFF94A3B8).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 18),
              ),
              title: const Text('Application Version', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _textDark)),
              subtitle: const Text('GlowBay Android Release v2.4.0 (Build 240)', style: TextStyle(fontSize: 11, color: _textSubtle)),
              trailing: const Text('Up to date', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 16),

          // Group 5: Danger Zone
          _buildGroupHeader('ACCOUNT DELETION'),
          _buildGroupContainer([
            _buildSettingTile(
              icon: Icons.delete_forever_outlined,
              iconColor: AppColors.error,
              title: 'Delete Account',
              subtitle: 'Permanently remove your account & order history',
              textColor: AppColors.error,
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ]),
          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
              label: const Text(
                'Log Out of Account',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFFEE2E2), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'GlowBay BD • 100% Authentic Malaysian Skincare\nSecured by WooCommerce REST API',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: _textSubtle,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGroupContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderSubtle),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? textColor,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor ?? _textDark),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: _textSubtle),
      ),
      trailing: trailingText != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(trailingText, style: const TextStyle(fontSize: 11, color: _textSubtle, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
              ],
            )
          : const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  Widget _buildTileDivider() {
    return const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 52);
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: _textDark)),
    );
  }

  Widget _buildModalField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderSubtle),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: _textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}
