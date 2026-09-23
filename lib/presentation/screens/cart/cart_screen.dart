import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/cart_provider.dart';
import '../../../logic/language_provider.dart';
import '../account/account_screen.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final lang = context.watch<LanguageProvider>();
    final isEn = lang.isEnglish;
    final allSelected = cart.items.isNotEmpty && cart.items.every((i) => i.isSelected);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP HEADER (.gbm-cart-header matching mobile web)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: const Color(0xFFF8FAFC),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context)) ...[
                        GestureDetector(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFEDF2F7)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF101936)),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        'My Cart',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF101936),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${cart.totalItemCount} Items',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF2374),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. BODY CONTENT
            Expanded(
              child: cart.items.isEmpty
                  ? _buildEmptyState(context)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
                      children: [
                        // Free Shipping Progress Bar (.gbm-fs-card: hidden when inactive, active when campaign live)
                        if (cart.isFreeShippingActive)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: cart.hasUnlockedFreeShipping ? const Color(0xFF86EFAC) : const Color(0xFFFFD1E3)),
                              boxShadow: [
                                BoxShadow(
                                  color: (cart.hasUnlockedFreeShipping ? const Color(0xFF10B981) : const Color(0xFFFF2374)).withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          cart.hasUnlockedFreeShipping ? Icons.celebration_rounded : Icons.local_shipping_rounded,
                                          size: 16,
                                          color: cart.hasUnlockedFreeShipping ? const Color(0xFF10B981) : const Color(0xFFFF2374),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          cart.hasUnlockedFreeShipping
                                              ? '🎉 Congratulations! You unlocked Free Delivery'
                                              : (isEn
                                                  ? 'Add ৳${(cart.freeShippingThreshold - cart.subtotal).toInt()} more for Free Delivery'
                                                  : 'Add ৳${(cart.freeShippingThreshold - cart.subtotal).toInt()} more for Free Delivery'),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: cart.hasUnlockedFreeShipping ? const Color(0xFF047857) : const Color(0xFF101936),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: cart.hasUnlockedFreeShipping ? const Color(0xFFECFDF5) : const Color(0xFFFFF0F5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${(cart.freeShippingProgress * 100).toInt()}%',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: cart.hasUnlockedFreeShipping ? const Color(0xFF10B981) : const Color(0xFFFF2374),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: cart.freeShippingProgress,
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFFEEF2F6),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      cart.hasUnlockedFreeShipping ? const Color(0xFF10B981) : const Color(0xFFFF2374),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Select All Bar
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEDF2F7)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Checkbox(
                                      value: allSelected,
                                      activeColor: const Color(0xFFFF2374),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      onChanged: (val) => cart.toggleSelectAll(val ?? false),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Select All (${cart.items.length})',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF101936),
                                    ),
                                  ),
                                ],
                              ),
                              if (cart.selectedCount > 0)
                                GestureDetector(
                                  onTap: () {
                                    for (var item in List.from(cart.items)) {
                                      if (item.isSelected) {
                                        cart.removeItem(item.product.id);
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Delete Selected',
                                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11.5, fontWeight: FontWeight.w800),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Cart Items (.gbm-cart-items-list)
                        ...cart.items.map((item) => _buildCartItem(context, cart, item)),

                        const SizedBox(height: 14),

                        // Trust Grid (.gbm-trust-grid matching mobile web)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFEDF2F7)),
                                ),
                                child: Column(
                                  children: [
                                    const Text('✨', style: TextStyle(fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '100% Authentic',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936)),
                                    ),
                                    Text(
                                      'Directly imported from Malaysia',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFEDF2F7)),
                                ),
                                child: Column(
                                  children: [
                                    const Text('✈️', style: TextStyle(fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '10–25 Days',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936)),
                                    ),
                                    Text(
                                      'Pre-order direct home delivery',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Order Summary Card (.gbm-summary-card matching mobile web)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEDF2F7)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF101936).withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Summary',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF101936),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Subtotal (${cart.selectedCount} Items)', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  Text(
                                    '৳${cart.subtotal.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF101936)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Estimated Shipping', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  Text(
                                    isEn
                                        ? '৳80 (Dhaka) / ৳150 (Outside)${cart.totalWeightKg > 1 ? ' • ${cart.totalWeightKg.toStringAsFixed(1)} kg' : ''}'
                                        : '৳80 (Dhaka) / ৳150 (Outside)${cart.totalWeightKg > 1 ? ' • ${cart.totalWeightKg.toStringAsFixed(1)} kg' : ''}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF101936)),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(height: 1, color: Color(0xFFEDF2F7)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Estimated Total',
                                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF101936)),
                                  ),
                                  Text(
                                    '৳${cart.total.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFFF2374)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),

      // 3. STICKY BOTTOM ACTION BAR (.gbm-sticky-bar matching mobile web)
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: Color(0xFFEDF2F7))),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF101936).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Total',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                        Text(
                          '৳${cart.total.toStringAsFixed(0)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFF2374),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A20), Color(0xFFFF5B4D), Color(0xFFFF2374)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2374).withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: cart.selectedCount == 0
                          ? null
                          : () {
                              HapticFeedback.heavyImpact();
                              final auth = context.read<AuthProvider>();
                              if (!auth.isLoggedIn) {
                                _showLoginPrompt(context);
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'CHECKOUT (${cart.selectedCount}) →',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Cart Item Card (.gbm-cart-item matching mobile web)
  Widget _buildCartItem(BuildContext context, CartProvider cart, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101936).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select Checkbox
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: item.isSelected,
              activeColor: const Color(0xFFFF2374),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (_) => cart.toggleItemSelection(item.product.id, item.variation?.id),
            ),
          ),
          const SizedBox(width: 8),

          // Thumbnail (.gbm-ci-thumb: 72x72 square)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: CachedNetworkImage(
                imageUrl: item.displayImage,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_outlined, size: 24, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details (.gbm-ci-details)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF101936),
                          height: 1.3,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => cart.removeFromCart(item.product.id, item.variation?.id),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.delete_outline, size: 17, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
                if (item.variationText.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 3, bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      item.variationText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  item.product.brands.isNotEmpty ? item.product.brands.first : 'Authentic Malaysian Beauty',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),

                // Bottom row: Price & Quantity Box (.gbm-qty-box)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '৳${item.totalPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFF2374),
                          ),
                        ),
                        if (item.unitRegularPrice > item.unitPrice)
                          Text(
                            '৳${(item.unitRegularPrice * item.quantity).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                      ],
                    ),

                    // 28x28 Quantity Selector Box (.gbm-qty-box)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFBFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEDF2F7), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => cart.updateQuantity(item.product.id, item.quantity - 1, item.variation?.id),
                            child: Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              child: const Icon(Icons.remove, size: 12, color: Color(0xFF101936)),
                            ),
                          ),
                          Container(
                            width: 28,
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF101936)),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => cart.updateQuantity(item.product.id, item.quantity + 1, item.variation?.id),
                            child: Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              child: const Icon(Icons.add, size: 12, color: Color(0xFF101936)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Empty State (.gbm-cart-empty-card matching mobile web)
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDF2F7)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF101936).withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_outlined, size: 32, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 18),
              Text(
                'Your Cart is Empty',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF101936),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover 100% authentic Malaysian beauty & skincare products directly imported to Bangladesh.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A20), Color(0xFFFF5B4D), Color(0xFFFF2374)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF2374).withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Continue Shopping', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      ],
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

  void _showLoginPrompt(BuildContext context) {
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
                    color: const Color(0xFFFF2374).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: Color(0xFFFF2374), size: 24),
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
                        'Please login to complete checkout',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Please login with your GlowBayBD account or create a new account to proceed with checkout and secure your order tracking.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
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
                      backgroundColor: const Color(0xFFFF2374),
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
}
