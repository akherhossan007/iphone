import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../data/models/brand_model.dart';
import '../../../logic/catalog_provider.dart';
import '../../../logic/language_provider.dart';
import 'catalog_screen.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  String _selectedLetter = 'ALL';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _letters = [
    'ALL', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalog = context.read<CatalogProvider>();
      if (catalog.brands.isEmpty) {
        catalog.loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _navigateToBrand(BrandModel brand) {
    HapticFeedback.lightImpact();
    context.read<CatalogProvider>().filterByBrand(brand.slug);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogScreen(
          initialBrand: brand.slug,
          initialBrandName: brand.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final isEn = context.watch<LanguageProvider>().isEnglish;
    final allBrands = catalog.brands;

    // Filter brands based on search and selected letter
    final query = _searchCtrl.text.trim().toLowerCase();
    final filteredBrands = allBrands.where((b) {
      final matchesQuery = query.isEmpty || b.name.toLowerCase().contains(query);
      final matchesLetter = _selectedLetter == 'ALL' ||
          (b.name.isNotEmpty && b.name[0].toUpperCase() == _selectedLetter);
      return matchesQuery && matchesLetter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF101936)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEn ? 'Official Brand Stores' : 'অফিশিয়াল ব্র্যান্ড স্টোর',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF101936),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Text(
              isEn ? '100% Authentic Malaysian Direct Sourced' : '১০০% অথেনটিক সরাসরি মালয়েশিয়া থেকে আমদানিকৃত',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (Navigator.canPop(context))
            IconButton(
              icon: const Icon(Icons.home_outlined, size: 22, color: Color(0xFF101936)),
              tooltip: isEn ? 'Home' : 'হোম পেজ',
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => catalog.loadInitialData(),
        color: const Color(0xFFED2165),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
          children: [
            // 1. Search Bar
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF0E2E9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: isEn ? 'Search brand (CeraVe, The Ordinary, COSRX...)' : 'ব্র্যান্ড খুঁজুন (CeraVe, The Ordinary, COSRX...)',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. Official Brand Hero Banner (.gb-brands-hero)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A00), Color(0xFFFF2374)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFED2165).withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '✨ DIRECT MALAYSIAN IMPORT',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 9.5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Verified Global Brands',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Every product is sourced straight from official brand partners in Kuala Lumpur.',
                          style: TextStyle(color: Colors.white, fontSize: 11, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Horizontal A-Z Letters Bar (.gb-az-nav-wrap)
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _letters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final letter = _letters[index];
                  final isSelected = _selectedLetter == letter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLetter = letter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFED2165) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFED2165) : const Color(0xFFF0E2E9),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFED2165).withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF1D1D1F),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // 4. Brands Grid / Results
            if (filteredBrands.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredBrands.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.7,
                ),
                itemBuilder: (context, index) {
                  final brand = filteredBrands[index];
                  return GestureDetector(
                    onTap: () => _navigateToBrand(brand),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF0E2E9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFF1F1F4)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/brands/${brand.slug}.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => CachedNetworkImage(
                                      imageUrl: brand.logoUrl,
                                      fit: BoxFit.contain,
                                      errorWidget: (context, url, error) => Center(
                                        child: Text(
                                          brand.name.isNotEmpty ? brand.name[0].toUpperCase() : 'B',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFED2165),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  brand.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: const Color(0xFF101936),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  brand.count > 0 ? '${brand.count} Items' : 'Explore ›',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFED2165)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ] else if (catalog.isLoadingInitial && allBrands.isEmpty) ...[
              // Loading State
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFED2165)),
                ),
              ),
            ] else ...[
              // Empty State
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 40, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 8),
                    Text(
                      isEn ? 'No brands found for "$_selectedLetter"' : '"$_selectedLetter" দিয়ে কোনো ব্র্যান্ড পাওয়া যায়নি',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF101936)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEn ? 'Try selecting another letter or clearing the search.' : 'অন্য অক্ষর বেছে নিন বা সার্চ ক্লিয়ার করুন।',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
