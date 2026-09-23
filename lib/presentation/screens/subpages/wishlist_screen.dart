import '../../../logic/language_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/cart_provider.dart';
import '../../../logic/wishlist_provider.dart';
import '../catalog/catalog_screen.dart';
import '../product_detail/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final cart = context.read<CartProvider>();
    final isEn = context.watch<LanguageProvider>().isEnglish;
    final items = wishlist.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          isEn ? 'My Wishlist (${items.length})' : 'পছন্দের তালিকা (${items.length})',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16.5,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
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
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(isEn ? 'Clear Wishlist?' : 'তালিকা খালি করতে চান?'),
                    content: Text(isEn ? 'Are you sure you want to remove all items from your wishlist?' : 'পছন্দের তালিকা থেকে সব পণ্য মুছে ফেলতে চান?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(isEn ? 'No' : 'না'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          for (var item in List.from(items)) {
                            wishlist.toggleFavorite(item);
                          }
                        },
                        child: Text(isEn ? 'Yes, Clear' : 'হ্যাঁ, মুছে ফেলুন', style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                isEn ? 'Clear All' : 'সব মুছুন',
                style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyState(context, isEn)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = items[index];
                return _buildWishlistItem(context, product, wishlist, cart, isEn);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isEn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.favorite_rounded, color: Color(0xFFE11D48), size: 44),
            ),
            const SizedBox(height: 20),
            Text(
              isEn ? 'Your Wishlist is Empty!' : 'পছন্দের তালিকা ফাঁকা!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEn ? 'Tap the ❤️ icon on products to save them here for easy shopping later.' : 'আপনার পছন্দের পণ্যগুলোর ❤️ আইকনে ট্যাপ করে এখানে সেভ করে রাখুন, যাতে পরবর্তীতে সহজেই কিনতে পারেন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.45,
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
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: Text(isEn ? 'Start Shopping' : 'শপিং শুরু করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistItem(
    BuildContext context,
    ProductModel product,
    WishlistProvider wishlist,
    CartProvider cart,
    bool isEn,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: product.image,
                width: 78,
                height: 78,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: const Color(0xFFF1F5F9)),
                errorWidget: (context, url, error) => Container(
                  width: 78,
                  height: 78,
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brands.isNotEmpty)
                    Text(
                      product.brands.first.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                        letterSpacing: 0.4,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '৳${product.price.toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      if (product.onSale && product.regularPrice > product.price) ...[
                        const SizedBox(width: 6),
                        Text(
                          '৳${product.regularPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_rounded, color: Color(0xFFE11D48), size: 22),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    wishlist.toggleFavorite(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEn ? 'Removed from wishlist' : 'পছন্দের তালিকা থেকে সরানো হয়েছে'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    cart.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEn ? '${product.name} added to cart!' : '${product.name} কার্টে যোগ হয়েছে!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(0, 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(isEn ? 'Add to Cart' : 'কার্টে নিন', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
