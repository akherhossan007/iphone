import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/catalog_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shimmer_loader.dart';

class CatalogScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialCategoryName;
  final String? initialBrand;
  final String? initialBrandName;
  final String? initialSearch;

  const CatalogScreen({
    super.key,
    this.initialCategory,
    this.initialCategoryName,
    this.initialBrand,
    this.initialBrandName,
    this.initialSearch,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CatalogProvider>();
      provider.loadInitialData();

      if (widget.initialBrand != null) {
        provider.filterByBrand(widget.initialBrand);
      } else if (widget.initialCategory != null) {
        provider.filterByCategory(widget.initialCategory);
      } else if (widget.initialSearch != null) {
        provider.setSearchQuery(widget.initialSearch!);
      } else if (provider.products.isEmpty) {
        provider.fetchProducts();
      }

      if (provider.searchQuery.isNotEmpty) {
        _searchController.text = provider.searchQuery;
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<CatalogProvider>().fetchProducts(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<CatalogProvider>(
          builder: (context, catalog, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Products',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          catalog.resetFilters();
                          _searchController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset All', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        // Categories
                        Text(
                          'Category',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: catalog.categories.map((c) {
                            final isSel = catalog.selectedCategory == c.slug;
                            return ChoiceChip(
                              label: Text(c.name),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  catalog.filterByCategory(c.slug);
                                } else {
                                  catalog.setCategory(null);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Brands
                        Text(
                          'Brand',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: catalog.brands.map((b) {
                            final isSel = catalog.selectedBrand == b.slug;
                            return ChoiceChip(
                              label: Text(b.name),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  catalog.filterByBrand(b.slug);
                                } else {
                                  catalog.setBrand(null);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Price Range
                        Text(
                          'Price Range (৳)',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => catalog.setPriceRange(0, 1500),
                                child: const Text('Under ৳1,500', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => catalog.setPriceRange(1500, 3000),
                                child: const Text('৳1,500 - ৳3,000', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => catalog.setPriceRange(3000, 10000),
                                child: const Text('Above ৳3,000', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBrandOrCategoryHeader(CatalogProvider catalog) {
    final isBrand = catalog.selectedBrand != null;
    final isCategory = catalog.selectedCategory != null;
    if (!isBrand && !isCategory) return const SizedBox.shrink();

    final title = isBrand
        ? (catalog.selectedBrandName ?? widget.initialBrandName ?? catalog.selectedBrand!.toUpperCase())
        : (catalog.selectedCategoryName ?? widget.initialCategoryName ?? catalog.selectedCategory!);

    final subtitle = isBrand
        ? 'Official Brand Store • 100% Authentic Malaysian Direct Sourced'
        : 'Curated Authentic Skincare & Beauty Collection';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBrand
              ? [const Color(0xFFFFF1F2), const Color(0xFFFFE4E6)]
              : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: isBrand ? const Color(0xFFFECDD3) : const Color(0xFFBAE6FD),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isBrand ? const Color(0xFFE11D48) : const Color(0xFF0284C7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBrand ? Icons.verified_rounded : Icons.category_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Container(
          margin: const EdgeInsets.only(right: 8, left: 12),
          height: 40,
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (val) {
              FocusScope.of(context).unfocus();
              catalog.setSearchQuery(val.trim());
            },
            decoration: InputDecoration(
              hintText: 'Search authentic brands, serums, cleansers...',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              prefixIcon: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  catalog.setSearchQuery(_searchController.text.trim());
                },
                child: const Icon(Icons.search, size: 18, color: AppColors.primary),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                        catalog.setSearchQuery('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20, color: AppColors.primary),
            onPressed: () => _showFilterModal(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Dedicated Brand / Category Header (if active)
          _buildBrandOrCategoryHeader(catalog),

          // Active Filter Chips (if any)
          if (catalog.selectedBrand != null || catalog.selectedCategory != null || catalog.searchQuery.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (catalog.selectedBrand != null) ...[
                      Chip(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        label: Text(
                          'Brand: ${catalog.selectedBrandName ?? catalog.selectedBrand!}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
                        onDeleted: () => catalog.setBrand(null),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (catalog.selectedCategory != null) ...[
                      Chip(
                        backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.1),
                        label: Text(
                          'Category: ${catalog.selectedCategoryName ?? catalog.selectedCategory!}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF0284C7)),
                        onDeleted: () => catalog.setCategory(null),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (catalog.searchQuery.isNotEmpty) ...[
                      Chip(
                        backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                        label: Text('Query: "${catalog.searchQuery}"', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                        deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF7C3AED)),
                        onDeleted: () {
                          _searchController.clear();
                          catalog.setSearchQuery('');
                        },
                      ),
                      const SizedBox(width: 6),
                    ],
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        catalog.resetFilters();
                      },
                      child: const Text('Clear All', style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),

          // Sort Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${catalog.products.length} Products Found',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: catalog.orderBy,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('Newest Arrivals')),
                      DropdownMenuItem(value: 'popularity', child: Text('Best Sellers')),
                      DropdownMenuItem(value: 'rating', child: Text('Top Rated')),
                      DropdownMenuItem(value: 'price', child: Text('Price: Low to High')),
                      DropdownMenuItem(value: 'price-desc', child: Text('Price: High to Low')),
                    ],
                    onChanged: (val) {
                      if (val != null) catalog.setSort(val);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Products Grid View
          Expanded(
            child: catalog.isLoading && catalog.products.isEmpty
                ? const ShimmerGridLoader(itemCount: 8)
                : catalog.products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'No products found matching your filter.',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                catalog.resetFilters();
                              },
                              child: const Text('Reset All Filters'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => catalog.fetchProducts(),
                        color: AppColors.primary,
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.59,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: catalog.products.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                              product: catalog.products[index],
                              isFlashSale: false,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
