import '../../../logic/language_provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_service.dart';
import '../../../logic/cart_provider.dart';
import '../../../logic/catalog_provider.dart';
import '../subpages/visual_search_screen.dart';
import '../../widgets/voice_search_modal.dart';
import '../product_detail/product_detail_screen.dart';
import 'catalog_screen.dart';

class SmartSearchDelegate extends SearchDelegate<void> {
  final bool? isEnglishOverride;

  SmartSearchDelegate({this.isEnglishOverride});

  bool _isEn(BuildContext context) => isEnglishOverride ?? context.read<LanguageProvider>().isEnglish;

  static const List<String> _trendingTerms = [
    'CeraVe',
    'Anua',
    'Sunscreen',
    'Retinol',
    'Niacinamide',
    'Centella',
    'Cetaphil',
    'Torriden',
  ];

  @override
  String get searchFieldLabel => (isEnglishOverride ?? true) ? 'Search authentic skincare, brands...' : 'অথেনটিক স্কিনকেয়ার বা ব্র্যান্ড খুঁজুন...';

  @override
  TextStyle? get searchFieldStyle => GoogleFonts.plusJakartaSans(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF0F172A),
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Color(0xFF0F172A), size: 22),
        titleTextStyle: TextStyle(color: Color(0xFF0F172A), fontSize: 15),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
      // 📷 Visual / Camera Search Button
      IconButton(
        icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFFE11D48), size: 22),
        tooltip: _isEn(context) ? 'Search by Photo' : 'ছবি দিয়ে বা তুলে সার্চ',
        onPressed: () {
          _openVisualSearch(context);
        },
      ),
      // 🎙️ Voice Search Button
      IconButton(
        icon: const Icon(Icons.mic_none_rounded, color: Color(0xFFE11D48), size: 23),
        tooltip: _isEn(context) ? 'Voice Search' : 'ভয়েস দিয়ে সার্চ',
        onPressed: () async {
          final spoken = await VoiceSearchModal.show(context);
          if (spoken != null && spoken.trim().isNotEmpty) {
            query = spoken.trim();
            if (context.mounted) {
              showResults(context);
            }
          }
        },
      ),
      const SizedBox(width: 4),
    ];
  }

  void _openVisualSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isEn(context) ? 'Visual Search (Search by Photo)' : 'ভিজ্যুয়াল সার্চ (ছবি দিয়ে খুঁজুন)',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFFEEF3), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFE11D48)),
                ),
                title: Text(_isEn(context) ? 'Take Photo with Camera' : 'ক্যামেরা দিয়ে ছবি তুলুন', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                subtitle: Text(_isEn(context) ? 'Snap bottle or packaging directly' : 'প্রোডাক্ট বা বোতলের ছবি সরাসরি তুলুন', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualSearchScreen(initialSource: ImageSource.camera)));
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF2563EB)),
                ),
                title: Text(_isEn(context) ? 'Upload Photo from Gallery' : 'গ্যালারি থেকে ছবি আপলোড করুন', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                subtitle: Text(_isEn(context) ? 'Choose product photo from your phone' : 'ফোন থেকে প্রোডাক্টের ছবি বাছাই করুন', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualSearchScreen(initialSource: ImageSource.gallery)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isNotEmpty) {
      _saveRecentSearch(query.trim());
    }
    return _SearchResultsView(query: query.trim(), onSelectTerm: (term) {
      query = term;
      showResults(context);
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return _ZeroStateSuggestions(
        trendingTerms: _trendingTerms,
        onSelectTerm: (term) {
          query = term;
          showResults(context);
        },
      );
    }
    return _SearchResultsView(query: query.trim(), onSelectTerm: (term) {
      query = term;
      showResults(context);
    });
  }

  Future<void> _saveRecentSearch(String term) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recent = prefs.getStringList('gb_app_recent_searches') ?? [];
      recent.removeWhere((item) => item.toLowerCase() == term.toLowerCase());
      recent.insert(0, term);
      if (recent.length > 10) recent = recent.sublist(0, 10);
      await prefs.setStringList('gb_app_recent_searches', recent);
    } catch (_) {}
  }
}

class _ZeroStateSuggestions extends StatefulWidget {
  final List<String> trendingTerms;
  final ValueChanged<String> onSelectTerm;

  const _ZeroStateSuggestions({
    required this.trendingTerms,
    required this.onSelectTerm,
  });

  @override
  State<_ZeroStateSuggestions> createState() => _ZeroStateSuggestionsState();
}

