import 'package:flutter/material.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final String vipTier;
  final String token;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    this.vipTier = 'Silver Member',
    this.token = '',
    this.roles = const [],
  });

  bool get isStaff =>
      roles.contains('administrator') ||
      roles.contains('shop_manager') ||
      roles.contains('staff') ||
      roles.contains('hub_manager');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> userRoles = [];
    if (json['roles'] is List) {
      userRoles = (json['roles'] as List).map((e) => e.toString().toLowerCase()).toList();
    } else if (json['role'] != null) {
      userRoles = [json['role'].toString().toLowerCase()];
    }

    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? json['user_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'GlowBay User',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? json['avatar_url']?.toString() ?? '',
      vipTier: json['vip_tier']?.toString() ?? json['member_badge']?.toString() ?? 'Silver Member',
      token: json['token']?.toString() ?? '',
      roles: userRoles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'vip_tier': vipTier,
      'token': token,
      'roles': roles,
    };
  }
}

class VipTierInfo {
  final int level; // 1 to 4
  final String tier; // silver, gold, platinum, diamond
  final String label; // Silver Member, Gold Member, etc.
  final String badge; // 🌱 Silver Member, etc.
  final Color primaryColor;
  final Color badgeBg;
  final Color textColor;
  final String discount;
  final double minSpent;
  final int minOrders;
  final String? nextTier;
  final double nextTarget;
  final double progressRatio;
  final String remainingMsg;
  final List<String> perks;

  const VipTierInfo({
    required this.level,
    required this.tier,
    required this.label,
    required this.badge,
    required this.primaryColor,
    required this.badgeBg,
    required this.textColor,
    required this.discount,
    required this.minSpent,
    required this.minOrders,
    this.nextTier,
    required this.nextTarget,
    required this.progressRatio,
    required this.remainingMsg,
    required this.perks,
  });

  static VipTierInfo fromStats({required double totalSpent, required int orderCount}) {
    if (totalSpent >= 30000 || orderCount >= 10) {
      return const VipTierInfo(
        level: 4,
        tier: 'diamond',
        label: 'Diamond VIP',
        badge: '👑 Diamond VIP',
        primaryColor: Color(0xFFFFB020),
        badgeBg: Color(0xFFFEF3C7),
        textColor: Color(0xFF92400E),
        discount: '10% Lifetime VIP Rebate',
        minSpent: 30000,
        minOrders: 10,
        nextTier: null,
        nextTarget: 0,
        progressRatio: 1.0,
        remainingMsg: 'Max Tier Unlocked • Top 1% VIP Shopper 👑',
        perks: [
          '10% Instant VIP Discount on all orders',
          'Personal Beauty & Skincare Consultant via WhatsApp',
          'Priority direct flight dispatch from Kuala Lumpur',
          'Free deluxe gift boxes on special occasions',
        ],
      );
    } else if (totalSpent >= 15000 || orderCount >= 6) {
      final neededSpent = (30000 - totalSpent).clamp(0, 30000).toInt();
      final neededOrders = (10 - orderCount).clamp(0, 10);
      final ratio = ((totalSpent - 15000) / 15000).clamp(0.0, 1.0);
      return VipTierInfo(
        level: 3,
        tier: 'platinum',
        label: 'Platinum Member',
        badge: '💎 Platinum Member',
        primaryColor: const Color(0xFF8B5CF6),
        badgeBg: const Color(0xFFEDE9FE),
        textColor: const Color(0xFF5B21B6),
        discount: '7% Special Rebate',
        minSpent: 15000,
        minOrders: 6,
        nextTier: 'Diamond VIP',
        nextTarget: 30000,
        progressRatio: ratio,
        remainingMsg: 'Spend ৳$neededSpent or $neededOrders more orders for Diamond VIP',
        perks: [
          '7% Special Platinum Discount on pre-orders',
          'Free home delivery voucher every month',
          'Early access to limited Malaysian collections',
          'Priority customer support line',
        ],
      );
    } else if (totalSpent >= 5000 || orderCount >= 2) {
      final neededSpent = (15000 - totalSpent).clamp(0, 15000).toInt();
      final neededOrders = (6 - orderCount).clamp(0, 6);
      final ratio = ((totalSpent - 5000) / 10000).clamp(0.0, 1.0);
      return VipTierInfo(
        level: 2,
        tier: 'gold',
        label: 'Gold Member',
        badge: '✨ Gold Member',
        primaryColor: const Color(0xFFEAB308),
        badgeBg: const Color(0xFFFEF9C3),
        textColor: const Color(0xFF854D0E),
        discount: '5% Member Discount',
        minSpent: 5000,
        minOrders: 2,
        nextTier: 'Platinum Member',
        nextTarget: 15000,
        progressRatio: ratio,
        remainingMsg: 'Spend ৳$neededSpent or $neededOrders more orders for Platinum',
        perks: [
          '5% Member discount on selected brands',
          'Special Birthday Voucher worth ৳250',
          'Exclusive Flash Sale invitations',
          'Steadfast & RedX express tracking',
        ],
      );
    } else {
      final neededSpent = (5000 - totalSpent).clamp(0, 5000).toInt();
      final neededOrders = (2 - orderCount).clamp(0, 2);
      final ratio = (totalSpent / 5000).clamp(0.0, 1.0);
      return VipTierInfo(
        level: 1,
        tier: 'silver',
        label: 'Silver Member',
        badge: '🌱 Silver Member',
        primaryColor: const Color(0xFF94A3B8),
        badgeBg: const Color(0xFFF1F5F9),
        textColor: const Color(0xFF475569),
        discount: 'Standard Pricing',
        minSpent: 0,
        minOrders: 0,
        nextTier: 'Gold Member',
        nextTarget: 5000,
        progressRatio: ratio,
        remainingMsg: 'Spend ৳$neededSpent or $neededOrders more orders for Gold',
        perks: [
          '100% Authentic Malaysian Sourced Guarantee',
          'Free Skin Routine Quiz Consultation',
          'Earn Glow Points on every purchase',
          'Track parcel live from KL to Dhaka Hub',
        ],
      );
    }
  }
}

