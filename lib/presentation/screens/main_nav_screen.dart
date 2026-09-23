import 'dart:async';
import '../../logic/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../logic/auth_provider.dart';
import '../../logic/cart_provider.dart';
import '../../logic/catalog_provider.dart';
import '../../logic/home_provider.dart';
import '../../logic/wishlist_provider.dart';
import '../../data/services/notification_service.dart';
import 'account/account_screen.dart';
import 'cart/cart_screen.dart';
import 'subpages/wishlist_screen.dart';
import 'catalog/brands_screen.dart';
import 'catalog/catalog_screen.dart';
import 'catalog/flash_sale_screen.dart';
import 'catalog/smart_search_delegate.dart';
import 'home/home_screen.dart';
import 'subpages/notifications_screen.dart';
import 'subpages/order_tracking_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'subpages/visual_search_screen.dart';
import '../widgets/voice_search_modal.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isHeaderCollapsed = false;
  int _searchHintIndex = 0;
  Timer? _searchHintTimer;

  static const List<String> _searchHintsEn = [
    'Search CeraVe Moisturising Cream...',
    'Search La Roche-Posay Anthelios SPF 50...',
    'Search COSRX Snail Mucin 96...',
    'Search The Ordinary Niacinamide...',
    'Search Watsons / Cetaphil cleansers...',
    'Search authentic skincare...',
  ];

  static const List<String> _searchHintsBn = [
    'সেরাভে ময়েশ্চারাইজিং ক্রিম খুঁজুন...',
    'লা রোশ-পোসে সানস্ক্রিন এসপিএফ ৫০...',
    'কক্সরেক্স স্নেল মিউসিন এসেন্স...',
    'দ্য অর্ডিনারি নায়াসিনামাইড সিরাম...',
    'আসল মালয়েশিয়ান ও কোরিয়ান স্কিনকেয়ার...',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startSearchHintTimer();
  }

  void _startSearchHintTimer() {
    _searchHintTimer?.cancel();
    _searchHintTimer = Timer.periodic(const Duration(milliseconds: 3200), (timer) {
      if (!mounted) return;
      setState(() {
        _searchHintIndex = (_searchHintIndex + 1) % _searchHintsEn.length;
      });
    });
  }

  @override
  void dispose() {
    _searchHintTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HomeProvider>().fetchHomeData(silent: true);
      context.read<CatalogProvider>().fetchProducts();
      if (context.read<AuthProvider>().isLoggedIn) {
        context.read<AuthProvider>().fetchDashboard();
      }
    }
  }

  void _openVoiceSearch() async {
    final query = await VoiceSearchModal.show(context);
    if (query != null && query.trim().isNotEmpty && mounted) {
      showSearch(
        context: context,
        delegate: SmartSearchDelegate(),
        query: query.trim(),
      );
    }
  }

  void _openVisualSearch() {
    final isEn = context.read<LanguageProvider>().isEnglish;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEn ? 'Visual Skincare Search' : 'ভিজ্যুয়াল স্কিনকেয়ার সার্চ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEn ? 'Search any beauty product by taking a photo or from gallery' : 'ছবি তুলে বা গ্যালারি থেকে যেকোনো বিউটি প্রোডাক্ট খুঁজুন',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VisualSearchScreen(initialSource: ImageSource.camera),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE11D48),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isEn ? 'Take Photo' : 'ছবি তুলুন',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFBE123C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VisualSearchScreen(initialSource: ImageSource.gallery),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isEn ? 'From Gallery' : 'গ্যালারি থেকে নিন',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final isEn = langProvider.isEnglish;
    final cart = context.watch<CartProvider>();
    final showSearchBar = _currentIndex == 0 || _currentIndex == 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Top Header (Crisp White Lazada / Shopee Light Flagship Theme - Hidden on My Account tab)
            if (_currentIndex != 4) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOutCubic,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
              ),
              padding: EdgeInsets.fromLTRB(14, 42, 14, (_isHeaderCollapsed && showSearchBar) ? 8 : 10),
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                firstCurve: Curves.easeOutCubic,
                secondCurve: Curves.easeInCubic,
                crossFadeState: (_isHeaderCollapsed && showSearchBar)
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Title Bar (Logo + GlowBay MALL + Notifications + Cart)
                    Row(
                      children: [
                        // GB Official Round Badge
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo_badge.png',
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'GlowBay',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFBE123C), Color(0xFFE11D48)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE11D48).withValues(alpha: 0.25),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, color: Colors.white, size: 9),
                                  SizedBox(width: 2.5),
                                  Text(
                                    'MALL',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _buildWishlistButton(),
                        const SizedBox(width: 14),
                        _buildNotificationBell(),
                        const SizedBox(width: 14),
                        _buildCartButton(cart),
                        const SizedBox(width: 2),
                      ],
                    ),
                    if (showSearchBar) ...[
                      const SizedBox(height: 10),
                      // Smart Search Capsule Bar (Opens Live Plugin Synchronized Search)
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  showSearch(
                                    context: context,
                                    delegate: SmartSearchDelegate(),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search_rounded, color: Color(0xFFE11D48), size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 350),
                                          transitionBuilder: (child, anim) => SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.4),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                                            child: FadeTransition(opacity: anim, child: child),
                                          ),
                                          child: Text(
                                            isEn
                                                ? _searchHintsEn[_searchHintIndex % _searchHintsEn.length]
                                                : _searchHintsBn[_searchHintIndex % _searchHintsBn.length],
                                            key: ValueKey<int>(_searchHintIndex),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Camera Icon
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _openVisualSearch,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                child: Icon(Icons.camera_alt_outlined, color: Color(0xFF64748B), size: 19),
                              ),
                            ),
                            // Voice Mic Icon
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _openVoiceSearch,
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE4E6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.mic_rounded, color: Color(0xFFE11D48), size: 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Category Chips Bar
                      _buildCategoryChipsBar(),
                    ],
                  ],
                ),
                secondChild: Row(
                  children: [
                    // Brand Badge Compact
                    ClipOval(
                      child: Image.asset(
                        'assets/images/logo_badge.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Compact Search Capsule Bar
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  showSearch(
                                    context: context,
                                    delegate: SmartSearchDelegate(),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search_rounded, color: Color(0xFFE11D48), size: 18),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          isEn ? 'Search products...' : 'পণ্য খুঁজুন...',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _openVisualSearch,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                child: Icon(Icons.camera_alt_outlined, color: Color(0xFF64748B), size: 17),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _openVoiceSearch,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 2, right: 8, top: 6, bottom: 6),
                                child: Icon(Icons.mic_rounded, color: Color(0xFFE11D48), size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildWishlistButton(),
                    const SizedBox(width: 10),
                    _buildNotificationBell(),
                    const SizedBox(width: 12),
                    _buildCartButton(cart),
                    const SizedBox(width: 2),
                  ],
                ),
              ),
            ),

              // Subtle Sunset Accent Trim
              Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFFFF7A00)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ],

            // Active Screen Body with Scroll Notification Listener
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (showSearchBar && notification.metrics.axis == Axis.vertical) {
                    if (notification is ScrollUpdateNotification) {
                      final delta = notification.scrollDelta ?? 0;
                      if (delta > 3 && notification.metrics.pixels > 35) {
                        if (!_isHeaderCollapsed) {
                          setState(() => _isHeaderCollapsed = true);
                        }
                      } else if (delta < -3 || notification.metrics.pixels <= 15) {
                        if (_isHeaderCollapsed) {
                          setState(() => _isHeaderCollapsed = false);
                        }
                      }
                    }
                  }
                  return false;
                },
                child: IndexedStack(
                  key: ValueKey('main_nav_stack_${langProvider.currentLanguage}'),
                  index: _currentIndex,
                  children: [
                    HomeScreen(key: ValueKey('home_${langProvider.currentLanguage}')),
                    FlashSaleScreen(key: ValueKey('flash_${langProvider.currentLanguage}')),
                    BrandsScreen(key: ValueKey('brands_${langProvider.currentLanguage}')),
                    OrderTrackingScreen(key: ValueKey('tracking_${langProvider.currentLanguage}')),
                    AccountScreen(
                      key: ValueKey('account_${langProvider.currentLanguage}'),
                      onBackToHome: () {
                        setState(() {
                          _currentIndex = 0;
                          _isHeaderCollapsed = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // 5-Tab Bottom Navigation Bar (Hidden on Login / Auth page when logged out)
        bottomNavigationBar: (_currentIndex == 4 && !context.watch<AuthProvider>().isLoggedIn)
            ? null
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.borderSubtle, width: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              HapticFeedback.selectionClick();
              setState(() {
                _currentIndex = index;
                _isHeaderCollapsed = false;
              });
              if (index == 0) {
                context.read<HomeProvider>().fetchHomeData(silent: true);
              } else if (index == 1) {
                context.read<CatalogProvider>().fetchProducts();
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFFFF2374),
            unselectedItemColor: const Color(0xFF64748B),
            selectedFontSize: 11,
            unselectedFontSize: 10.5,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.1),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: _buildLazadaActiveIcon(Icons.home_rounded),
                label: context.watch<LanguageProvider>().isEnglish ? 'Home' : 'হোম',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bolt_outlined),
                activeIcon: _buildLazadaActiveIcon(Icons.bolt_rounded),
                label: context.watch<LanguageProvider>().isEnglish ? 'Flash Deals' : 'ফ্ল্যাশ ডিল',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.verified_outlined),
                activeIcon: _buildLazadaActiveIcon(Icons.verified_rounded),
                label: context.watch<LanguageProvider>().isEnglish ? 'Brands' : 'ব্র্যান্ড',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.local_shipping_outlined),
                activeIcon: _buildLazadaActiveIcon(Icons.local_shipping_rounded),
                label: context.watch<LanguageProvider>().isEnglish ? 'Track Order' : 'ট্র্যাকিং',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: _buildLazadaActiveIcon(Icons.person_rounded),
                label: context.watch<LanguageProvider>().isEnglish ? 'Account' : 'অ্যাকাউন্ট',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLazadaActiveIcon(IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF2A6D), Color(0xFFFF7A00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 2),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFFFF2A6D),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistButton() {
    return Consumer<WishlistProvider>(
      builder: (context, wishlist, _) {
        final count = wishlist.items.length;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistScreen()),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topRight,
            children: [
              const Icon(Icons.favorite_border_rounded, color: Color(0xFF0F172A), size: 24),
              if (count > 0)
                Positioned(
                  right: -5,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2374),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2374).withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(minWidth: 15),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationBell() {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationService().unreadCountNotifier,
      builder: (context, unreadCount, _) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topRight,
            children: [
              const Icon(Icons.notifications_outlined, color: Color(0xFF0F172A), size: 24),
              if (unreadCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF2374),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartButton(CartProvider cart) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topRight,
        children: [
          const Icon(Icons.shopping_bag_outlined, color: Color(0xFF0F172A), size: 24),
          if (cart.totalItemCount > 0)
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2374),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF2374).withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(minWidth: 16),
                child: Text(
                  '${cart.totalItemCount}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChipsBar() {
    final isEn = context.watch<LanguageProvider>().isEnglish;
    final chips = [
      {'name': isEn ? 'All Products' : 'সকল পণ্য', 'slug': ''},
      {'name': isEn ? 'Skincare' : 'স্কিনকেয়ার', 'slug': 'skin-care'},
      {'name': isEn ? 'Cleansers' : 'ক্লিনজার', 'slug': 'facial-cleanser'},
      {'name': isEn ? 'Moisturizers' : 'ময়েশ্চারাইজার', 'slug': 'skincare-moisturizer'},
      {'name': isEn ? 'Serums' : 'সিরাম', 'slug': 'serum'},
      {'name': isEn ? 'Sunscreen' : 'সানস্ক্রিন', 'slug': 'sunscreen'},
      {'name': isEn ? 'Haircare' : 'হেয়ার কেয়ার', 'slug': 'haircare'},
      {'name': isEn ? 'Body Care' : 'বডি কেয়ার', 'slug': 'bath-body'},
    ];

    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return GestureDetector(
            onTap: () {
              final catalog = context.read<CatalogProvider>();
              final slug = chip['slug']!;
              if (slug.isNotEmpty) {
                catalog.filterByCategory(slug);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CatalogScreen(
                      initialCategory: slug,
                      initialCategoryName: chip['name'],
                    ),
                  ),
                );
              } else {
                catalog.resetFilters();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CatalogScreen()),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              alignment: Alignment.center,
              child: Text(
                chip['name']!,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
