import 'dart:async';
import '../catalog/brands_screen.dart';
import '../catalog/flash_sale_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/launcher_helper.dart';
import '../../../data/models/review_model.dart';
import '../../../logic/catalog_provider.dart';
import '../../../logic/home_provider.dart';
import '../../../logic/language_provider.dart';
import '../../widgets/countdown_timer_widget.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../catalog/categories_screen.dart';
import '../catalog/catalog_screen.dart';
import '../catalog/smart_search_delegate.dart';
import '../subpages/order_tracking_screen.dart';
import '../subpages/request_product_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../subpages/visual_search_screen.dart';
import '../subpages/vouchers_wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _bannerController;
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final banners = context.read<HomeProvider>().banners;
      if (banners.length > 1 && _bannerController.hasClients) {
        final nextPage = (_currentBannerPage + 1) % banners.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse('https://wa.me/8801948667001?text=Hello%20GlowBay%20Support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static const List<Map<String, String>> _officialWebBrands = [
    {'name': 'Nivea', 'slug': 'nivea', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/nivea.png'},
    {'name': 'Vaseline', 'slug': 'vaseline', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/vaseline.png'},
    {'name': 'La Roche-Posay', 'slug': 'la-roche-posay', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/la-roche-posay.png'},
    {'name': 'Dove', 'slug': 'dove', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/dove.png'},
    {'name': 'Watsons', 'slug': 'watsons', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/watsons.png'},
    {'name': 'GOOD VIRTUES CO', 'slug': 'goodvirtuesco', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/goodvirtuesco.png'},
    {'name': 'Eucerin', 'slug': 'eucerin', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/eucerin.png'},
    {'name': 'Sunsilk', 'slug': 'sunsilk', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/sunsilk.png'},
    {'name': 'Biore', 'slug': 'biore', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/biore.png'},
    {'name': 'Hada Labo', 'slug': 'hadalabo', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/hadalabo.png'},
    {'name': 'Olay', 'slug': 'olay', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/olay.png'},
    {'name': 'Pantene', 'slug': 'pantene', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/pantene.png'},
    {'name': 'Garnier', 'slug': 'garnier', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/garnier.png'},
    {'name': "L'Oreal", 'slug': 'loreal', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/loreal.png'},
    {'name': 'Blackmores', 'slug': 'blackmores', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/blackmores.png'},
    {'name': 'Simple', 'slug': 'simple', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/simple.png'},
    {'name': 'Neutrogena', 'slug': 'neutrogena', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/neutrogena.png'},
    {'name': 'TRESemme', 'slug': 'tresemme', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/tresemme.png'},
    {'name': 'Cetaphil', 'slug': 'cetaphil', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/cetaphil.png'},
    {'name': 'Himalaya', 'slug': 'himalaya', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/himalaya.png'},
    {'name': 'CeraVe', 'slug': 'cerave', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/cerave.png'},
    {'name': 'Tsubaki Premium', 'slug': 'tsubaki-premium', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/tsubaki-premium.png'},
    {'name': 'Aveeno', 'slug': 'aveeno', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/aveeno.png'},
    {'name': 'COSRX', 'slug': 'cosrx', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/cosrx.png'},
    {'name': 'Anua', 'slug': 'anua', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/anua.png'},
    {'name': 'Fino', 'slug': 'fino', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/fino.png'},
    {'name': "Pond's", 'slug': 'ponds', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/ponds.png'},
    {'name': 'Sunplay', 'slug': 'sunplay', 'logo': 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/sunplay.png'},
  ];

  static const List<Map<String, String>> _officialWebCategories = [
    {'emoji': '🧼', 'name': 'Cleansers', 'slug': 'facial-cleanser'},
    {'emoji': '🧴', 'name': 'Moisturizers', 'slug': 'skincare-moisturizer'},
    {'emoji': '🧪', 'name': 'Serums', 'slug': 'serum'},
    {'emoji': '🌞', 'name': 'Sunscreen', 'slug': 'sunscreen'},
    {'emoji': '💇', 'name': 'Hair Care', 'slug': 'haircare'},
    {'emoji': '🌸', 'name': 'Body Care', 'slug': 'bath-body'},
    {'emoji': '✨', 'name': 'Toners', 'slug': 'skincare-toner'},
    {'emoji': '📦', 'name': 'All Products', 'slug': ''},
  ];

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final lang = context.watch<LanguageProvider>();
    final isEn = lang.isEnglish;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: RefreshIndicator(
        onRefresh: () => context.read<HomeProvider>().fetchHomeData(),
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (homeProvider.isLoading && homeProvider.forYouProducts.isEmpty)
              SliverFillRemaining(child: ShimmerHomeLoader())
            else ...[
              if (!homeProvider.isLoading && homeProvider.forYouProducts.isEmpty && homeProvider.newArrivals.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.wifi_off_rounded, color: Color(0xFFEF4444), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Connection Error or Offline',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isEn
                                      ? 'Could not load products. Please tap Retry.'
                                      : 'Could not load products. Please try again.',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => context.read<HomeProvider>().fetchHomeData(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              'Retry',
                              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 1. Dynamic Hero Promotional Banner Carousel
              if (homeProvider.banners.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 175,
                          child: PageView.builder(
                            controller: _bannerController,
                            onPageChanged: (idx) => setState(() => _currentBannerPage = idx),
                            itemCount: homeProvider.banners.length,
                            itemBuilder: (context, index) {
                              final banner = homeProvider.banners[index];
                              final List<Color> gradientColors = banner.bgGradient.length >= 2
                                  ? [
                                      _parseHexColor(banner.bgGradient[0], const Color(0xFF0F172A)),
                                      _parseHexColor(banner.bgGradient[1], const Color(0xFF1E293B)),
                                    ]
                                  : const [Color(0xFF0F172A), Color(0xFF1E293B)];

                              return GestureDetector(
                                onTap: () {
                                  if (banner.targetType == 'category') {
                                    context.read<CatalogProvider>().filterByCategory(banner.targetId);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CatalogScreen(
                                          initialCategory: banner.targetId,
                                        ),
                                      ),
                                    );
                                  } else if (banner.targetType == 'brand') {
                                    context.read<CatalogProvider>().filterByBrand(banner.targetId);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CatalogScreen(
                                          initialBrand: banner.targetId,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.12),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                '100% DIRECT FROM MALAYSIA',
                                                style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              banner.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              banner.subtitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Shop Now ›',
                                                style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (banner.image.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            color: Colors.white.withValues(alpha: 0.15),
                                            padding: const EdgeInsets.all(8),
                                            child: CachedNetworkImage(
                                              imageUrl: banner.image,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.contain,
                                              errorWidget: (context, url, error) => const Icon(Icons.verified, color: Colors.white, size: 40),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Dynamic Expanding Pill Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            homeProvider.banners.length,
                            (idx) {
                              final isActive = _currentBannerPage == idx;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                width: isActive ? 22 : 6,
                                height: 5.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  gradient: isActive
                                      ? const LinearGradient(
                                          colors: [Color(0xFFFF2A6D), Color(0xFFFF7A00)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        )
                                      : null,
                                  color: isActive ? null : const Color(0xFFCBD5E1),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFFF2A6D).withValues(alpha: 0.35),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Mobile Web Signature Dual CTA Buttons ("Shop Authentic" & "Track Order")
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF2A6D), Color(0xFFFF7A00)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF2A6D).withValues(alpha: 0.28),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15),
                                  SizedBox(width: 6),
                                  Text(
                                    'Shop Authentic',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen()));
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.flight_takeoff_rounded, color: Color(0xFF6366F1), size: 15),
                                  SizedBox(width: 6),
                                  Text(
                                    'Track Order',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Authentic Trust Badges Strip
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _TrustBadgePill(icon: Icons.check_circle, label: '100% Original'),
                        _TrustBadgePill(icon: Icons.verified_outlined, label: 'Direct KL Sourced'),
                        _TrustBadgePill(icon: Icons.local_shipping_outlined, label: 'Delivery 10-25D'),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Fallback Hero Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B0764), Color(0xFF831843), Color(0xFF9A3412)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF2A6D).withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('100% Original Malaysian Cosmetics', style: TextStyle(color: Color(0xFFFF7A00), fontSize: 11, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          const Text('Glow Naturally. Love Confidently.', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          const Text('Authentic international beauty directly from Malaysia to Bangladesh.', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen())),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF2A6D),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Shop Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // 2. Shopee / Lazada Signature 8-Channel Quick Hub (2 Rows x 4 Columns)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Row 1 (4 items)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildPrestigeChannel(
                              title: 'Flash Deals',
                              badge: 'HOT',
                              icon: Icons.bolt_rounded,
                              gradient: const [Color(0xFFFF2A6D), Color(0xFFFF7A00)],
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashSaleScreen())),
                            ),
                            _buildPrestigeChannel(
                              title: 'Direct KL',
                              badge: '100%',
                              icon: Icons.flight_takeoff_rounded,
                              gradient: const [Color(0xFF0284C7), Color(0xFF06B6D4)],
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestProductScreen())),
                            ),
                            _buildPrestigeChannel(
                              title: 'GlowMall',
                              badge: 'MALL',
                              icon: Icons.verified_rounded,
                              gradient: const [Color(0xFF7C3AED), Color(0xFFA855F7)],
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BrandsScreen())),
                            ),
                            _buildPrestigeChannel(
                              title: 'Vouchers',
                              badge: '৳500',
                              icon: Icons.confirmation_num_outlined,
                              gradient: const [Color(0xFFD97706), Color(0xFFFBBF24)],
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VouchersWalletScreen())),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Row 2 (4 items)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildPrestigeChannel(
                              title: 'Track Parcel',
                              badge: 'LIVE',
                              icon: Icons.inventory_2_outlined,
                              gradient: const [Color(0xFF2563EB), Color(0xFF38BDF8)],
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen())),
                            ),
                            _buildPrestigeChannel(
                              title: 'AI Skin Studio',
                              badge: 'AI NEW',
                              icon: Icons.auto_awesome_rounded,
                              gradient: const [Color(0xFFDB2777), Color(0xFFF472B6)],
                              onTap: () => _openAiSkinConsultantModal(context),
                            ),
                            _buildPrestigeChannel(
                              title: 'Best Sellers',
                              badge: 'TOP',
                              icon: Icons.workspace_premium_rounded,
                              gradient: const [Color(0xFF059669), Color(0xFF34D399)],
                              onTap: () {
                                context.read<CatalogProvider>().setSort('rating');
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                              },
                            ),
                            _buildPrestigeChannel(
                              title: 'Help 24/7',
                              badge: 'CHAT',
                              icon: Icons.support_agent_rounded,
                              gradient: const [Color(0xFF16A34A), Color(0xFF4ADE80)],
                              onTap: () => _launchWhatsApp(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2.2. Mobile Web Signature 3-Step Secure Pre-Order Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0B1933), Color(0xFF1E1B4B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFF2A6D).withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shield_outlined, color: Color(0xFFE11D48), size: 13),
                            const SizedBox(width: 4),
                            Text(
                              '100% SECURE PRE-ORDER',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFE11D48),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Authentic Products in 3 Easy Steps',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Direct delivery from Malaysia Official Hub',
                          style: TextStyle(color: Color(0xFFFDA4AF), fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildMiniStepCard('1', '50% Advance', 'Confirm via bKash/Nagad'),
                            const SizedBox(width: 8),
                            _buildMiniStepCard('2', 'Air Cargo', 'Direct flight (10-25D)'),
                            const SizedBox(width: 8),
                            _buildMiniStepCard('3', 'Intact Seal', 'Pay balance on delivery'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              // 2.5. Skin Concern Quick Filters (Lazada / Shopee Style Quick Hub)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 15, color: Color(0xFFE11D48)),
                          const SizedBox(width: 6),
                          Text(
                            'Shop by Skin Concern',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildConcernPill(
                              icon: '🌸',
                              label: 'Acne Care',
                              query: 'acne',
                              context: context,
                            ),
                            const SizedBox(width: 8),
                            _buildConcernPill(
                              icon: '✨',
                              label: 'Brightening',
                              query: 'brightening',
                              context: context,
                            ),
                            const SizedBox(width: 8),
                            _buildConcernPill(
                              icon: '💧',
                              label: 'Hydration',
                              query: 'moisturizer',
                              context: context,
                            ),
                            const SizedBox(width: 8),
                            _buildConcernPill(
                              icon: '☀️',
                              label: 'Sun Protection',
                              query: 'sunscreen',
                              context: context,
                            ),
                            const SizedBox(width: 8),
                            _buildConcernPill(
                              icon: '🛡️',
                              label: 'Dark Spots',
                              query: 'serum',
                              context: context,
                            ),
                            const SizedBox(width: 8),
                            _buildConcernPill(
                              icon: '🌿',
                              label: 'Anti-Aging',
                              query: 'anti aging',
                              context: context,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Shopee / Lazada Shocking Sale (Flash Deals) Carousel Section
              if (homeProvider.isFlashSaleActive)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF1F2), Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFFD1D8), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF2A6D).withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF385C), Color(0xFFFF7A00)],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF385C).withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.bolt, color: Colors.white, size: 14),
                                        SizedBox(width: 3),
                                        Text(
                                          'SHOCKING SALE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 10.5,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CountdownTimerWidget(
                                    endTimestamp: homeProvider.flashSaleEndTime,
                                    badgeColor: const Color(0xFF1E293B),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashSaleScreen())),
                                child: Text(
                                  'See All ›',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accentPink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Shopee Signature Horizontal Flash Reel (Fast Swiping)
                          SizedBox(
                            height: 242,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: homeProvider.flashProducts.take(8).length,
                              separatorBuilder: (_, index) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: 146,
                                  child: ProductCard(
                                    product: homeProvider.flashProducts[index],
                                    isFlashSale: true,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 4. Shopee Mall / LazMall Official Brands Hub
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Official Mall Ribbon
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF1F2), Color(0xFFFFFBEB)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFCCD5), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.verified, color: Color(0xFFD0011B), size: 14),
                                SizedBox(width: 3.5),
                                Text('100% Authentic', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFD0011B))),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.sync_rounded, color: Color(0xFF0284C7), size: 14),
                                SizedBox(width: 3.5),
                                Text('15-Day Return', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.local_shipping_outlined, color: Color(0xFF059669), size: 14),
                                SizedBox(width: 3.5),
                                Text('Direct KL Stock', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFD0011B), Color(0xFFFF2A6D)],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'MALL',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Official Brand Stores',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const BrandsScreen()));
                            },
                            child: const Text('View All ›', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Shop your favourite global brands',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _officialWebBrands.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (context, index) {
                          final brand = _officialWebBrands[index];
                          return GestureDetector(
                            onTap: () {
                              context.read<CatalogProvider>().filterByBrand(brand['slug']);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CatalogScreen(
                                    initialBrand: brand['slug'],
                                    initialBrandName: brand['name'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderSubtle),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/brands/${brand['slug']}.png',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => CachedNetworkImage(
                                    imageUrl: brand['logo']!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                                    ),
                                    errorWidget: (context, url, error) => Text(
                                      brand['name']!,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 9.5, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Mobile Web Section 17: Trending Now (2-Column Grid)
              if (homeProvider.trending.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up_rounded, color: Color(0xFFE11D48), size: 19),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trending Now', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14.5, color: const Color(0xFF0F172A))),
                            const Text('Flying off the shelves this week', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            context.read<CatalogProvider>().setSort('popularity');
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                          },
                          child: const Text('View All ›', style: TextStyle(fontSize: 11.5, color: Color(0xFFE11D48), fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.59,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ProductCard(
                          product: homeProvider.trending[index],
                          isFlashSale: false,
                        );
                      },
                      childCount: homeProvider.trending.take(4).length,
                    ),
                  ),
                ),
              ],

              // Mobile Web Section 18: Weekly Deals (2-Column Grid)
              if (homeProvider.weeklyDeals.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer_rounded, color: Color(0xFFFF7A00), size: 18),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Weekly Deals', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14.5, color: const Color(0xFF0F172A))),
                            const Text('Fresh discounts every week', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashSaleScreen()));
                          },
                          child: const Text('Shop Deals ›', style: TextStyle(fontSize: 11.5, color: Color(0xFFFF7A00), fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.59,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ProductCard(
                          product: homeProvider.weeklyDeals[index],
                          isFlashSale: true,
                        );
                      },
                      childCount: homeProvider.weeklyDeals.take(4).length,
                    ),
                  ),
                ),
              ],




              // 6. 4 Quad Feature Promo Banners Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _buildPromoCard('Best Sellers', 'Top rated & most loved', const Color(0xFF7C3AED), const Color(0xFFF5F3FF), () {
                        context.read<CatalogProvider>().setSort('rating');
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                      }),
                      _buildPromoCard('Bundle & Save', 'More buys, more saves', const Color(0xFF059669), const Color(0xFFECFDF5), () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                      }),
                      _buildPromoCard('Clearance Sale', 'Up to 60% OFF', const Color(0xFFE11D48), const Color(0xFFFFF1F2), () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                      }),
                      _buildPromoCard('Authentic KL', 'Fresh Counter Stock', const Color(0xFF0284C7), const Color(0xFFF0F9FF), () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                      }),
                    ],
                  ),
                ),
              ),

              // 7. Complete Your Routine Combo Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
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
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: AppColors.accentPink, size: 16),
                                const SizedBox(width: 4),
                                Text('Complete Your Skincare Routine', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13.5)),
                              ],
                            ),
                            const Text('3-Step Essentials', style: TextStyle(color: AppColors.accentPink, fontWeight: FontWeight.w800, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildRoutineStepPill('1. Cleanse', 'facial-cleanser', Icons.water_drop_outlined),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textMuted)),
                            _buildRoutineStepPill('2. Hydrate', 'skincare-moisturizer', Icons.spa_outlined),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textMuted)),
                            _buildRoutineStepPill('3. Protect', 'sunscreen', Icons.wb_sunny_outlined),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen())),
                            icon: const Icon(Icons.tune, color: Colors.white, size: 15),
                            label: const Text('BUILD YOUR DAILY ROUTINE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11.5)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentPink,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 8. Shop by Category (3-Column Grid 100% Matching Mobile Website gbm-catgrid)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shop by Category', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14.5, color: AppColors.textPrimary)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
                            },
                            child: const Text('All Categories ›', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Find what you need',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _officialWebCategories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2.2,
                        ),
                        itemBuilder: (context, index) {
                          final cat = _officialWebCategories[index];
                          return GestureDetector(
                            onTap: () {
                              if (cat['slug']!.isNotEmpty) {
                                context.read<CatalogProvider>().filterByCategory(cat['slug']!);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CatalogScreen(
                                      initialCategory: cat['slug'],
                                      initialCategoryName: cat['name'],
                                    ),
                                  ),
                                );
                              } else {
                                context.read<CatalogProvider>().resetFilters();
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.borderSubtle),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(cat['emoji']!, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      cat['name']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),


              // Mobile Web Section 16: Mid Sourcing Studio Showcase Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7A00).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, color: Color(0xFFFF7A00), size: 12),
                              SizedBox(width: 4),
                              Text('100% AUTHENTIC SOURCING', style: TextStyle(color: Color(0xFFFF7A00), fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Direct Air Cargo From Malaysia Hub',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '100% genuine skincare and beauty products dispatched directly from Kuala Lumpur to Dhaka.',
                          style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5, height: 1.35),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  showSearch(context: context, delegate: SmartSearchDelegate());
                                },
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search, color: Colors.white, size: 15),
                                      SizedBox(width: 6),
                                      Text('Search by Name', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualSearchScreen(initialSource: ImageSource.camera)));
                                },
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF2A6D), Color(0xFFFF7A00)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt_outlined, color: Colors.white, size: 15),
                                      SizedBox(width: 6),
                                      Text('Search by Photo', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 8.5. Recently Viewed Section (If any products viewed)
              if (homeProvider.recentlyViewed.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.history, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text('Recently Viewed', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14)),
                        const Spacer(),
                        const Text('Your browsing history', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 250,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      scrollDirection: Axis.horizontal,
                      itemCount: homeProvider.recentlyViewed.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 155,
                          child: ProductCard(product: homeProvider.recentlyViewed[index]),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // 8.6. Best Sellers Section (Clean 2-Column Grid Layout)
              if (homeProvider.bestSellers.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Color(0xFFFF7A00), size: 18),
                        const SizedBox(width: 6),
                        Text('Best Sellers', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14.5)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            context.read<CatalogProvider>().setSort('popularity');
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                          },
                          child: const Text('View All ›', style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.59,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ProductCard(
                          product: homeProvider.bestSellers[index],
                          isFlashSale: false,
                        );
                      },
                      childCount: homeProvider.bestSellers.take(4).length,
                    ),
                  ),
                ),
              ],

              // 8.7. New Arrivals Section (Clean 2-Column Grid Layout)
              if (homeProvider.newArrivals.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.new_releases_outlined, color: Color(0xFF0284C7), size: 18),
                        const SizedBox(width: 6),
                        Text('New Arrivals', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14.5)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            context.read<CatalogProvider>().setSort('date');
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                          },
                          child: const Text('View All ›', style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.59,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ProductCard(
                          product: homeProvider.newArrivals[index],
                          isFlashSale: false,
                        );
                      },
                      childCount: homeProvider.newArrivals.take(4).length,
                    ),
                  ),
                ),
              ],

              // 9. "Just For You" Personalized Feed Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: AppColors.accentPink, size: 16),
                      const SizedBox(width: 6),
                      Text('Just For You', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14.5)),
                      const Spacer(),
                      const Text('Direct from Malaysia', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

              // 10. 2-Column Product Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.59,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final prod = homeProvider.forYouProducts[index];
                      return ProductCard(
                        product: prod,
                        isFlashSale: false,
                      );
                    },
                    childCount: homeProvider.forYouProducts.length,
                  ),
                ),
              ),

              // 11. How Pre-Order Works (Direct Import 10-25 Days Guide)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: const Color(0xFF3B82F6).withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF3B82F6), size: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'How Pre-Order Works (10–25 Days)',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStepItem(
                          '1',
                          '50% Advance Booking',
                          isEn
                              ? 'Pay 50% deposit via bKash/Nagad to confirm your pre-order.'
                              : 'Book with 50% advance via bKash/Nagad to confirm your order.',
                        ),
                        _buildStepItem(
                          '2',
                          'Direct Sourcing in Kuala Lumpur',
                          isEn
                              ? 'Our Malaysia team procures fresh authentic batches from authorized outlets.'
                              : 'Our team sources fresh batches directly from authorized Malaysian pharmacies.',
                        ),
                        _buildStepItem(
                          '3',
                          'Air Cargo Transit & Safe Packing',
                          isEn
                              ? 'Flown to Dhaka via Air Cargo keeping original intact seals and secure packaging.'
                              : 'Dispatched to Dhaka with original intact seals and secure packaging.',
                        ),
                        _buildStepItem(
                          '4',
                          'Home Delivery + Remaining 50% COD',
                          isEn
                              ? 'Inspect your parcel upon delivery and pay the remaining 50% to courier.'
                              : 'Check parcel at doorstep and pay remaining 50% cash on delivery.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 12. What Customers Say (Verified Buyer Reviews)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
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
                            Text(
                              'What Customers Say',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13.5),
                            ),
                            const Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 14),
                                SizedBox(width: 2),
                                Text('Verified Reviews', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (homeProvider.reviews.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Text(
                                'Authentic reviews from verified buyers are loaded directly from store orders.',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          ...homeProvider.reviews.take(3).map((r) => _buildDynamicReview(r)),
                      ],
                    ),
                  ),
                ),
              ),

              // 13. Why Shop With GlowBayBD (Trust Bento Grid)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Why Shop With GlowBayBD', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13.5)),
                        const SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 2.3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: const [
                            _TrustCard(icon: Icons.check_circle_outline, color: AppColors.authenticGreen, title: '100% Original', desc: 'Direct KL Sourced'),
                            _TrustCard(icon: Icons.local_shipping_outlined, color: Color(0xFF3B82F6), title: 'Direct Import', desc: '10-25 Days Timeline'),
                            _TrustCard(icon: Icons.moped_outlined, color: Color(0xFFF59E0B), title: 'Pathao Tracking', desc: 'Live Parcel Map'),
                            _TrustCard(icon: Icons.credit_card, color: AppColors.accentPink, title: '50% Advance', desc: '50% on Delivery COD'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              // Mobile Web Section 12: Instagram Community Showcase
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.camera_rounded, color: Colors.white, size: 15),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Instagram', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13.5)),
                                const Text('@glowbaybd', style: TextStyle(fontSize: 10.5, color: Color(0xFFE11D48), fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () => launchUrl(Uri.parse('https://instagram.com/glowbaybd'), mode: LaunchMode.externalApplication),
                              child: const Row(
                                children: [
                                  Text('Follow', style: TextStyle(color: Color(0xFFE11D48), fontSize: 11.5, fontWeight: FontWeight.w800)),
                                  SizedBox(width: 2),
                                  Icon(Icons.arrow_forward_ios, color: Color(0xFFE11D48), size: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInstagramPhotoCard('assets/images/logo_badge.png', 'Official Unboxing', () {
                              launchUrl(Uri.parse('https://instagram.com/glowbaybd'), mode: LaunchMode.externalApplication);
                            }),
                            const SizedBox(width: 8),
                            _buildInstagramPhotoCard(null, 'Fresh KL Stock', () {
                              launchUrl(Uri.parse('https://instagram.com/glowbaybd'), mode: LaunchMode.externalApplication);
                            }),
                            const SizedBox(width: 8),
                            _buildInstagramPhotoCard(null, 'Glow Community', () {
                              launchUrl(Uri.parse('https://instagram.com/glowbaybd'), mode: LaunchMode.externalApplication);
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Mobile Web Section 15: Beauty Tips & Guides
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu_book_rounded, color: Color(0xFF6366F1), size: 18),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Beauty Tips & Guides', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13.5)),
                                const Text('Tips, ingredient guides & how-tos', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen())),
                              child: const Text('View All ›', style: TextStyle(fontSize: 11.5, color: Color(0xFF6366F1), fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 125,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildTipCard('Layering Niacinamide & Vit C', 'Clear, radiant barrier repair routine.', Icons.spa_rounded, const Color(0xFFF5F3FF), const Color(0xFF7C3AED)),
                              _buildTipCard('Choosing the Right Daily SPF', 'Lightweight sunscreens for humidity.', Icons.wb_sunny_rounded, const Color(0xFFFFFBEB), const Color(0xFFD97706)),
                              _buildTipCard('Pre-Order Skincare Guide', 'How to save big with authentic direct flights.', Icons.flight_takeoff_rounded, const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Mobile Web Section 21: Homepage FAQ Accordion
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE4E6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'FAQ',
                                  style: TextStyle(
                                    color: Color(0xFFE11D48),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Frequently Asked Questions',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.5,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFaqTile(
                          'Are the products 100% authentic Malaysian?',
                          'Yes, 100% authentic guaranteed. All products are procured directly from authorized brand distributors and pharmacies in Kuala Lumpur, Malaysia with intact factory seals.',
                        ),
                        const SizedBox(height: 8),
                        _buildFaqTile(
                          'How does the 50% advance booking policy work?',
                          'You confirm your pre-order by paying 50% advance via bKash or Nagad. The remaining 50% balance is paid via Cash on Delivery when you receive your parcel at your doorstep.',
                        ),
                        const SizedBox(height: 8),
                        _buildFaqTile(
                          'How long does air cargo delivery take?',
                          'Direct air delivery from our Malaysia hub takes approximately 10 to 25 business days, with live parcel tracking provided.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 14. Payment Methods & Security Strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lock_outline, color: AppColors.authenticGreen, size: 16),
                            SizedBox(width: 6),
                            Text('Safe & Flexible Payment Methods', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'bKash, Nagad, Rocket, Visa, Mastercard and 50% Cash on Delivery supported with 256-bit SSL encryption.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildPaymentBadge('bKash'),
                            const SizedBox(width: 6),
                            _buildPaymentBadge('Nagad'),
                            const SizedBox(width: 6),
                            _buildPaymentBadge('Rocket'),
                            const SizedBox(width: 6),
                            _buildPaymentBadge('50% COD'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrestigeChannel({
    required String title,
    required String badge,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                ),
                if (badge.isNotEmpty)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF1F78), Color(0xFFFF5E3A)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConcernPill({
    required String icon,
    required String label,
    required String query,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<CatalogProvider>().resetFilters();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CatalogScreen(
              initialSearch: query,
              initialCategoryName: label,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12.5)),
            const SizedBox(width: 5.5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard(String title, String desc, Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineStepPill(String step, String categorySlug, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CatalogScreen(initialCategory: categorySlug))),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.accentPink),
              const SizedBox(height: 4),
              Text(step, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5, color: AppColors.textPrimary), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary, height: 1.3),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w800)),
                  TextSpan(text: desc, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicReview(ReviewModel r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(r.author, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  if (r.verified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: AppColors.authenticGreen, size: 13),
                  ],
                ],
              ),
              Row(
                children: List.generate(
                  r.rating.clamp(1, 5),
                  (_) => const Icon(Icons.star, color: Colors.amber, size: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(r.content, style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.3)),
          const SizedBox(height: 2),
          Text('${r.productName}${r.date.isNotEmpty ? ' • ${r.date}' : ''}', style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
          const Divider(height: 14),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    );
  }

  void _openAiSkinConsultantModal(BuildContext context) {
    HapticFeedback.lightImpact();
    final isEn = context.read<LanguageProvider>().isEnglish;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF2A6D), Color(0xFFFF7A00)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Skincare & Scanner',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Personalized routine & authentic product match',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Option 1: AI Skin Consultant Live Studio
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  LauncherHelper.openAiSkinConsultant(context: context);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF1F2), Color(0xFFFFFBEB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFECDD3), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2A6D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.face_retouching_natural_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'AI Skin Analysis Studio',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF2A6D),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('LIVE AI', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isEn
                                  ? 'Identify skin type, concerns & get dermatologist-backed recommendations'
                                  : 'Analyze skin type and concerns for dermatologist-grade suggestions',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFFF2A6D)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Option 2: Visual Product Scanner
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualSearchScreen()));
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visual Product Scanner',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isEn
                                  ? 'Snap or upload any skincare bottle to find authentic price & stock'
                                  : 'Snap product packaging to check authentic Malaysian stock and pricing',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseHexColor(String hex, Color fallback) {
    try {
      String clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) clean = 'FF$clean';
      return Color(int.parse(clean, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  Widget _buildMiniStepCard(String num, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFFF2A6D),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 6),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(subtitle, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          dense: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF475569),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String desc, IconData icon, Color bg, Color accent) {
    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: accent,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstagramPhotoCard(String? assetPath, String caption, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 105,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (assetPath != null)
                Image.asset(assetPath, fit: BoxFit.cover)
              else
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFEFF3), Color(0xFFFFF0E6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.photo_library_outlined, color: Color(0xFFFDA4AF), size: 28),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  color: Colors.black.withValues(alpha: 0.65),
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

class _TrustBadgePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadgePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.authenticGreen, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 10.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _TrustCard({required this.icon, required this.color, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
