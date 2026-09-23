import 'package:flutter/material.dart';

class AppColors {
  // GlowBay Brand Identity — Luxury Pink & Sunset Orange
  static const Color primary = Color(0xFFFF2A6D); // Radiant Glow Pink / Magenta
  static const Color primaryDark = Color(0xFFE11D48); // Deep Rose
  static const Color primaryLight = Color(0xFFFF6B9D); // Soft Blossom
  static const Color accentOrange = Color(0xFFFF7A00); // Warm Sunset Glow
  static const Color accentPink = Color(0xFFFF2A6D);
  static const Color primaryPink = Color(0xFFFF2A6D);
  static const Color accent = Color(0xFFFF7A00);
  static const Color accentGradientStart = Color(0xFFFF2A6D);
  static const Color accentGradientEnd = Color(0xFFFF7A00);

  // Background & Surfaces
  static const Color navyBackground = Color(0xFF0F172A);
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardSurface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Status & Badges
  static const Color authenticGreen = Color(0xFF10B981);
  static const Color authenticGreenBg = Color(0xFFECFDF5);
  static const Color authenticBg = Color(0xFFECFDF5);
  static const Color starGold = Color(0xFFFBBF24);
  static const Color flashRed = Color(0xFFFF2A6D);
  static const Color flashRedBg = Color(0xFFFFF0F5);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color infoBlueBg = Color(0xFFEFF6FF);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Luxury Soft Ambient Shadows
  static List<BoxShadow> get luxuryCardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFFFF2A6D).withValues(alpha: 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get buttonGlowShadow => [
    BoxShadow(
      color: const Color(0xFFFF2A6D).withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> get primaryGlowShadow => [
    BoxShadow(
      color: const Color(0xFFFF7A00).withValues(alpha: 0.30),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  // Gradients — Iconic Pink & Orange Glow
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF2A6D), Color(0xFFFF7A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryRoseGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFFFF6B00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF31103F), Color(0xFF1F1235)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient flashGradient = LinearGradient(
    colors: [Color(0xFFFF2A6D), Color(0xFFFF6B00)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Shopee / Lazada Signature Radiant Sunset Glow Header
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFFF1B6B), Color(0xFFFF416C), Color(0xFFFF7A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkOrangeBrandGradient = LinearGradient(
    colors: [Color(0xFFFF1F78), Color(0xFFFF6B00), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Southeast Asian E-Commerce Prestige Tokens
  static const Color shopeeOrange = Color(0xFFFF5722);
  static const Color shopeeRed = Color(0xFFEE4D2D);
  static const Color lazadaBlue = Color(0xFF0F146D);
  static const Color lazadaGold = Color(0xFFF6A609);
  static const Color mallRed = Color(0xFFD0011B);

  static const LinearGradient mallBadgeGradient = LinearGradient(
    colors: [Color(0xFFD0011B), Color(0xFFFF2A6D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient flameSaleGradient = LinearGradient(
    colors: [Color(0xFFFF385C), Color(0xFFFF7A00)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
