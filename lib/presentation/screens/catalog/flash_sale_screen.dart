import '../../../logic/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_service.dart';
import '../../../logic/cart_provider.dart';
import '../../../logic/home_provider.dart';
import '../../widgets/countdown_timer_widget.dart';
import '../../widgets/product_card.dart';
import '../cart/cart_screen.dart';
import 'catalog_screen.dart';

class FlashSaleScreen extends StatefulWidget {
  const FlashSaleScreen({super.key});

  @override
  State<FlashSaleScreen> createState() => _FlashSaleScreenState();
}

class _FlashSaleScreenState extends State<FlashSaleScreen> {
  final ApiService _apiService = ApiService();
  List<ProductModel> _flashProducts = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Skincare',
    'Hair Care',
    'Body & Bath',
    'Serums',
  ];

  @override
  void initState() {
    super.initState();
    _loadFlashDeals();
  }

  Future<void> _loadFlashDeals() async {
    setState(() => _isLoading = true);
    try {
      final products = await _apiService.getFlashSale();
      if (mounted) {
        setState(() {
          _flashProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _flashProducts = [];
          _isLoading = false;
        });
      }
    }
  }

  List<ProductModel> get _filteredProducts {
    if (_selectedCategory == 'All') return _flashProducts;
    return _flashProducts.where((p) {
      final name = p.name.toLowerCase();
      final cat = _selectedCategory.toLowerCase();
      if (cat == 'skincare') {
        return name.contains('cream') || name.contains('serum') || name.contains('cleanser') || name.contains('lotion');
      } else if (cat == 'hair care') {
        return name.contains('hair') || name.contains('shampoo') || name.contains('conditioner') || name.contains('oil');
      } else if (cat == 'serums') {
        return name.contains('serum') || name.contains('essence') || name.contains('ampoule');
      } else if (cat == 'body & bath') {
        return name.contains('body') || name.contains('wash') || name.contains('lotion');
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.watch<LanguageProvider>().isEnglish;
    final homeProvider = context.watch<HomeProvider>();
    final cartProvider = context.watch<CartProvider>();
    final endTime = homeProvider.flashSaleEndTime;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 18),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          children: [
            const Icon(Icons.bolt, color: Color(0xFFFF1F78), size: 22),
            const SizedBox(width: 6),
            Text(
              'GlowBay Flash Deals',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ],
        ),
        actions: [
          if (Navigator.canPop(context))
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Color(0xFF0F172A), size: 22),
              tooltip: isEn ? 'Home' : 'হোম পেজ',
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF1F78),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF1F78)))
          : RefreshIndicator(
              onRefresh: _loadFlashDeals,
              color: const Color(0xFFFF1F78),
              child: _flashProducts.isEmpty
                  ? _buildStandbyView(context)
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. FLASH SALE HERO BANNER
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0B1933), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B1933).withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFFF1F78), Color(0xFFFF7A00)]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'LIMITED TIME EVENT',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Text(
                                  'ENDS IN: ',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                                CountdownTimerWidget(endTimestamp: endTime),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Mega Multi-Brand Flash Sale',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Flat discounts on 100% authentic Malaysian beauty & skincare.',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. CATEGORY FILTER CHIPS
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFF1F78) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFFF1F78) : const Color(0xFFE2E8F0),
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: const Color(0xFFFF1F78).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.plusJakartaSans(
                                color: isSelected ? Colors.white : const Color(0xFF475569),
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. RESPONSIVE PRODUCT GRID
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(color: Color(0xFFFF1F78)),
                            ),
                          )
                        : _filteredProducts.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.flash_off, size: 48, color: Color(0xFFCBD5E1)),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No flash deals in this category',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  int crossAxisCount = 2;
                                  double childAspectRatio = 0.63;

                                  if (constraints.maxWidth >= 900) {
                                    crossAxisCount = 4;
                                    childAspectRatio = 0.72;
                                  } else if (constraints.maxWidth >= 600) {
                                    crossAxisCount = 3;
                                    childAspectRatio = 0.68;
                                  }

                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: childAspectRatio,
                                    ),
                                    itemCount: _filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = _filteredProducts[index];
                                      return ProductCard(
                                        product: product,
                                        isFlashSale: true,
                                      );
                                    },
                                  );
                                },
                              ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandbyView(BuildContext context) {
    final isEn = context.watch<LanguageProvider>().isEnglish;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF2A6D).withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.bolt_outlined, color: Color(0xFFFF2A6D), size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              isEn ? 'No Active Flash Deals Right Now' : 'বর্তমানে কোনো ফ্ল্যাশ ডিল চালু নেই',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEn ? 'Our next flash deal campaign is starting soon! Check our full catalog to explore authentic skincare products.' : 'আমাদের পরবর্তী ফ্ল্যাশ সেল ক্যাম্পেইন শীঘ্রই শুরু হবে! স্পেশাল ডিসকাউন্ট ও আন্তর্জাতিক অথেনটিক পণ্য দেখতে আমাদের নিয়মিত ক্যাটালগ এক্সপ্লোর করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CatalogScreen()),
                );
              },
              icon: const Icon(Icons.storefront_outlined, size: 18),
              label: Text(isEn ? 'Browse All Products' : 'সকল পণ্য দেখুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
