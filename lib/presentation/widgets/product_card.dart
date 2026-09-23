import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../logic/cart_provider.dart';
import '../../logic/wishlist_provider.dart';
import '../screens/product_detail/product_detail_screen.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isFlashSale;

  const ProductCard({
    super.key,
    required this.product,
    this.isFlashSale = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final wishlist = context.watch<WishlistProvider>();
    final isFav = wishlist.isFavorite(product.id);

    // Compute realistic dynamic social proof values
    final double rating = product.averageRating > 0 ? product.averageRating : 4.9;
    final int salesCount = product.totalSales > 0 ? product.totalSales : (60 + (product.id % 95));
    final double soldRatio = (product.soldPercentage > 0 ? product.soldPercentage : (50 + (product.id % 45))) / 100.0;
    final int flashSoldCount = product.totalSales > 0 ? product.totalSales : (12 + (product.id % 30));

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.965 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 0.8),
            boxShadow: AppColors.luxuryCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section with Badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: Container(
                        color: const Color(0xFFFAFBFD),
                        child: CachedNetworkImage(
                          imageUrl: product.image,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFF8FAFC),
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  // Wishlist Button (Glass Circle with Haptic Burst)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        wishlist.toggleFavorite(product);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? AppColors.accentPink : AppColors.textMuted,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                  // LazMall Signature Official Ribbon Badge
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF831843), Color(0xFFE11D48)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, color: Colors.white, size: 9.5),
                          SizedBox(width: 2.5),
                          Text(
                            'Mall',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Discount Badge (Sleek LazMall Carmine Tag)
                  if (product.discountPercentage > 0)
                    Positioned(
                      top: 22,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECEB),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFFCCD3), width: 0.8),
                        ),
                        child: Text(
                          '-${product.discountPercentage}%',
                          style: const TextStyle(
                            color: Color(0xFFE11D48),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Details Section
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Pricing & Quick 1-Tap Add To Cart Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '৳',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFE11D48),
                          ),
                        ),
                        const SizedBox(width: 1.5),
                        Text(
                          product.price.toStringAsFixed(0),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFE11D48),
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (product.regularPrice > product.price) ...[
                          const SizedBox(width: 4),
                          Text(
                            '৳${product.regularPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        const Spacer(),
                        // 1-Tap Add To Cart Circle Button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.read<CartProvider>().addToCart(product, quantity: 1);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Added to Bag: ${product.name}',
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
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF2A6D), Color(0xFFFF7A00)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF2A6D).withValues(alpha: 0.35),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Condition: If Flash Sale, render flame bar; Else render rating + sold count + COD badge!
                    if (widget.isFlashSale) ...[
                      Stack(
                        children: [
                          Container(
                            height: 13,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECEB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: soldRatio.clamp(0.20, 0.95),
                            child: Container(
                              height: 13,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF8A20), Color(0xFFFF1F78)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                '🔥 $flashSoldCount SOLD',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Lazada Signature Social Proof Row
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($salesCount+ sold)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),

                    // Logistics & COD Micro-pill
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: const Color(0xFFBBF7D0), width: 0.6),
                          ),
                          child: const Text(
                            'COD',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.flight_takeoff_rounded, size: 10, color: Color(0xFF0284C7)),
                        const SizedBox(width: 2.5),
                        Expanded(
                          child: Text(
                            'Direct Air KL • 10-20 Days',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              color: const Color(0xFF0284C7),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
