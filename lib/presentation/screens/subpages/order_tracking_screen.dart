import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/order_model.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/order_provider.dart';
import '../../../logic/language_provider.dart';
import '../account/account_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? initialOrderId;
  final String? initialFunnel;
  const OrderTrackingScreen({super.key, this.initialOrderId, this.initialFunnel});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with SingleTickerProviderStateMixin {
  String? _selectedOrderId;
  String _selectedFunnel = 'all';
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Cached fallback telemetry to prevent empty states during transient downtime
  static final Map<int, SteadfastTelemetry> _localCourierCache = {};

  @override
  void initState() {
    super.initState();
    _selectedOrderId = widget.initialOrderId;
    _selectedFunnel = widget.initialFunnel ?? 'all';

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTracking();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _syncCountdownTimer(OrderTrackingModel? tracking) {
    if (tracking == null) return;
    if (tracking.remainingPaymentSeconds > 0 && (_countdownTimer == null || !_countdownTimer!.isActive)) {
      _remainingSeconds = tracking.remainingPaymentSeconds;
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          if (mounted) {
            setState(() => _remainingSeconds--);
          }
        } else {
          timer.cancel();
        }
      });
    }
  }

  void _initTracking() {
    final orderProvider = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();

    if (auth.isLoggedIn && auth.dashboardData != null) {
      final allOrders = auth.dashboardData!.recentOrders;
      final matchingOrders = _filterOrdersByFunnel(allOrders, _selectedFunnel);

      if (_selectedOrderId != null && _selectedOrderId!.isNotEmpty) {
        final belongs = matchingOrders.any((o) => (o['id'] ?? o['order_id']).toString() == _selectedOrderId);
        if (belongs || _selectedFunnel == 'all') {
          orderProvider.trackOrder(_selectedOrderId!);
          return;
        }
      }

      if (matchingOrders.isNotEmpty) {
        final first = matchingOrders.first;
        final id = (first['id'] ?? first['order_id'] ?? '').toString();
        if (id.isNotEmpty) {
          setState(() => _selectedOrderId = id);
          orderProvider.trackOrder(id);
        }
      } else {
        setState(() => _selectedOrderId = null);
      }
    } else if (_selectedOrderId != null && _selectedOrderId!.isNotEmpty) {
      orderProvider.trackOrder(_selectedOrderId!);
    }
  }

  void _selectOrder(String id) {
    if (_selectedOrderId == id) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedOrderId = id);
    context.read<OrderProvider>().trackOrder(id);
  }

  Future<void> _launchWhatsAppSupport(String orderId) async {
    final message = Uri.encodeComponent('Hello GlowBayBD, I need an update on my pre-order #$orderId');
    final uri = Uri.parse('https://wa.me/8801948667001?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            const SizedBox(width: 8),
            Text('$label copied: $text', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: const Color(0xFF101936),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final isEn = lang.isEnglish;
    final tracking = orderProvider.trackingData;
    final recentOrders = auth.dashboardData?.recentOrders ?? [];
    final filteredOrders = _filterOrdersByFunnel(recentOrders, _selectedFunnel);

    // Cache valid courier telemetry for resilience, but remove if cancelled
    if (tracking != null && (tracking.isOrderCancelled || tracking.isOrderRefunded)) {
      _localCourierCache.remove(tracking.orderId);
    } else if (tracking != null && tracking.courierTelemetry != null) {
      _localCourierCache[tracking.orderId] = tracking.courierTelemetry!;
    }

    if (tracking != null) {
      _syncCountdownTimer(tracking);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Live Order Tracking',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: const Color(0xFF101936),
          ),
        ),
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF101936)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              )
            : null,
        actions: [
          if (auth.isLoggedIn && _selectedOrderId != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22, color: Color(0xFF101936)),
              tooltip: 'Refresh Tracking',
              onPressed: () {
                HapticFeedback.lightImpact();
                orderProvider.trackOrder(_selectedOrderId!);
              },
            ),
          if (Navigator.canPop(context))
            IconButton(
              icon: const Icon(Icons.home_outlined, size: 22, color: Color(0xFF101936)),
              tooltip: 'Home Page',
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
        ],
      ),
      body: !auth.isLoggedIn
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildNotLoggedInCard(isEn),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 1. 5-Funnel Master Tabs
                  _buildFunnelTabs(isEn),
                  const SizedBox(height: 12),

                  // 2. Multiple Active Orders Horizontal Selector (Strictly filtered by funnel)
                  if (filteredOrders.isNotEmpty) ...[
                    _buildOrderSelector(filteredOrders, isEn),
                    const SizedBox(height: 14),
                  ],

                  // 3. Loading State
                  if (orderProvider.isTrackingLoading) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(color: Color(0xFFFF2D78), strokeWidth: 3),
                          const SizedBox(height: 18),
                          Text(
                            'Loading live tracking data...',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (filteredOrders.isEmpty) ...[
                    // Empty funnel state: No orders in this specific tab
                    _buildEmptyOrdersCard(isEn),
                  ] else if (tracking != null && filteredOrders.any((o) => (o['id'] ?? o['order_id']).toString() == tracking.orderId.toString())) ...[
                    // Payment Under Review or Rejected Alert
                    _buildPaymentStatusBanner(tracking, isEn),

                    // 3-Hour Unpaid Deadline Timer
                    _buildPaymentDeadlineCard(tracking, isEn),
                    const SizedBox(height: 14),

                    if (tracking.isOrderCancelled || tracking.isOrderRefunded) ...[
                      // Cancelled / Refunded Order View
                      _buildCancelledOrderCard(tracking, lang),
                      const SizedBox(height: 14),
                      _buildConsignmentSummaryCard(tracking, isEn),
                      const SizedBox(height: 14),
                      _buildWhatsAppSupportCard(tracking, isEn),
                    ] else ...[
                      // Cross-Border Route Banner
                      _buildCrossBorderRouteBanner(tracking, isEn),
                      const SizedBox(height: 14),

                      // Order Consignment Summary Card (includes instant cancel & return buttons)
                      _buildConsignmentSummaryCard(tracking, isEn),
                      const SizedBox(height: 14),

                      // Embedded In-App Native Steadfast Courier Card
                      _buildEmbeddedSteadfastCourierCard(tracking, isEn),
                      const SizedBox(height: 14),

                      // Visual 5-Stage Cross-Border Progress Timeline
                      _buildFiveStageTimelineCard(tracking, isEn),
                      const SizedBox(height: 14),

                      // Direct WhatsApp VIP Support
                      _buildWhatsAppSupportCard(tracking, isEn),
                    ],
                  ] else if (orderProvider.trackingError != null) ...[
                    // Error State
                    _buildErrorCard(orderProvider.trackingError!, isEn),
                  ] else ...[
                    // Empty State
                    _buildEmptyOrdersCard(isEn),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // =========================================================================
  // CANCELLED / REFUNDED ORDER CARD
  // =========================================================================
  Widget _buildCancelledOrderCard(OrderTrackingModel tracking, LanguageProvider lang) {
    final isRefunded = tracking.isOrderRefunded;
    final isEn = lang.isEnglish;
    final title = isRefunded 
        ? ('Order Refunded')
        : ('Order Cancelled');
    final subtitle = isRefunded
        ? (isEn 
            ? 'This order has been cancelled and refunded. The payment has been processed back to your original payment source.' 
            : 'This order was cancelled and refunded. Your payment refund has been processed.')
        : (isEn 
            ? 'This order was cancelled and is no longer being processed or delivered. If you have questions or need assistance, please chat with our support team.' 
            : 'This order has been cancelled and is no longer being processed. If you have any questions, please contact support.');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1F2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isRefunded ? Icons.assignment_return_rounded : Icons.cancel_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF9F1239),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${'Order ID'}: #${tracking.orderId}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    isRefunded ? ('REFUNDED') : ('CANCELLED'),
                    style: const TextStyle(
                      color: Color(0xFFE11D48),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF475569),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),

                // Cancellation notice card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isEn
                              ? 'Courier tracking and transit milestones are disabled for this order.'
                              : 'Courier tracking is inactive for this order.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Buttons: Help on WhatsApp & Explore Store
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          final message = Uri.encodeComponent(
                            'Hello GlowBay Support, I have a question regarding my cancelled Order #${tracking.orderId}.',
                          );
                          final url = Uri.parse('https://wa.me/8801988883904?text=$message');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.support_agent_rounded, size: 16, color: Colors.white),
                        label: Text(
                          'Support Chat',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF101936),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        icon: const Icon(Icons.shopping_bag_outlined, size: 16, color: Color(0xFFFF2D78)),
                        label: Text(
                          'Explore Store',
                          style: const TextStyle(color: Color(0xFFFF2D78), fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF2D78)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    );
  }

  String _formatStatus(String status, bool isEn) {
    if (!isEn) return status;
    final s = status.toLowerCase();
    if (s.contains('cancel')) return 'Cancelled';
    if (s.contains('refund')) return 'Refunded';
    if (s.contains('process')) return 'Processing';
    if (s.contains('complet') || s.contains('deliver')) return 'Delivered';
    if (s.contains('ship') || s.contains('transit')) return 'In Transit';
    if (s.contains('hold')) return 'On Hold';
    if (s.contains('pend')) return 'Pending';
    return status;
  }

  // =========================================================================
  // STRICT FUNNEL FILTER (Lazada/Shopee Mutual Exclusivity Architecture)
  // =========================================================================
  List<dynamic> _filterOrdersByFunnel(List<dynamic> orders, String funnel) {
    if (funnel == 'all') return orders;
    return orders.where((order) {
      final funnelCategory = (order['funnel_category'] ?? '').toString().toLowerCase();
      final rawStatus = (order['raw_status'] ?? order['status'] ?? '').toString().toLowerCase();
      final statusLabel = (order['status_label'] ?? '').toString().toLowerCase();
      final isCancelled = order['is_cancelled'] == true ||
          rawStatus.contains('cancel') ||
          statusLabel.contains('cancel') ||
          rawStatus.contains('failed');
      final isRefunded = order['is_refunded'] == true ||
          rawStatus.contains('refund') ||
          statusLabel.contains('refund');

      // 1. Cancelled Orders: Strictly cancelled or failed
      if (funnel == 'cancelled') {
        return isCancelled || funnelCategory == 'cancelled';
      }

      // 2. Returns & Refunds: Strictly returns or refunded orders
      if (funnel == 'returns') {
        return (isRefunded || funnelCategory == 'returns' || rawStatus.contains('return') || statusLabel.contains('return')) && !isCancelled;
      }

      // 3. CRITICAL ISOLATION RULE: Cancelled or Refunded orders NEVER appear in active funnels!
      if (isCancelled || isRefunded) return false;

      // 3. To Pay
      if (funnel == 'to_pay') {
        return funnelCategory == 'to_pay' ||
            rawStatus.contains('pend') ||
            rawStatus.contains('hold') ||
            rawStatus.contains('to-pay') ||
            rawStatus.contains('draft');
      }

      // 4. To Ship
      if (funnel == 'to_ship') {
        return funnelCategory == 'to_ship' ||
            rawStatus.contains('process') ||
            rawStatus.contains('to-ship') ||
            rawStatus.contains('sourcing') ||
            rawStatus.contains('payment-review');
      }

      // 5. In Transit
      if (funnel == 'in_transit') {
        return funnelCategory == 'in_transit' ||
            rawStatus.contains('transit') ||
            rawStatus.contains('flight') ||
            rawStatus.contains('hub') ||
            rawStatus.contains('courier') ||
            rawStatus.contains('shipped');
      }

      // 6. Delivered
      if (funnel == 'delivered') {
        return funnelCategory == 'delivered' ||
            rawStatus.contains('complete') ||
            rawStatus.contains('deliver');
      }

      return true;
    }).toList();
  }

  // =========================================================================
  // 1. HORIZONTAL ORDER SELECTOR
  // =========================================================================
  Widget _buildOrderSelector(List<dynamic> orders, bool isEn) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: orders.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final order = orders[index];
          final id = (order['id'] ?? order['order_id'] ?? '').toString();
          final rawStatus = (order['status_label'] ?? order['status'] ?? '').toString();
          final status = isEn ? _formatStatus(rawStatus, true) : rawStatus;
          final isSelected = id == _selectedOrderId || (_selectedOrderId == null && index == 0);

          return GestureDetector(
            onTap: () => _selectOrder(id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF101936) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF101936) : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF101936).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: isSelected ? const Color(0xFFFF2D78) : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Order #$id',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  if (status.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withValues(alpha: 0.18) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 2. CROSS-BORDER ROUTE BANNER (No traveler/customs jargon)
  // =========================================================================
  Widget _buildCrossBorderRouteBanner(OrderTrackingModel tracking, bool isEn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F5), Color(0xFFFFEBF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCCD9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2D78).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Origin: KL Hub
          Row(
            children: [
              const Text('🇲🇾', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kuala Lumpur',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101936),
                    ),
                  ),
                  Text(
                    'Sourcing Hub',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF881337), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),

          // Air Transit indicator
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2D78),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flight_takeoff_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Air Cargo',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '2–4 Days',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF881337),
                ),
              ),
            ],
          ),

          // Destination: Dhaka Hub
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Dhaka Central',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101936),
                    ),
                  ),
                  Text(
                    isEn 
                        ? (tracking.isInsideDhaka ? 'Dhaka Metro' : 'Outside Dhaka')
                        : (tracking.isInsideDhaka ? 'Dhaka Metro' : 'Outside Dhaka'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              const Text('🇧🇩', style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. CONSIGNMENT SUMMARY CARD
  // =========================================================================
  Widget _buildConsignmentSummaryCard(OrderTrackingModel tracking, bool isEn) {
    final effectiveTotal = (tracking.formattedTotal != '৳0' && tracking.formattedTotal != '৳ 0' && tracking.formattedTotal.isNotEmpty)
        ? tracking.formattedTotal
        : (tracking.total > 0
            ? '৳${tracking.total.toStringAsFixed(0)}'
            : (tracking.items.isNotEmpty
                ? '৳${tracking.items.fold<double>(0, (sum, i) => sum + i.total).toStringAsFixed(0)}'
                : '৳0'));
    final effectiveAddress = tracking.shippingAddress.trim().isNotEmpty
        ? tracking.shippingAddress
        : (tracking.billingName.isNotEmpty ? '${tracking.billingName} (Dhaka / Home Delivery)' : 'Dhaka (Home Delivery)');

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parcel Consignment #${tracking.orderId}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: const Color(0xFF101936),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total Value: $effectiveTotal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getStatusBg(tracking.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isEn ? _formatStatus(tracking.status, true) : tracking.statusLabel,
                  style: GoogleFonts.plusJakartaSans(
                    color: _getStatusColor(tracking.status),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          // Items preview
          if (tracking.items.isNotEmpty) ...[
            ...tracking.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.image.isNotEmpty
                            ? Image.network(
                                item.image,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  width: 40,
                                  height: 40,
                                  color: const Color(0xFFF1F5F9),
                                  child: const Icon(Icons.shopping_bag_outlined, size: 20, color: Color(0xFF94A3B8)),
                                ),
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                color: const Color(0xFFF1F5F9),
                                child: const Icon(Icons.shopping_bag_outlined, size: 20, color: Color(0xFF94A3B8)),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                            ),
                            Text(
                              'Qty: ${item.quantity} • ${item.formattedTotal}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          const SizedBox(height: 6),
          // Delivery destination
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFFF2D78)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Delivery: $effectiveAddress',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Return Status Banner (if return requested)
          if (tracking.returnStatus.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment_return_outlined, size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEn
                          ? 'Return Status: ${tracking.returnStatus.toUpperCase()}'
                          : 'Return Status: ${tracking.returnStatus.toUpperCase()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons: Cancel Order & Request Return (Only for active orders)
          if (!tracking.isOrderCancelled && !tracking.isOrderRefunded && (tracking.canCancel || tracking.canReturn)) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (tracking.canCancel)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCancelOrderDialog(tracking, isEn),
                      icon: const Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFDC2626)),
                      label: Text(
                        'Cancel Order',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        backgroundColor: const Color(0xFFFEF2F2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                if (tracking.canCancel && tracking.canReturn)
                  const SizedBox(width: 10),
                if (tracking.canReturn)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRequestReturnDialog(tracking, isEn),
                      icon: const Icon(Icons.assignment_return_outlined, size: 16, color: Colors.white),
                      label: Text(
                        'Request Return',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // 4. EMBEDDED IN-APP NATIVE STEADFAST COURIER CARD (STRICTLY NO EXTERNAL REDIRECTS)
  // =========================================================================
  Widget _buildEmbeddedSteadfastCourierCard(OrderTrackingModel tracking, bool isEn) {
    // Resolve courier telemetry: live response or fallback from cache
    final courier = tracking.courierTelemetry ?? _localCourierCache[tracking.orderId];
    final hasTrackingCode = (courier != null && courier.consignmentId.isNotEmpty) || tracking.courierCode.isNotEmpty;
    final consignmentCode = courier?.consignmentId.isNotEmpty == true
        ? courier!.consignmentId
        : (tracking.courierCode.isNotEmpty ? tracking.courierCode : 'ST-${tracking.orderId}');

    final liveStatus = isEn
        ? (tracking.currentStage >= 5
            ? 'Parcel is with rider for delivery'
            : (tracking.currentStage == 4
                ? 'At Dhaka sorting hub, preparing for courier pickup'
                : 'In transit via Air Cargo from Kuala Lumpur'))
        : (courier?.statusBengali.isNotEmpty == true
            ? courier!.statusBengali
            : (tracking.currentStage >= 5
                ? 'Parcel is with rider for delivery'
                : (tracking.currentStage == 4
                    ? 'At Dhaka sorting hub, preparing for courier pickup'
                    : 'In transit via Air Cargo from Kuala Lumpur')));

    final hubLocation = isEn
        ? (tracking.isInsideDhaka ? 'Dhaka Central Sorting Hub, Tejgaon' : 'Dhaka Regional Dispatch Hub')
        : (courier?.hubLocation.isNotEmpty == true
            ? courier!.hubLocation
            : (tracking.isInsideDhaka ? 'Dhaka Central Sorting Hub, Tejgaon' : 'Dhaka Regional Dispatch Hub'));

    final lastUpdated = isEn
        ? 'Synced just now'
        : (courier?.lastUpdated.isNotEmpty == true ? courier!.lastUpdated : 'Synced just now');
    final codBalanceText = tracking.codBalanceFormatted.isNotEmpty ? tracking.codBalanceFormatted : '৳${tracking.codBalance.toStringAsFixed(0)}';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Courier badge + Consignment Tracking Code
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🚚 Courier Delivery Update',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                            color: const Color(0xFF065F46),
                          ),
                        ),
                        Text(
                          'Steadfast Express Telemetry',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: const Color(0xFF047857),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (hasTrackingCode)
                  InkWell(
                    onTap: () => _copyToClipboard(consignmentCode, 'Consignment Code'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            consignmentCode,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                              color: const Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy_rounded, size: 12, color: Color(0xFF10B981)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFD1FAE5)),

          // Body: Live Status Indicator (Pulsing Emerald Green Dot)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated Pulsing Emerald Dot
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF10B981),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            liveStatus,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                              color: const Color(0xFF064E3B),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.storefront_rounded, size: 14, color: Color(0xFF047857)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  hubLocation,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF047857),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF059669)),
                              const SizedBox(width: 4),
                              Text(
                                'Last update: $lastUpdated',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  color: const Color(0xFF059669),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // COD Balance Card (50% remaining due)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: const Icon(Icons.payments_rounded, color: Color(0xFFEA580C), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Due on Delivery (Remaining 50%)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              codBalanceText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFEA580C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Cash on Delivery',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 5. VISUAL 5-STAGE CROSS-BORDER PROGRESS TIMELINE
  // =========================================================================
  Widget _buildFiveStageTimelineCard(OrderTrackingModel tracking, bool isEn) {
    final courierText = (tracking.courierTelemetry?.status ?? tracking.status).toLowerCase();
    final isCourierWithRider = courierText.contains('rider') ||
        courierText.contains('delivery') ||
        courierText.contains('out for delivery');
    final currentStage = (isCourierWithRider || tracking.hasCourierTracking) ? 5 : tracking.currentStage;
    final isInsideDhaka = tracking.isInsideDhaka;

    // Define 5 pristine stages matching exact user requirements
    final List<Map<String, dynamic>> stages = [
      {
        'stage': 1,
        'title': 'Order Confirmed — Sourcing in Progress',
        'subtitle': isEn
            ? 'Order verified and queued at Kuala Lumpur Central Sourcing Hub.'
            : 'Order verified, queued for sourcing at Kuala Lumpur center.',
        'icon': Icons.assignment_turned_in_rounded,
        'eta': '',
      },
      {
        'stage': 2,
        'title': 'Product Sourced Successfully',
        'subtitle': isEn
            ? 'Collected from official brand outlet in Kuala Lumpur with packing slip printed.'
            : 'Sourced from official Malaysia outlet and packing slip printed.',
        'icon': Icons.check_circle_rounded,
        'eta': '',
      },
      {
        'stage': 3,
        'title': 'In Transit: KL to Dhaka (Arrives in 2–4 Days)',
        'subtitle': isEn
            ? 'Dispatched via Air Cargo from Kuala Lumpur hub to Dhaka.'
            : 'Dispatched via Air Cargo from Kuala Lumpur hub towards Dhaka.',
        'icon': Icons.flight_takeoff_rounded,
        'eta': '2–4 Business Days',
      },
      {
        'stage': 4,
        'title': 'Arrived at Dhaka Sorting Hub',
        'subtitle': isEn
            ? 'Received at Dhaka Central Sorting Hub, quality inspection completed.'
            : 'Received at Dhaka central sorting hub; quality inspection complete.',
        'icon': Icons.warehouse_rounded,
        'eta': isEn
            ? (isInsideDhaka ? '1–2 Days Delivery' : '2–3 Days Delivery')
            : (isInsideDhaka ? 'Delivery in 1–2 days' : 'Delivery in 2–3 days'),
      },
      {
        'stage': 5,
        'title': 'Out for Delivery',
        'subtitle': isEn
            ? (isInsideDhaka
                ? 'Processing delivery to your Dhaka Metro address via courier rider.'
                : 'Express delivery in progress to outside Dhaka address via courier.')
            : (isInsideDhaka
                ? 'Delivery in progress via Steadfast courier rider across Dhaka.'
                : 'Express delivery in progress via Steadfast courier nationwide.'),
        'icon': Icons.delivery_dining_rounded,
        'eta': isEn
            ? (isInsideDhaka ? '1–2 Days Delivery' : '2–3 Days Delivery')
            : (isInsideDhaka ? 'Delivery in 1–2 days' : 'Delivery in 2–3 days'),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5-Stage Cross-Border Tracking Lifecycle',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: const Color(0xFF101936),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Stage $currentStage / 5',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFF2D78),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Render step items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final stepData = stages[index];
              final int stepNum = stepData['stage'] as int;
              final bool isCompleted = currentStage >= stepNum;
              final bool isActive = currentStage == stepNum;
              final bool isLast = index == stages.length - 1;

              // Timestamp lookup from timeline payload if present
              String stepTime = '';
              if (tracking.timeline.isNotEmpty && index < tracking.timeline.length) {
                stepTime = tracking.timeline[index].time;
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Node + Vertical Connector Line
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFFF2D78)
                                : (isCompleted ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                            shape: BoxShape.circle,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFF2D78).withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Icon(
                              isCompleted ? (stepData['icon'] as IconData) : Icons.circle_outlined,
                              color: isCompleted ? Colors.white : const Color(0xFF94A3B8),
                              size: 16,
                            ),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2.5,
                              color: isCompleted && currentStage > stepNum
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Stage Content Details
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    stepData['title'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: isActive
                                          ? const Color(0xFFFF2D78)
                                          : (isCompleted ? const Color(0xFF101936) : const Color(0xFF94A3B8)),
                                    ),
                                  ),
                                ),
                                if ((stepData['eta'] as String).isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    margin: const EdgeInsets.only(left: 6),
                                    decoration: BoxDecoration(
                                      color: isActive ? const Color(0xFFFFF0F5) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isActive ? const Color(0xFFFFCCD9) : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Text(
                                      stepData['eta'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        color: isActive ? const Color(0xFFFF2D78) : const Color(0xFF475569),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              stepData['subtitle'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                height: 1.35,
                                color: isCompleted ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                              ),
                            ),
                            if (stepTime.isNotEmpty && isCompleted) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 11, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    stepTime,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      color: const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 6. WHATSAPP VIP SUPPORT
  // =========================================================================
  Widget _buildWhatsAppSupportCard(OrderTrackingModel tracking, bool isEn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF10B981), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have questions about your order?',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: const Color(0xFF101936),
                  ),
                ),
                Text(
                  'Chat with us on official WhatsApp',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _launchWhatsAppSupport(tracking.orderId.toString()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(
              'WhatsApp',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 7. EMPTY / ERROR STATES
  // =========================================================================
  Widget _buildErrorCard(String message, bool isEn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _initTracking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2D78),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInCard(bool isEn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_person_rounded, size: 44, color: Color(0xFFFF2D78)),
          ),
          const SizedBox(height: 18),
          Text(
            'Login to View Live Tracking',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101936),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? 'Sign in to your account to view real-time live tracking of your pre-orders from Malaysia sourcing to Dhaka delivery.'
                : 'Sign in to your account to view real-time live tracking from Kuala Lumpur to your doorstep.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, height: 1.4, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2D78),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'Login / Register',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersCard(bool isEn) {
    String title = 'No Active Orders Found';
    String desc = isEn
        ? 'You do not have any running orders in this section. Browse catalog to place a new pre-order.'
        : 'No active orders in this section. Browse catalog to pre-order.';

    if (_selectedFunnel == 'to_pay') {
      title = 'No Unpaid Orders';
      desc = isEn
          ? 'All your orders are verified or paid. You have zero pending payments.'
          : 'You have no unpaid or pending payment orders.';
    } else if (_selectedFunnel == 'to_ship') {
      title = 'No Orders in To Ship';
      desc = isEn
          ? 'You do not have any orders currently being sourced or packed in Kuala Lumpur.'
          : 'No orders are currently being packed or sourced at Kuala Lumpur hub.';
    } else if (_selectedFunnel == 'in_transit') {
      title = 'No Parcels in Transit';
      desc = isEn
          ? 'You currently have no air cargo or courier shipments on the road.'
          : 'No parcels are currently in transit via Air Cargo or courier.';
    } else if (_selectedFunnel == 'delivered') {
      title = 'No Delivered Orders Yet';
      desc = isEn
          ? 'Completed orders and delivery history will show up here.'
          : 'Delivered orders will appear here.';
    } else if (_selectedFunnel == 'returns') {
      title = 'No Returns or Cancelled Orders';
      desc = isEn
          ? 'Cancelled orders and refund cases will be listed here.'
          : 'You have no cancelled orders or refund cases.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 44, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101936),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Color _getStatusBg(String status) {
    final st = status.toLowerCase();
    if (st.contains('complete') || st.contains('deliver')) return const Color(0xFFDCFCE7);
    if (st.contains('process') || st.contains('ship') || st.contains('transit')) return const Color(0xFFEFF6FF);
    if (st.contains('hold') || st.contains('pend')) return const Color(0xFFFEF3C7);
    if (st.contains('cancel') || st.contains('refund')) return const Color(0xFFFEE2E2);
    return const Color(0xFFF1F5F9);
  }

  Color _getStatusColor(String status) {
    final st = status.toLowerCase();
    if (st.contains('complete') || st.contains('deliver')) return const Color(0xFF16A34A);
    if (st.contains('process') || st.contains('ship') || st.contains('transit')) return const Color(0xFF2563EB);
    if (st.contains('hold') || st.contains('pend')) return const Color(0xFFD97706);
    if (st.contains('cancel') || st.contains('refund')) return const Color(0xFFDC2626);
    return const Color(0xFF475569);
  }

  // =========================================================================
  // 5-FUNNEL TABS
  // =========================================================================
  Widget _buildFunnelTabs(bool isEn) {
    final funnels = [
      {'id': 'all', 'label': 'All', 'icon': Icons.apps_rounded},
      {'id': 'to_pay', 'label': 'To Pay', 'icon': Icons.account_balance_wallet_outlined},
      {'id': 'to_ship', 'label': 'To Ship', 'icon': Icons.inventory_2_outlined},
      {'id': 'in_transit', 'label': 'In Transit', 'icon': Icons.local_shipping_outlined},
      {'id': 'delivered', 'label': 'Delivered', 'icon': Icons.verified_outlined},
      {'id': 'cancelled', 'label': 'Cancelled', 'icon': Icons.cancel_outlined},
      {'id': 'returns', 'label': 'Returns', 'icon': Icons.assignment_return_outlined},
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: funnels.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = funnels[index];
          final isSelected = _selectedFunnel == f['id'];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              final newFunnel = f['id'] as String;
              final auth = context.read<AuthProvider>();
              final orderProvider = context.read<OrderProvider>();
              final allOrders = auth.dashboardData?.recentOrders ?? [];
              final matchingOrders = _filterOrdersByFunnel(allOrders, newFunnel);

              setState(() {
                _selectedFunnel = newFunnel;
                if (matchingOrders.isNotEmpty) {
                  final stillValid = matchingOrders.any((o) => (o['id'] ?? o['order_id']).toString() == _selectedOrderId);
                  if (!stillValid) {
                    _selectedOrderId = (matchingOrders.first['id'] ?? matchingOrders.first['order_id']).toString();
                    orderProvider.trackOrder(_selectedOrderId!);
                  }
                } else {
                  _selectedOrderId = null;
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF2D78) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF2D78) : const Color(0xFFE2E8F0),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF2D78).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    f['icon'] as IconData,
                    size: 14,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    f['label'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 3-HOUR UNPAID DEADLINE COUNTDOWN CARD
  // =========================================================================
  Widget _buildPaymentDeadlineCard(OrderTrackingModel tracking, bool isEn) {
    if (tracking.isOrderCancelled || tracking.isOrderRefunded || tracking.paymentStatus == 'approved') {
      return const SizedBox.shrink();
    }
    final remaining = _remainingSeconds > 0 ? _remainingSeconds : tracking.remainingPaymentSeconds;
    if (remaining <= 0 && tracking.paymentStatus != 'pending') {
      return const SizedBox.shrink();
    }

    final hours = remaining ~/ 3600;
    final minutes = (remaining % 3600) ~/ 60;
    final seconds = remaining % 60;
    final isExpired = remaining <= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD97706),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3-Hour Payment Window',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                    Text(
                      isEn
                          ? (isExpired ? 'Payment time expired' : 'Complete payment before deadline')
                          : (isExpired ? 'Payment window expired' : 'Submit payment within the remaining time to confirm pre-order'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFFB45309),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF92400E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEn
                        ? 'If payment details are not submitted within 3 hours, the order is automatically cancelled and reserved stock is restocked.'
                        : 'Advance payment details must be submitted within 3 hours, otherwise the order will auto-cancel and reserved stock will be released.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF78350F),
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // PAYMENT STATUS BANNER
  // =========================================================================
  Widget _buildPaymentStatusBanner(OrderTrackingModel tracking, bool isEn) {
    if (tracking.isPaymentUnderReview) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user_outlined, color: Color(0xFF2563EB), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Under Review',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E40AF),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEn
                        ? 'Your TrxID has been submitted. GlowBay admin is verifying the transaction.'
                        : 'Your TrxID has been submitted. It will move to To Ship once verified by our admin team.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (tracking.isPaymentRejected) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Verification Failed',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF991B1B),
                        ),
                      ),
                      if (tracking.paymentRejectionReason.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Reason: ${tracking.paymentRejectionReason}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFFB91C1C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showResubmitPaymentDialog(tracking, isEn),
                icon: const Icon(Icons.edit_note_rounded, size: 18, color: Colors.white),
                label: Text(
                  'Update Correct Payment Details',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // =========================================================================
  // MODAL DIALOGS: CANCEL, RESUBMIT PAYMENT, RETURN REQUEST
  // =========================================================================
  void _showCancelOrderDialog(OrderTrackingModel tracking, bool isEn) {
    String selectedReason = 'Ordered wrong item';
    final reasons = [
      'Ordered wrong item',
      'Delivery taking too long',
      'Want to change address',
      'Payment issue',
      'Bought from elsewhere',
      'Other reason',
    ];
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancel Order #${tracking.orderId}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF101936),
                          ),
                        ),
                        Text(
                          'Select a reason for cancellation',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: Color(0xFFDC2626), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEn
                            ? 'Instant Restock: Items in this order will be immediately returned to warehouse inventory.'
                            : 'Instant Restock: Cancelled items will immediately return to available inventory.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: const Color(0xFF991B1B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ...reasons.map((r) => RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFDC2626),
                    title: Text(
                      r,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    value: r,
                    // ignore: deprecated_member_use
                    groupValue: selectedReason,
                    // ignore: deprecated_member_use
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedReason = val);
                    },
                  )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Keep Order',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() => isSubmitting = true);
                              final res = await context.read<OrderProvider>().cancelOrder(
                                    orderId: tracking.orderId,
                                    reason: selectedReason,
                                  );
                              setModalState(() => isSubmitting = false);
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] ?? 'Order cancelled successfully'),
                                    backgroundColor: res['success'] == true ? const Color(0xFF101936) : const Color(0xFFDC2626),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Confirm Cancel',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResubmitPaymentDialog(OrderTrackingModel tracking, bool isEn) {
    final trxController = TextEditingController();
    final senderController = TextEditingController();
    final receiptController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Update Payment Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF101936),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isEn
                    ? 'Enter the correct Transaction ID for order #${tracking.orderId}'
                    : 'Enter correct TrxID and sender phone for Order #${tracking.orderId}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: trxController,
                decoration: InputDecoration(
                  labelText: 'Transaction ID (TrxID) *',
                  hintText: 'e.g. BL9A7K2M90',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.receipt_long_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: senderController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Sender bKash/Nagad Number',
                  hintText: '01XXXXXXXXX',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_iphone_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: receiptController,
                decoration: InputDecoration(
                  labelText: 'Receipt Link / Image URL',
                  hintText: 'https://...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final trx = trxController.text.trim();
                          if (trx.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter Transaction ID'),
                                backgroundColor: const Color(0xFFDC2626),
                              ),
                            );
                            return;
                          }
                          setModalState(() => isSubmitting = true);
                          final res = await context.read<OrderProvider>().resubmitPayment(
                                orderId: tracking.orderId,
                                trxId: trx,
                                senderNumber: senderController.text.trim(),
                                receiptUrl: receiptController.text.trim(),
                              );
                          setModalState(() => isSubmitting = false);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res['message'] ?? 'Payment details updated successfully'),
                                backgroundColor: res['success'] == true ? const Color(0xFF101936) : const Color(0xFFDC2626),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2D78),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Submit For Verification',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestReturnDialog(OrderTrackingModel tracking, bool isEn) {
    String selectedReason = 'Damaged or defective item';
    final reasons = [
      'Damaged or defective item',
      'Wrong product delivered',
      'Quality or expiry issue',
      'Not as described',
      'Other issue',
    ];
    final notesController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.assignment_return_outlined, color: Color(0xFF2563EB), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7-Day Return / Refund',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF101936),
                          ),
                        ),
                        Text(
                          'Order #${tracking.orderId}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: Color(0xFF2563EB), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEn
                            ? 'Delivered orders qualify for 7-day return policy for damaged or incorrect items.'
                            : 'Returns & refunds are applicable within 7 days of delivery for damaged or mismatched products.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: const Color(0xFF1E40AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...reasons.map((r) => RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFF2563EB),
                    title: Text(
                      r,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    value: r,
                    // ignore: deprecated_member_use
                    groupValue: selectedReason,
                    // ignore: deprecated_member_use
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedReason = val);
                    },
                  )),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Additional Details (Optional)',
                  hintText: 'Describe the defect or reason',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setModalState(() => isSubmitting = true);
                          final res = await context.read<OrderProvider>().requestReturn(
                                orderId: tracking.orderId,
                                reason: selectedReason,
                                notes: notesController.text.trim(),
                              );
                          setModalState(() => isSubmitting = false);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res['message'] ?? 'Return request submitted successfully'),
                                backgroundColor: res['success'] == true ? const Color(0xFF101936) : const Color(0xFFDC2626),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Submit Return Request',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