class DashboardData {
  final UserModel profile;
  final int glowCoins;
  final int rewardPoints;
  final int activeVouchers;
  final String totalSpent;
  final int toPay;
  final int toShip;
  final int shipped;
  final int delivered;
  final int cancelled;
  final int returns;
  final int inTransit;
  final int toReview;
  final int totalOrders;
  final List<dynamic> recentOrders;

  DashboardData({
    required this.profile,
    required this.glowCoins,
    required this.rewardPoints,
    required this.activeVouchers,
    required this.totalSpent,
    required this.toPay,
    required this.toShip,
    this.shipped = 0,
    this.delivered = 0,
    this.cancelled = 0,
    this.returns = 0,
    required this.inTransit,
    required this.toReview,
    this.totalOrders = 0,
    required this.recentOrders,
  });

  double get numericSpent {
    final cleaned = totalSpent.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  VipTierInfo get tierInfo => VipTierInfo.fromStats(
        totalSpent: numericSpent,
        orderCount: totalOrders,
      );

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final profJson = Map<String, dynamic>.from(json['profile'] ?? {});
    final walletJson = json['wallet'] ?? {};
    final funnelJson = json['orders_funnel'] ?? {};
    final recentList = json['recent_orders'] as List? ?? [];

    if (!profJson.containsKey('vip_tier') && json.containsKey('member_badge')) {
      profJson['vip_tier'] = json['member_badge'];
    }

    return DashboardData(
      profile: UserModel.fromJson(profJson),
      glowCoins: walletJson['glow_coins'] ?? 0,
      rewardPoints: walletJson['reward_points'] ?? 0,
      activeVouchers: walletJson['active_vouchers'] ?? 0,
      totalSpent: walletJson['total_spent_formatted'] ?? '৳0',
      toPay: funnelJson['to_pay'] ?? funnelJson['topay'] ?? 0,
      toShip: funnelJson['to_ship'] ?? funnelJson['toship'] ?? 0,
      shipped: funnelJson['shipped'] ?? funnelJson['in_transit'] ?? 0,
      delivered: funnelJson['delivered'] ?? funnelJson['completed'] ?? 0,
      cancelled: funnelJson['cancelled'] ?? 0,
      returns: funnelJson['returns'] ?? funnelJson['refunded'] ?? 0,
      inTransit: funnelJson['in_transit'] ?? funnelJson['shipped'] ?? 0,
      toReview: funnelJson['to_review'] ?? 0,
      totalOrders: json['total_orders'] ?? recentList.length,
      recentOrders: recentList,
    );
  }
}