class _ZeroStateSuggestionsState extends State<_ZeroStateSuggestions> {
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _recent = prefs.getStringList('gb_app_recent_searches') ?? [];
      });
    } catch (_) {}
  }

  Future<void> _clearRecent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('gb_app_recent_searches');
      setState(() => _recent = []);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // Quick Voice & Visual Search Bar
        Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF1F2), Color(0xFFFEE2E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final spoken = await VoiceSearchModal.show(context);
                    if (spoken != null && spoken.trim().isNotEmpty) {
                      widget.onSelectTerm(spoken.trim());
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mic_rounded, color: Color(0xFFE11D48), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          (context.watch<LanguageProvider>().isEnglish) ? 'Voice Search' : 'ভয়েস সার্চ',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualSearchScreen()));
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          (context.watch<LanguageProvider>().isEnglish) ? 'Visual Search' : 'ছবি দিয়ে সার্চ',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_recent.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_rounded, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 6),
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _clearRecent,
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recent.map((term) {
              return ActionChip(
                backgroundColor: const Color(0xFFF1F5F9),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: -2),
                label: Text(
                  term,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                onPressed: () => widget.onSelectTerm(term),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
        ],
        const Row(
          children: [
            Icon(Icons.local_fire_department_rounded, size: 18, color: Color(0xFFFF7A00)),
            SizedBox(width: 6),
            Text(
              'Trending Authentic Skincare',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.trendingTerms.map((term) {
            return ActionChip(
              backgroundColor: const Color(0xFFFFF1F2),
              side: const BorderSide(color: Color(0xFFFECDD3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: -2),
              avatar: const Icon(Icons.search_rounded, size: 14, color: Color(0xFFE11D48)),
              label: Text(
                term,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFBE123C)),
              ),
              onPressed: () => widget.onSelectTerm(term),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '100% Genuine Guaranteed — Direct authorized counter import from Malaysia with 3X Money-Back Promise.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchResultsView extends StatefulWidget {
  final String query;
  final ValueChanged<String> onSelectTerm;

  const _SearchResultsView({
    required this.query,
    required this.onSelectTerm,
  });

  @override
  State<_SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<_SearchResultsView> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<dynamic> _brands = [];
  List<dynamic> _categories = [];
  List<dynamic> _products = [];
  String? _correctedTerm;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void didUpdateWidget(covariant _SearchResultsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    if (widget.query.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    final data = await _api.smartSearch(widget.query);
    if (mounted) {
      setState(() {
        _isLoading = false;
        _brands = data['brands'] as List? ?? [];
        _categories = data['categories'] as List? ?? [];
        _products = data['products'] as List? ?? [];
        _correctedTerm = data['corrected_term']?.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xFFFF2374)),
            ),
            SizedBox(height: 12),
            Text(
              'Searching authentic catalog...',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_brands.isEmpty && _categories.isEmpty && _products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
              const SizedBox(height: 12),
              Text(
                'No exact match for "${widget.query}"',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try searching for brand names like CeraVe, Cosrx, or categories like Cleanser.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () {
                  context.read<CatalogProvider>().setSearchQuery(widget.query);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                },
                icon: const Icon(Icons.explore_rounded, color: Colors.white, size: 16),
                label: const Text('Search in Full Catalog', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      children: [
        // Brand and Category match pills
        if (_brands.isNotEmpty || _categories.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._brands.map((b) {
                  final name = b['name']?.toString() ?? '';
                  final count = b['count'] != null ? ' (${b['count']})' : '';
                  final slug = b['slug']?.toString() ?? name.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: const Color(0xFFFFF7ED),
                      side: const BorderSide(color: Color(0xFFFED7AA)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      avatar: const Icon(Icons.verified_rounded, size: 14, color: Color(0xFFEA580C)),
                      label: Text(
                        '$name$count',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFC2410C)),
                      ),
                      onPressed: () {
                        final catalog = context.read<CatalogProvider>();
                        catalog.resetFilters();
                        catalog.setBrand(slug);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                      },
                    ),
                  );
                }),
                ..._categories.map((c) {
                  final name = c['name']?.toString() ?? '';
                  final slug = c['slug']?.toString() ?? name.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: const Color(0xFFF0FDF4),
                      side: const BorderSide(color: Color(0xFFBBF7D0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      avatar: const Icon(Icons.local_offer_rounded, size: 13, color: Color(0xFF16A34A)),
                      label: Text(
                        name,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                      ),
                      onPressed: () {
                        final catalog = context.read<CatalogProvider>();
                        catalog.resetFilters();
                        catalog.setCategory(slug);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        if (_correctedTerm != null && _correctedTerm!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFD97706)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Showing results for: "$_correctedTerm"',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),

        // Product list header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Products (${_products.length})',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            GestureDetector(
              onTap: () {
                context.read<CatalogProvider>().setSearchQuery(widget.query);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
              },
              child: const Row(
                children: [
                  Text(
                    'View All in Shop',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFFF2374)),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFFF2374)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Product items
        ..._products.map((p) {
          final id = p['id'] is int ? p['id'] as int : int.tryParse(p['id']?.toString() ?? '0') ?? 0;
          final title = p['title']?.toString() ?? p['name']?.toString() ?? 'GlowBay Product';
          final image = p['image']?.toString() ?? '';
          final price = p['price']?.toString() ?? '0';
          final inStock = p['in_stock'] == true || p['stock_status'] == 'instock';

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              if (id > 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: id)),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 54,
                      height: 54,
                      color: const Color(0xFFF8FAFC),
                      child: image.isNotEmpty
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_rounded, size: 20, color: Color(0xFFCBD5E1)),
                            )
                          : const Icon(Icons.shopping_bag_outlined, color: Color(0xFFCBD5E1)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), height: 1.25),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '৳$price',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFFF2374)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: inStock ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                inStock ? '🇲🇾 Ready Stock' : '✈️ Pre-Order',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: inStock ? const Color(0xFF166534) : const Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart_rounded, color: Color(0xFF0F172A), size: 20),
                    onPressed: () {
                      if (id > 0) {
                        final parsedPrice = double.tryParse(price) ?? 0.0;
                        final prod = ProductModel.fromJson({
                          'id': id,
                          'name': title,
                          'price': parsedPrice,
                          'regular_price': parsedPrice,
                          'image': image,
                          'in_stock': inStock,
                          'sku': p['sku']?.toString() ?? '',
                        });
                        context.read<CartProvider>().addToCart(prod);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added "$title" to Bag'),
                            duration: const Duration(milliseconds: 1400),
                            backgroundColor: const Color(0xFF0F172A),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
