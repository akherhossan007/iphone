import re

with open('lib/presentation/screens/home/home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Check if 3-Step Secure Pre-Order Banner already exists
preorder_banner_code = """
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
"""

target_after_8channel = """                              onTap: () => _launchWhatsApp(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),"""

if target_after_8channel in content and "100% SECURE PRE-ORDER" not in content:
    content = content.replace(target_after_8channel, target_after_8channel + "\n" + preorder_banner_code)
    print("Added 100% SECURE PRE-ORDER Banner")
else:
    print("Could not find target_after_8channel or already present")

# 2. Add Trending Now and Weekly Deals after Top Brands Hub
trending_and_deals_code = """
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
"""

target_after_brands = """                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),"""

if target_after_brands in content and "Trending Now" not in content:
    content = content.replace(target_after_brands, target_after_brands + "\n" + trending_and_deals_code, 1)
    print("Added Trending Now and Weekly Deals")
else:
    print("Could not find target_after_brands or already present")

# 3. Add Mid Sourcing Studio Showcase Card (Mobile Web Section 16)
sourcing_studio_code = """
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
"""

target_after_category_grid = """                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _verifiedCategories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.86,
                        ),
                        itemBuilder: (context, index) {
                          final cat = _verifiedCategories[index];
                          return InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context.read<CatalogProvider>().filterByCategory(cat['slug']!);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/images/categories/${cat['slug']}.png',
                                      width: 46,
                                      height: 46,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 46,
                                        height: 46,
                                        color: const Color(0xFFF8FAFC),
                                        child: const Icon(Icons.category_outlined, color: AppColors.primary, size: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      cat['name']!,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
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
              ),"""

if target_after_category_grid in content and "100% AUTHENTIC SOURCING" not in content:
    content = content.replace(target_after_category_grid, target_after_category_grid + "\n" + sourcing_studio_code, 1)
    print("Added Mid Sourcing Studio Card")
else:
    print("Could not find target_after_category_grid or already present")

# 4. Add Instagram Community Showcase & Beauty Tips & FAQ Accordion
extra_bottom_sections = """
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
                              onTap: () => LauncherHelper.launchUrlSafe('https://instagram.com/glowbaybd'),
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
                              LauncherHelper.launchUrlSafe('https://instagram.com/glowbaybd');
                            }),
                            const SizedBox(width: 8),
                            _buildInstagramPhotoCard(null, 'Fresh KL Stock', () {
                              LauncherHelper.launchUrlSafe('https://instagram.com/glowbaybd');
                            }),
                            const SizedBox(width: 8),
                            _buildInstagramPhotoCard(null, 'Glow Community', () {
                              LauncherHelper.launchUrlSafe('https://instagram.com/glowbaybd');
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
"""

target_before_payments = """              // 14. Payment Methods & Security Strip"""

if target_before_payments in content and "Frequently Asked Questions" not in content:
    content = content.replace(target_before_payments, extra_bottom_sections + "\n" + target_before_payments, 1)
    print("Added Instagram, Beauty Tips, and FAQ Accordion")
else:
    print("Could not find target_before_payments or already present")

# 5. Add helper methods at the end of the class
helper_methods = """
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
"""

last_closing_brace = content.rfind("}")
if last_closing_brace != -1:
    content = content[:last_closing_brace] + helper_methods + "\n}\n"
    print("Added helper methods")

with open('lib/presentation/screens/home/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Saved updated home_screen.dart")
