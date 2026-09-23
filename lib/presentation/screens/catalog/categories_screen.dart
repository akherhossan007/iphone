import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../data/models/category_model.dart';
import '../../../logic/catalog_provider.dart';
import '../../../logic/language_provider.dart';
import 'catalog_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalog = context.read<CatalogProvider>();
      if (catalog.categories.isEmpty) {
        catalog.loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _navigateToCategory(String slug, String name) {
    HapticFeedback.lightImpact();
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
  }

  IconData _getCategoryIcon(String slug) {
    final s = slug.toLowerCase();
    if (s.contains('skin') || s.contains('face')) return Icons.face_retouching_natural_rounded;
    if (s.contains('hair')) return Icons.content_cut_rounded;
    if (s.contains('bath') || s.contains('body') || s.contains('personal')) return Icons.bathtub_outlined;
    if (s.contains('makeup')) return Icons.auto_awesome_rounded;
    if (s.contains('baby')) return Icons.child_care_rounded;
    if (s.contains('health') || s.contains('supplement') || s.contains('vitamin')) return Icons.health_and_safety_outlined;
    if (s.contains('oral') || s.contains('tooth')) return Icons.sentiment_satisfied_alt_rounded;
    if (s.contains('hand') || s.contains('foot')) return Icons.clean_hands_outlined;
    return Icons.category_outlined;
  }

  List<Color> _getCategoryGradient(int index) {
    final palettes = [
      [const Color(0xFFFF2374), const Color(0xFFFF7A00)], // Sunset Pink/Orange
      [const Color(0xFF2563EB), const Color(0xFF06B6D4)], // Ocean Blue
      [const Color(0xFF7C3AED), const Color(0xFFA855F7)], // Royal Purple
      [const Color(0xFF059669), const Color(0xFF10B981)], // Emerald
      [const Color(0xFFD97706), const Color(0xFFFBBF24)], // Amber
      [const Color(0xFFDB2777), const Color(0xFFF472B6)], // Rose
      [const Color(0xFF0891B2), const Color(0xFF38BDF8)], // Cyan
      [const Color(0xFF4F46E5), const Color(0xFF818CF8)], // Indigo
    ];
    return palettes[index % palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final isEn = context.watch<LanguageProvider>().isEnglish;
    final categories = catalog.categories;

    // Filter categories and subcategories by query
    final query = _searchQuery.trim().toLowerCase();
    final List<CategoryModel> filteredCategories = [];

    for (final cat in categories) {
      if (query.isEmpty) {
        filteredCategories.add(cat);
      } else {
        final matchesParent = cat.name.toLowerCase().contains(query);
        final matchingSubs = cat.subcategories.where((sub) => sub.name.toLowerCase().contains(query)).toList();
        if (matchesParent || matchingSubs.isNotEmpty) {
          filteredCategories.add(
            CategoryModel(
              id: cat.id,
              name: cat.name,
              slug: cat.slug,
              count: cat.count,
              image: cat.image,
              icon: cat.icon,
              subcategories: matchingSubs.isNotEmpty ? matchingSubs : cat.subcategories,
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              )
            : null,
        title: Text(
          isEn ? 'All Categories' : 'সকল ক্যাটাগরি',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 22, color: Color(0xFF0F172A)),
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
        color: const Color(0xFFFF2374),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
          children: [
            // 1. Search Bar
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: isEn ? 'Search categories (Cleanser, Serum, Sunscreen...)' : 'ক্যাটাগরি খুঁজুন (Cleanser, Serum, Sunscreen...)',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Verified Sourcing Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: Color(0xFFE11D48), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '100% Authentic Malaysian & Global Direct Import',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFBE123C),
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Category Sections
            if (catalog.isLoadingInitial && categories.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: Color(0xFFFF2374)),
                ),
              )
            else if (filteredCategories.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 40, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 8),
                    Text(
                      'No categories found matching "$_searchQuery"',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              )
            else
              ...filteredCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final cat = entry.value;
                final gradient = _getCategoryGradient(index);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      // Parent Category Header Bar
                      InkWell(
                        onTap: () => _navigateToCategory(cat.slug, cat.name),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(_getCategoryIcon(cat.slug), color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat.name,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    if (cat.count > 0)
                                      Text(
                                        '${cat.count} Authentic Products',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('View All', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                                    SizedBox(width: 2),
                                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF334155)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Subcategories Chips/Grid (if any)
                      if (cat.subcategories.isNotEmpty) ...[
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: cat.subcategories.map((sub) {
                              return InkWell(
                                onTap: () => _navigateToCategory(sub.slug, sub.name),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        sub.name,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      if (sub.count > 0) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE2E8F0),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${sub.count}',
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
