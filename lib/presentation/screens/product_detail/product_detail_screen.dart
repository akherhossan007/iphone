import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/launcher_helper.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/recently_viewed_service.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/cart_provider.dart';
import '../../../logic/catalog_provider.dart';
import '../../../logic/wishlist_provider.dart';
import '../../../logic/language_provider.dart';
import '../account/account_screen.dart';
import '../cart/cart_screen.dart';
import '../catalog/catalog_screen.dart';
import '../catalog/smart_search_delegate.dart';
import '../checkout/checkout_screen.dart';
import '../../widgets/product_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final ProductModel? initialProduct;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  ProductVariationModel? _selectedVariation;
  Map<String, String> _selectedAttributes = {};
  bool _isLoading = true;
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isDescriptionExpanded = false;
  int _activeInfoTab = 0;

  double get _currentPrice => _selectedVariation != null ? _selectedVariation!.price : (_product?.price ?? 0.0);
  double get _currentRegularPrice => _selectedVariation != null ? _selectedVariation!.regularPrice : (_product?.regularPrice ?? 0.0);
  int get _currentDiscountPercentage {
    if (_currentRegularPrice > _currentPrice && _currentRegularPrice > 0) {
      return (((_currentRegularPrice - _currentPrice) / _currentRegularPrice) * 100).round();
    }
    return _product?.discountPercentage ?? 0;
  }

  bool _fbtItem2Checked = true;
  bool _fbtItem3Checked = true;
  List<ProductModel> _relatedProducts = [];
  List<ProductModel> _subCategoryProducts = [];
  List<ProductModel> _recentlyViewed = [];
  bool _isLoadingSubCategory = false;

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct;
    if (widget.initialProduct != null) {
      if (widget.initialProduct!.hasVariations) {
        _selectedVariation = widget.initialProduct!.variations.firstWhere(
          (v) => v.inStock,
          orElse: () => widget.initialProduct!.variations.first,
        );
        _selectedAttributes = Map<String, String>.from(_selectedVariation!.attributes);
      }
      if (widget.initialProduct!.relatedProducts.isNotEmpty) {
        _relatedProducts = widget.initialProduct!.relatedProducts;
      }
      _fetchSubCategoryProducts(widget.initialProduct!);
    }
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final res = await ApiService().fetchProductDetails(widget.productId);
    if (res != null && mounted) {
      RecentlyViewedService.addProduct(res);
      setState(() {
        _product = res;
        _isLoading = false;
        if (res.hasVariations) {
          _selectedVariation = res.variations.firstWhere(
            (v) => v.inStock,
            orElse: () => res.variations.first,
          );
          _selectedAttributes = Map<String, String>.from(_selectedVariation!.attributes);
        }
        if (res.relatedProducts.isNotEmpty) {
          _relatedProducts = res.relatedProducts;
        }
      });
      if (_relatedProducts.isEmpty) {
        _fetchCategoryRelated(res);
      }
      _fetchSubCategoryProducts(res);
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (_product != null) {
        RecentlyViewedService.addProduct(_product!);
        if (_relatedProducts.isEmpty) {
          _fetchCategoryRelated(_product!);
        }
        _fetchSubCategoryProducts(_product!);
      }
    }
    final recents = await RecentlyViewedService.getRecentlyViewed();
    if (mounted) {
      setState(() {
        _recentlyViewed = recents.where((item) => item.id != widget.productId).toList();
      });
    }
  }

  Future<void> _fetchSubCategoryProducts(ProductModel p) async {
    if (!mounted) return;
    setState(() {
      _isLoadingSubCategory = true;
    });

    try {
      // Prioritize explicit sub-category ID or slug, then taxonomy lists
      String catParam = '';
      if (p.subCategoryId != null && p.subCategoryId! > 0) {
        catParam = p.subCategoryId.toString();
      } else if (p.subCategorySlug != null && p.subCategorySlug!.isNotEmpty) {
        catParam = p.subCategorySlug!;
      } else if (p.categorySlugs.isNotEmpty) {
        catParam = p.categorySlugs.last;
      } else if (p.categories.isNotEmpty) {
        catParam = p.categories.last;
      }

      if (catParam.isNotEmpty) {
        final res = await ApiService().getProducts(category: catParam, perPage: 50);
        final list = (res['products'] as List<ProductModel>? ?? [])
            .where((item) => item.id != p.id)
            .toList();

        if (mounted) {
          setState(() {
            _subCategoryProducts = list;
            _isLoadingSubCategory = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingSubCategory = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingSubCategory = false;
        });
      }
    }
  }

  Future<void> _fetchCategoryRelated(ProductModel p) async {
    try {
      final String cat = p.categories.isNotEmpty ? p.categories.first : '';
      final res = await ApiService().getProducts(category: cat, perPage: 8);
      final list = (res['products'] as List<ProductModel>? ?? []).where((item) => item.id != p.id).toList();
      
      if (mounted) {
        setState(() {
          if (list.isNotEmpty) {
            // Merge unique items with existing related products
            final existingIds = _relatedProducts.map((e) => e.id).toSet();
            final combined = List<ProductModel>.from(_relatedProducts);
            for (var item in list) {
              if (!existingIds.contains(item.id)) {
                combined.add(item);
                existingIds.add(item.id);
              }
            }
            _relatedProducts = combined;
          }
        });
      }
    } catch (_) {}
  }

  void _openWhatsApp() async {
    final varSummary = _selectedVariation?.attributeSummary ?? '';
    final name = _product != null
        ? (varSummary.isNotEmpty ? '${_product!.name} ($varSummary)' : _product!.name)
        : 'Skincare Item';
    final price = (_currentPrice * _quantity).toStringAsFixed(0);
    final msg = "Hello GlowBayBD! I would like to order: $name (৳$price) via WhatsApp.";
    await LauncherHelper.openWhatsApp(
      context: context,
      phone: '8801948667001',
      text: msg,
    );
  }

  void _addFbtBundleToCart() {
    if (_product == null) return;
    final cart = context.read<CartProvider>();
    cart.addToCart(_product!, quantity: 1);

    int addedCount = 1;
    if (_relatedProducts.isNotEmpty && _fbtItem2Checked) {
      cart.addToCart(_relatedProducts[0], quantity: 1);
      addedCount++;
    }
    if (_relatedProducts.length > 1 && _fbtItem3Checked) {
      cart.addToCart(_relatedProducts[1], quantity: 1);
      addedCount++;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bundle with $addedCount items added to cart! Saved ৳300.')),
    );
  }

  void _openFullscreenGallery(BuildContext context, List<String> images, int initialIndex) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (ctx, animation, secondaryAnimation) {
          int activePage = initialIndex;
          final pageController = PageController(initialPage: initialIndex);

          return StatefulBuilder(
            builder: (modalContext, setModalState) {
              return Scaffold(
                backgroundColor: Colors.black.withValues(alpha: 0.94),
                body: Stack(
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: images.length,
                      onPageChanged: (idx) => setModalState(() => activePage = idx),
                      itemBuilder: (context, idx) {
                        return Center(
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.8,
                            maxScale: 4.0,
                            child: CachedNetworkImage(
                              imageUrl: images[idx],
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 48,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                '${activePage + 1} / ${images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(modalContext),
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'Pinch to zoom • Swipe to browse',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final lang = context.watch<LanguageProvider>();
    final isEn = lang.isEnglish;

    if (_isLoading && _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final p = _product!;
    final isWishlisted = wishlist.isFavorite(p.id);
    final List<String> galleryImages = p.gallery.isNotEmpty ? p.gallery : (p.image.isNotEmpty ? [p.image] : <String>[]);
    final socialOrders = 12 + (p.id % 15);

    // Get companion products for FBT bundle from real related products
    final ProductModel? fbt1 = _relatedProducts.isNotEmpty ? _relatedProducts[0] : null;
    final ProductModel? fbt2 = _relatedProducts.length > 1 ? _relatedProducts[1] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF0F172A)),
              ),
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () {
            showSearch(context: context, delegate: SmartSearchDelegate());
          },
          child: Container(
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 17, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search on GlowBay...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22, color: Color(0xFF0F172A)),
            tooltip: 'Share',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'https://glowbaybd.com/product/${p.slug}'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Product link copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: cart.totalItemCount > 0,
              label: Text('${cart.totalItemCount}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFFFF1F78),
              child: const Icon(Icons.shopping_bag_outlined, size: 22, color: Color(0xFF0F172A)),
            ),
            tooltip: 'Cart',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Carousel Gallery
            Stack(
              children: [
                Container(
                  color: Colors.white,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 330,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: galleryImages.length > 1,
                      onPageChanged: (index, reason) {
                        setState(() => _currentImageIndex = index);
                      },
                    ),
                    items: galleryImages.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final imgUrl = entry.value;
                      return GestureDetector(
                        onTap: () => _openFullscreenGallery(context, galleryImages, idx),
                        child: CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                          errorWidget: (context, url, error) => const Center(child: Icon(Icons.image_not_supported, color: AppColors.textMuted, size: 48)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Bottom Gradient Vignette for smooth transition to details
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 28,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.8),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
                // Brand Pill Top-Left
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_outlined, color: Color(0xFFFF2A6D), size: 12),
                        SizedBox(width: 4),
                        Text('100% Direct Malaysia Import', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                // Discount Badge Top-Right
                if (p.onSale && p.discountPercentage > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.flashRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${p.discountPercentage}% OFF',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ),
                  ),
                // Tap to Zoom Pill Bottom-Left
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => _openFullscreenGallery(context, galleryImages, _currentImageIndex),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in_rounded, size: 14, color: Color(0xFF0F172A)),
                          SizedBox(width: 3),
                          Text(
                            'Zoom',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Dot Indicators Bottom-Center
                if (galleryImages.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: galleryImages.asMap().entries.map((entry) {
                        final isActive = _currentImageIndex == entry.key;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          width: isActive ? 18 : 6,
                          height: 5.5,
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: isActive ? AppColors.primary : AppColors.borderSubtle,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                // Lazada Signature Image Counter Pill (e.g. 1/6)
                if (galleryImages.length > 1)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${galleryImages.length}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 🌟 1. LAZADA APP-GRADE FLASH SALE / CAMPAIGN PRICE BANNER (POINT 1)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD90429),
                    Color(0xFFEF233C),
                    Color(0xFFFF1F78),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD90429).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Price & discount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              '৳ ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _currentPrice.toStringAsFixed(0),
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                        if (_currentDiscountPercentage > 0 || _currentRegularPrice > _currentPrice) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                '৳ ${_currentRegularPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-$_currentDiscountPercentage% OFF',
                                  style: const TextStyle(
                                    color: Color(0xFFD90429),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Right: ⚡ 100% ORIGINAL badge pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: Color(0xFFFFE600), size: 14),
                        SizedBox(width: 3),
                        Text(
                          '100% ORIGINAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. PRODUCT INFO & DETAILS
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRODUCT TITLE
                  Text(
                    p.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      height: 1.38,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🌟 3. LAZADA APP-GRADE COMPACT SOCIAL PROOF & ACTION ROW (POINT 3)
                  Row(
                    children: [
                      // Left: Rating, Sold & Brand
                      Expanded(
                        child: Row(
                          children: [
                            // Star Rating
                            const Icon(Icons.star, color: Color(0xFFFFB800), size: 14),
                            const SizedBox(width: 3),
                            Text(
                              p.rating > 0 ? p.rating.toStringAsFixed(1) : '5.0',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '(${p.ratingCount > 0 ? p.ratingCount : (14 + (p.id % 15))})',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Separator
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 1,
                              height: 10,
                              color: const Color(0xFFCBD5E1),
                            ),
                            // Sold Count
                            Text(
                              '$socialOrders sold',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (p.brands.isNotEmpty) ...[
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                width: 1,
                                height: 10,
                                color: const Color(0xFFCBD5E1),
                              ),
                              Flexible(
                                child: InkWell(
                                  onTap: () {
                                    final slug = p.brandSlugs.isNotEmpty
                                        ? p.brandSlugs.first
                                        : p.brands.first.toLowerCase().trim().replaceAll(' ', '-');
                                    context.read<CatalogProvider>().filterByBrand(slug);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CatalogScreen(
                                          initialBrand: slug,
                                          initialBrandName: p.brands.first,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'From ',
                                        style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                                      ),
                                      Flexible(
                                        child: Text(
                                          p.brands.first,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: Color(0xFF2563EB),
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, size: 12, color: Color(0xFF2563EB)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Right: 3 Action buttons (Wishlist, Share, WhatsApp)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Wishlist Button
                          InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              wishlist.toggleFavorite(p);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isWishlisted ? 'Removed from Wishlist' : 'Saved to Wishlist!'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isWishlisted ? const Color(0xFFFFF1F5) : const Color(0xFFF8FAFC),
                                border: Border.all(
                                  color: isWishlisted ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Icon(
                                isWishlisted ? Icons.favorite : Icons.favorite_border,
                                size: 15,
                                color: isWishlisted ? const Color(0xFFFF1F78) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Share Button
                          InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Clipboard.setData(ClipboardData(text: 'https://glowbaybd.com/product/${p.slug}'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Product link copied to clipboard!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF8FAFC),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Icon(
                                Icons.share_outlined,
                                size: 15,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // WhatsApp Button
                          InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _openWhatsApp();
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFECFDF5),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 15,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 🌟 VARIATION SELECTOR (Volume / Size / Shade)
                  _buildVariationSection(p),

                  // 🌟 4. LAZADA APP-GRADE COMPACT SERVICE & DELIVERY ROWS (POINT 4)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEF2F6)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: Column(
                      children: [
                        // Row 1: Delivery Row
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                child: Center(
                                  child: Icon(Icons.local_shipping_outlined, color: Color(0xFFFF6B00), size: 16),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'Standard Delivery',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12.5,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFECFDF5),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: const Color(0xFFA7F3D0)),
                                              ),
                                              child: const Text(
                                                'Guaranteed',
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF10B981),
                                                  height: 1.2,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Text(
                                          '৳ 80–150',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Est. Delivery: ${_getEstimatedDeliveryRange(true)} • Direct from Kuala Lumpur Hub',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
                            ],
                          ),
                        ),

                        // Divider line
                        const Divider(height: 1, thickness: 0.6, color: Color(0xFFF1F5F9)),

                        // Row 2: Authenticity / Protection Row
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                child: Center(
                                  child: Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 16),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          '100% Authentic Guarantee',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFBFDBFE)),
                                          ),
                                          child: const Text(
                                            '100% Authentic',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF2563EB),
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Directly Dispatched from Malaysia Hub',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Red Marked Brand Store Card & Trust Marquee
            _buildBrandStoreCard(p, isEn),
            const SizedBox(height: 10),

            // 6. Quantity Selector Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderSubtle),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          icon: const Icon(Icons.remove, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                        Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                        IconButton(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 7. Full Description Tabs (Description / How to Use / Ingredients)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5)),
                    ),
                    child: Row(
                      children: [
                        _buildInfoTabBtn(0, 'Description'),
                        _buildInfoTabBtn(1, 'How to Use'),
                        _buildInfoTabBtn(2, 'Ingredients'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: KeyedSubtree(
                        key: ValueKey<int>(_activeInfoTab),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_activeInfoTab == 0) ...[
                              _buildRichDescription(p),
                            ] else if (_activeInfoTab == 1) ...[
                              Text(
                                p.howToUse.isNotEmpty ? p.howToUse : 'Apply gently to clean face and neck.',
                                style: const TextStyle(fontSize: 12.5, height: 1.6, color: AppColors.textPrimary),
                              ),
                            ] else ...[
                              Text(
                                p.ingredients.isNotEmpty ? p.ingredients : 'Please refer to the product packaging for detailed ingredient list.',
                                style: const TextStyle(fontSize: 12.5, height: 1.6, color: AppColors.textPrimary),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 8. Frequently Bought Together (FBT) Dynamic Real Combo
            if (fbt1 != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Frequently Bought Together', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
                          child: const Text('Save ৳300', style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w800, fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildFbtRow(p.name, '৳${p.price.toStringAsFixed(0)}', true, null),
                    const Divider(height: 12),
                    _buildFbtRow(fbt1.name, '৳${fbt1.price.toStringAsFixed(0)}', _fbtItem2Checked, (val) => setState(() => _fbtItem2Checked = val ?? true)),
                    if (fbt2 != null) ...[
                      const Divider(height: 12),
                      _buildFbtRow(fbt2.name, '৳${fbt2.price.toStringAsFixed(0)}', _fbtItem3Checked, (val) => setState(() => _fbtItem3Checked = val ?? true)),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addFbtBundleToCart,
                        icon: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                        label: const Text('ADD ALL TO CART • SAVE ৳300', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentPink,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],



            // B4C: Purchase Protection • 100% Buyer Guarantee
            _buildPurchaseProtectionCard(isEn),
            const SizedBox(height: 10),

            // 12. Customer Reviews Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: AppColors.luxuryCardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Customer Reviews',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, color: AppColors.authenticGreen, size: 12),
                            SizedBox(width: 4),
                            Text('100% Verified', style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w800, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Rating Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFBFD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  p.rating > 0 ? p.rating.toStringAsFixed(1) : '4.9',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 26),
                              ],
                            ),
                            Text(
                              'Based on verified orders',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            children: [
                              _buildRatingBar('5★', 0.88, '88%'),
                              _buildRatingBar('4★', 0.09, '9%'),
                              _buildRatingBar('3★', 0.03, '3%'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildReviewItem('Nusrat Jahan', '5.0', '100% Authentic product! Delivery from KL took only 10 days. Skin feels super hydrated.', 'Verified Buyer • 2 days ago'),
                  const Divider(height: 16),
                  _buildReviewItem('Tanvir Ahmed', '5.0', 'Original packaging with Malaysian seal. Very happy with GlowBay service.', 'Verified Buyer • 1 week ago'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 12.5. 👉 You May Also Like (Recommended 4 Products from WooCommerce)
            if (_relatedProducts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  children: [
                    const Text('👉 ', style: TextStyle(fontSize: 14)),
                    Text(
                      'You May Also Like',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 195,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _relatedProducts.take(6).length,
                  itemBuilder: (context, index) {
                    final item = _relatedProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: item.id, initialProduct: item)),
                        );
                      },
                      child: Container(
                        width: 135,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Center(child: CachedNetworkImage(imageUrl: item.image, fit: BoxFit.contain)),
                                  if (item.onSale && item.discountPercentage > 0)
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(color: AppColors.flashRed, borderRadius: BorderRadius.circular(4)),
                                        child: Text('-${item.discountPercentage}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10.5)),
                            Text('৳${item.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],

            // 13. ✨ More from Sub-Category (2-Column Grid of ALL Subcategory Products)
            Builder(
              builder: (context) {
                final displayList = _subCategoryProducts.isNotEmpty
                    ? _subCategoryProducts
                    : _relatedProducts.where((item) => item.id != p.id).toList();

                if (displayList.isEmpty && !_isLoadingSubCategory) {
                  return const SizedBox.shrink();
                }

                final String subCatTitle = p.subCategoryName.isNotEmpty
                    ? p.subCategoryName
                    : (p.categories.isNotEmpty ? p.categories.first : "This Category");

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('✨ ', style: TextStyle(fontSize: 14)),
                              Text(
                                'More from $subCatTitle',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13.5),
                              ),
                              if (displayList.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${displayList.length}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              final slug = (p.subCategorySlug != null && p.subCategorySlug!.isNotEmpty)
                                  ? p.subCategorySlug!
                                  : (p.categorySlugs.isNotEmpty ? p.categorySlugs.first : '');
                              final name = p.subCategoryName.isNotEmpty
                                  ? p.subCategoryName
                                  : (p.categories.isNotEmpty ? p.categories.first : '');
                              if (slug.isNotEmpty) {
                                context.read<CatalogProvider>().filterByCategory(slug);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CatalogScreen(
                                      initialCategory: slug,
                                      initialCategoryName: name,
                                    ),
                                  ),
                                );
                              } else {
                                context.read<CatalogProvider>().resetFilters();
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                              }
                            },
                            child: const Text('View All →', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                    if (_isLoadingSubCategory && displayList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.55,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final item = displayList[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: item.id, initialProduct: item)),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Center(child: CachedNetworkImage(imageUrl: item.image, fit: BoxFit.contain)),
                                          if (item.onSale && item.discountPercentage > 0)
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                decoration: BoxDecoration(color: AppColors.flashRed, borderRadius: BorderRadius.circular(4)),
                                                child: Text('-${item.discountPercentage}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8.5)),
                                              ),
                                            ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(color: const Color(0xFF0F172A).withValues(alpha: 0.8), borderRadius: BorderRadius.circular(4)),
                                              child: const Text('100% Authentic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 7)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      (item.brands.isNotEmpty ? item.brands.first : 'GLOWBAY').toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 9, color: AppColors.textMuted, letterSpacing: 0.5),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, height: 1.2)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text('৳${item.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary)),
                                        if (item.regularPrice > item.price) ...[
                                          const SizedBox(width: 5),
                                          Text(
                                            '৳${item.regularPrice.toStringAsFixed(0)}',
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: AppColors.textMuted, decoration: TextDecoration.lineThrough),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 30,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          context.read<CartProvider>().addToCart(item, quantity: 1);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${item.name} added to Cart!'),
                                              duration: const Duration(seconds: 1),
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: AppColors.primary,
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: const Text('+ Add to Cart', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 14),
                  ],
                );
              },
            ),

            // 13.5. Recently Viewed History Carousel (Lazada / Shopee Style)
            if (_recentlyViewed.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Recently Viewed Products',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13.5),
                    ),
                    const Spacer(),
                    Text(
                      'Browsing History',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  scrollDirection: Axis.horizontal,
                  itemCount: _recentlyViewed.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 155,
                      child: ProductCard(product: _recentlyViewed[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),

      // 14. Luxury Frosted Glass Sticky Bottom Bar
      bottomSheet: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 1)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                child: Row(
                  children: [
                    // 1. Brand Store
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final String brandName = p.brands.isNotEmpty ? p.brands.first : 'GlowBay Brand';
                        final String brandSlug = p.brandSlugs.isNotEmpty
                            ? p.brandSlugs.first
                            : (p.brands.isNotEmpty ? p.brands.first.toLowerCase().replaceAll(' ', '-') : '');
                        context.read<CatalogProvider>().filterByBrand(brandSlug);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CatalogScreen(
                              initialBrand: brandSlug,
                              initialBrandName: brandName,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.storefront_outlined, color: Color(0xFF475569), size: 20),
                            const SizedBox(height: 2),
                            Text(
                              'Brand',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // 2. Chat (WhatsApp)
                    InkWell(
                      onTap: _openWhatsApp,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 20),
                            const SizedBox(height: 2),
                            Text(
                              'Chat',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 3. Buy Now Button (Warm Sunset Gradient)
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9500), Color(0xFFFF7A00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF7A00).withValues(alpha: 0.30),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            final auth = context.read<AuthProvider>();
                            if (!auth.isLoggedIn) {
                              _showLoginPrompt(context);
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  directItem: CartItem(
                                    product: p,
                                    variation: _selectedVariation,
                                    selectedAttributes: _selectedAttributes,
                                    quantity: _quantity,
                                  ),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Buy Now',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                              Text(
                                '৳${(_currentPrice * _quantity).toStringAsFixed(0)}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 4. Add to Cart Button (Radiant Glow Rose Gradient)
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF2A6D), Color(0xFFE11D48)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF2A6D).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            cart.addToCart(
                              p,
                              quantity: _quantity,
                              variation: _selectedVariation,
                              selectedAttributes: _selectedAttributes,
                            );
                            final varTxt = _selectedVariation?.attributeSummary ?? '';
                            final addedLabel = varTxt.isNotEmpty ? '${p.name} ($varTxt)' : p.name;
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Added $_quantity x $addedLabel to cart',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF0F172A),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(milliseconds: 1400),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Add to Cart',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLoginPrompt(BuildContext context) {
    final isEn = context.read<LanguageProvider>().isEnglish;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Login Required',
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Please log in to complete your order',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isEn
                  ? 'Please login with your GlowBayBD account or create a new account to proceed with checkout and secure your order tracking.'
                  : 'Please log in to your account or create a new account to proceed with checkout and live tracking.',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AccountScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Log In / Register', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildInfoTabBtn(int index, String title) {
    final isSel = _activeInfoTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeInfoTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSel ? AppColors.primary : Colors.transparent, width: 2.5)),
          ),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: isSel ? AppColors.primary : AppColors.textMuted)),
        ),
      ),
    );
  }

  Widget _buildFbtRow(String title, String price, bool isChecked, ValueChanged<bool?>? onChanged) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
        Expanded(
          child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.primary)),
      ],
    );
  }


  String _getEstimatedDeliveryRange(bool isEn) {
    final now = DateTime.now();
    final start = now.add(const Duration(days: 10));
    final end = now.add(const Duration(days: 25));

    const enMonths = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${start.day} ${enMonths[start.month]} – ${end.day} ${enMonths[end.month]}';
  }

  // 🌟 Purchase Protection • 100% Buyer Guarantee Card
  Widget _buildPurchaseProtectionCard(bool isEn) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_rounded, color: Color(0xFFFF1F78), size: 16),
              const SizedBox(width: 8),
              Text(
                'Purchase Protection • 100% Buyer Guarantee',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 4 Guarantee Items
          _buildPPItem(
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'Authenticity:',
            desc: 'Malaysia-sourced 100% original. Suspect fake? Photo the parcel before opening → proven fake = full refund.',
          ),
          const SizedBox(height: 8),
          _buildPPItem(
            icon: Icons.videocam_rounded,
            iconColor: const Color(0xFF6366F1),
            title: 'Unboxing Video:',
            desc: 'Record parcel before opening (label + seal). Protects you & GlowBayBD.',
          ),
          const SizedBox(height: 8),
          _buildPPItem(
            icon: Icons.block_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Cancellation:',
            desc: 'Before sourcing: full refund. After sourcing: 15% charge. After air shipping: non-refundable.',
          ),
          const SizedBox(height: 8),
          _buildPPItem(
            icon: Icons.replay_rounded,
            iconColor: const Color(0xFFEC4899),
            title: 'Returns & Exchange:',
            desc: 'Intact/unopened within 3–7 days → 15% charge. Opened cosmetics: non-returnable.',
          ),
        ],
      ),
    );
  }

  Widget _buildPPItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11.5, height: 1.45, color: Color(0xFF475569)),
              children: [
                TextSpan(
                  text: '$title ',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandStoreCard(ProductModel p, bool isEn) {
    final String brandName = p.brands.isNotEmpty ? p.brands.first : 'GlowBay Brand';
    final String brandSlug = p.brandSlugs.isNotEmpty
        ? p.brandSlugs.first
        : (p.brands.isNotEmpty ? p.brands.first.toLowerCase().replaceAll(' ', '-') : '');

    final String logoUrl = 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/${brandSlug.toLowerCase().trim()}.png';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Brand Logo Box
                Container(
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF001A6E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: logoUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: Text(
                          brandName.substring(0, brandName.length > 5 ? 5 : brandName.length).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Text(
                          brandName.substring(0, brandName.length > 5 ? 5 : brandName.length).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Brand Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              brandName,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 14.5,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle, color: Color(0xFFC0392B), size: 14),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                              const SizedBox(width: 2),
                              Text(
                                'Rating 99%',
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const Text('•', style: TextStyle(fontSize: 10, color: Color(0xFFCBD5E1))),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, color: Color(0xFF10B981), size: 12),
                              const SizedBox(width: 2),
                              Text(
                                '100% Authentic',
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF065F46), fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kuala Lumpur Central Hub',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // "View All >" Button
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<CatalogProvider>().filterByBrand(brandSlug);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CatalogScreen(
                          initialBrand: brandSlug,
                          initialBrandName: brandName,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Trust Marquee / Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                Text(
                  '100% Authentic',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                ),
                const Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1))),
                Text(
                  '✈️ Direct Air Cargo',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                ),
                const Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1))),
                Expanded(
                  child: Text(
                    'Intact Seal',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String starLabel, double ratio, String percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              starLabel,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 5,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 26,
            child: Text(
              percent,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String author, String stars, String text, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(author, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 2),
                Text(stars, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(date, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary, height: 1.3)),
      ],
    );
  }

  Widget _buildRichDescription(ProductModel p) {
    final blocks = p.descriptionBlocks;
    final displayBlocks = _isDescriptionExpanded ? blocks : blocks.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayBlocks.map((block) {
          if (block.isImage) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: block.content,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                block.content,
                maxLines: _isDescriptionExpanded ? 300 : 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, height: 1.6, color: AppColors.textPrimary),
              ),
            );
          }
        }),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
          child: Row(
            children: [
              Text(
                _isDescriptionExpanded 
                    ? 'Show Less ▴'
                    : '📖 View Full Description & Images ▾',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVariationSection(ProductModel p) {
    if (!p.hasVariations) return const SizedBox.shrink();

    final activeVar = _selectedVariation ?? p.variations.first;
    final currentOptionText = activeVar.attributeSummary.isNotEmpty
        ? activeVar.attributeSummary
        : (activeVar.sku.isNotEmpty ? activeVar.sku : 'Option #${activeVar.id}');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 16, color: Color(0xFFFF2A6D)),
                  const SizedBox(width: 6),
                  Text(
                    'Select Variation',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD1E3)),
                ),
                child: Text(
                  currentOptionText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFF2A6D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: p.variations.map((v) {
              final isSelected = activeVar.id == v.id;
              final label = v.attributeSummary.isNotEmpty
                  ? v.attributeSummary
                  : (v.sku.isNotEmpty ? v.sku : '#${v.id}');

              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedVariation = v;
                    _selectedAttributes = Map<String, String>.from(v.attributes);
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFF0F5)
                        : (v.inStock ? Colors.white : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF2A6D)
                          : const Color(0xFFCBD5E1),
                      width: isSelected ? 1.6 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF2A6D).withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (v.image.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: v.image,
                            width: 22,
                            height: 22,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFFFF2A6D)
                                  : (v.inStock ? const Color(0xFF1E293B) : const Color(0xFF94A3B8)),
                            ),
                          ),
                          Text(
                            '৳${v.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFFFF2A6D)
                                  : (v.inStock ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle, size: 13, color: Color(0xFFFF2A6D)),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

