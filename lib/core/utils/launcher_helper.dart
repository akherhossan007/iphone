import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LauncherHelper {
  /// Opens WhatsApp with given phone and pre-filled message text.
  /// Tries native deep link first, falls back to web wa.me, and provides clipboard copy if failed.
  static Future<void> openWhatsApp({
    required BuildContext context,
    required String phone,
    String text = '',
  }) async {
    HapticFeedback.lightImpact();
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedText = Uri.encodeComponent(text);

    // 1. Native WhatsApp intent URI
    final nativeUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedText');
    try {
      final canNative = await canLaunchUrl(nativeUri);
      if (canNative) {
        final ok = await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
        if (ok) return;
      }
    } catch (_) {}

    // 2. Direct wa.me external web link
    final webUri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedText');
    try {
      final canWeb = await canLaunchUrl(webUri);
      if (canWeb) {
        final ok = await launchUrl(webUri, mode: LaunchMode.externalApplication);
        if (ok) return;
      }
    } catch (_) {}

    // 3. Fallback to platform default browser
    try {
      final ok = await launchUrl(webUri, mode: LaunchMode.platformDefault);
      if (ok) return;
    } catch (_) {}

    // 4. If neither worked, notify user and provide copy action
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WhatsApp: +$cleanPhone'),
          action: SnackBarAction(
            label: 'Copy Number',
            textColor: const Color(0xFF25D366),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '+$cleanPhone'));
            },
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Opens a general URL with external app mode
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens the live GlowBay AI Skin Consultant studio directly inside the app
  static Future<void> openAiSkinConsultant({required BuildContext context}) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse('https://glowbaybd.com/skin-analyzer/');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (ok) return;
    } catch (_) {}
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}
