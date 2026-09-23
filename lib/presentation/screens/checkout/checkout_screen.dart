import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/bangladesh_regions.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/cart_provider.dart';
import '../../../logic/order_provider.dart';
import '../../../logic/language_provider.dart';
import '../account/account_screen.dart';
import '../subpages/order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final CartItem? directItem;
  const CheckoutScreen({super.key, this.directItem});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  List<CartItem> _getActiveItems(CartProvider cart) {
    if (widget.directItem != null) {
      return [widget.directItem!];
    }
    return cart.items.where((i) => i.isSelected).toList();
  }

  // Customer & Address Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _buildingController = TextEditingController();
  final _roadController = TextEditingController();
  final _areaController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  // Payment Controllers
  final _senderNumberController = TextEditingController();
  final _trxIdController = TextEditingController();


  // Selected State
  String _addressType = 'home'; // 'home', 'office', 'other'
  String _selectedDivision = 'Dhaka';
  String _selectedDistrict = 'Dhaka';
  String _selectedUpazila = 'Uttara';

  String _paymentPlan = 'advance_50'; // 'advance_50' or 'full_100'
  String _paymentGateway = 'glowbay_bkash'; // 'glowbay_bkash', 'glowbay_nagad', 'glowbay_bank'

  bool _showAllItems = false;
  XFile? _receiptImage;
  String? _receiptBase64;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn && auth.currentUser != null) {
      _nameController.text = auth.currentUser!.name;
      _emailController.text = auth.currentUser!.email;
      _phoneController.text = auth.currentUser!.phone;
      _whatsappController.text = auth.currentUser!.phone;
    }

    _loadDefaultSavedAddress();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchPaymentSettings();
      final cart = context.read<CartProvider>();
      cart.setShippingLocation(_selectedDistrict.toLowerCase() == 'dhaka');
    });
  }

  Future<void> _loadDefaultSavedAddress() async {
    final list = await LocalStorageService().getAddressesRaw();
    if (list.isNotEmpty && mounted) {
      final defaultAddr = list.firstWhere((a) => a['is_default'] == true, orElse: () => list.first);
      setState(() {
        if (defaultAddr['full_name'] != null && defaultAddr['full_name'].toString().isNotEmpty) {
          _nameController.text = defaultAddr['full_name'];
        }
        if (defaultAddr['phone'] != null && defaultAddr['phone'].toString().isNotEmpty) {
          _phoneController.text = defaultAddr['phone'];
        }
        if (defaultAddr['whatsapp_phone'] != null && defaultAddr['whatsapp_phone'].toString().isNotEmpty) {
          _whatsappController.text = defaultAddr['whatsapp_phone'];
        }
        if (defaultAddr['building_name'] != null) _buildingController.text = defaultAddr['building_name'];
        if (defaultAddr['road_number'] != null) _roadController.text = defaultAddr['road_number'];
        if (defaultAddr['area'] != null) _areaController.text = defaultAddr['area'];
        if (defaultAddr['postcode'] != null) _postcodeController.text = defaultAddr['postcode'];
        if (defaultAddr['district_name'] != null) _selectedDistrict = defaultAddr['district_name'];
        if (defaultAddr['thana'] != null && defaultAddr['thana'].toString().isNotEmpty) {
          _selectedUpazila = defaultAddr['thana'];
        }
        if (defaultAddr['address_type'] != null) _addressType = defaultAddr['address_type'];
      });
      context.read<CartProvider>().setShippingLocation(_selectedDistrict.toLowerCase() == 'dhaka');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _buildingController.dispose();
    _roadController.dispose();
    _areaController.dispose();
    _postcodeController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    _senderNumberController.dispose();
    _trxIdController.dispose();
    super.dispose();
  }

  // Calculate 10 to 25 Days Estimated Delivery Range
  String _getEstimatedDeliveryRange([bool isEn = true]) {
    final start = DateTime.now().add(const Duration(days: 10));
    final end = DateTime.now().add(const Duration(days: 25));
    const enMonths = {
      1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr',
      5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug',
      9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
    };
    final m1 = enMonths[start.month] ?? '';
    final m2 = enMonths[end.month] ?? '';
    final d1 = start.day.toString();
    final d2 = end.day.toString();
    return (m1 == m2) ? '$d1 – $d2 $m1' : '$d1 $m1 – $d2 $m2';
  }

  Future<void> _pickReceiptImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _receiptImage = picked;
          _receiptBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      debugPrint('Error picking receipt image: $e');
    }
  }

  void _showImagePickerModal() {
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
                'Upload Payment Slip / Receipt',
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF101936)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMediaOption(Icons.camera_alt, 'Camera', () {
                    Navigator.pop(ctx);
                    _pickReceiptImage(ImageSource.camera);
                  }),
                  _buildMediaOption(Icons.photo_library, 'Gallery', () {
                    Navigator.pop(ctx);
                    _pickReceiptImage(ImageSource.gallery);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFD4E2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: const Color(0xFFFF2D78)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF101936))),
          ],
        ),
      ),
    );
  }

  // Interactive High-Res QR Zoom Modal Dialog (Mobile UI standard)
  void _showQrZoomDialog({
    required String qrData,
    required String activeNumber,
    required double amount,
    required String gateway,
    required String qrColor,
    String? customQrImageUrl,
  }) {
    HapticFeedback.lightImpact();
    final bigQrUrl = (customQrImageUrl != null && customQrImageUrl.isNotEmpty)
        ? customQrImageUrl
        : 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&color=$qrColor&data=${Uri.encodeComponent(qrData)}';
    final Color brandColor = gateway == 'glowbay_bkash'
        ? const Color(0xFFD12053)
        : (gateway == 'glowbay_nagad'
            ? const Color(0xFFF7941D)
            : (gateway == 'glowbay_bangla_qr' ? const Color(0xFF059669) : const Color(0xFF15803D)));
    final String brandTitle = gateway == 'glowbay_bkash'
        ? 'bKash Send Money QR'
        : (gateway == 'glowbay_nagad'
            ? 'Nagad Send Money QR'
            : (gateway == 'glowbay_bangla_qr' ? ('Bangla QR (Integrated Payment)') : 'Bank Transfer QR'));

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.qr_code_2_rounded, color: brandColor, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        brandTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF101936),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Large QR Code Container
              Container(
                width: 220,
                height: 220,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brandColor.withValues(alpha: 0.35), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: brandColor.withValues(alpha: 0.14),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    bigQrUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: brandColor,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_2_rounded, size: 55, color: Colors.grey.shade400),
                        const SizedBox(height: 6),
                        Text('QR code failed to load', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Account Number with Copy
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.read<LanguageProvider>().isEnglish
                              ? (gateway == 'glowbay_bkash'
                                  ? 'bKash Number'
                                  : (gateway == 'glowbay_nagad'
                                      ? 'Nagad Number'
                                      : (gateway == 'glowbay_bangla_qr' ? 'Bangla QR / Bank A/C Number' : 'Account Number')))
                              : (gateway == 'glowbay_bkash'
                                  ? 'bKash Number'
                                  : (gateway == 'glowbay_nagad'
                                      ? 'Nagad Number'
                                      : (gateway == 'glowbay_bangla_qr' ? 'Bangla QR / Bank Account' : 'Account Number'))),
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                        SelectableText(
                          activeNumber,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: brandColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(ClipboardData(text: activeNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$activeNumber copied! ✓'),
                            backgroundColor: const Color(0xFF10B981),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 12, color: Colors.white),
                      label: Text('Copy', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Amount Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: brandColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: Color(0xFF101936)),
                    children: [
                      TextSpan(text: 'Payable Amount: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                        text: '৳${amount.toStringAsFixed(0)}',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5, color: brandColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scan directly with any mobile or banking app to pay',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitOrder() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      _showLoginPrompt(context);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields correctly *'), backgroundColor: AppColors.error),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    final activeItems = _getActiveItems(cart);

    if (activeItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No items selected for checkout!'), backgroundColor: AppColors.error),
      );
      return;
    }

    final orderItems = activeItems
        .map((i) => {
              'product_id': i.product.id,
              if (i.effectiveVariationId != null && i.effectiveVariationId! > 0)
                'variation_id': i.effectiveVariationId,
              if (i.selectedAttributes != null && i.selectedAttributes!.isNotEmpty)
                'variation': i.selectedAttributes,
              'quantity': i.quantity,
            })
        .toList();

    // Validate Sender & TrxID
    final sender = _senderNumberController.text.trim();
    final trxId = _trxIdController.text.trim();

    if (sender.isEmpty || sender.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter the 11-digit phone number you paid from *'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (trxId.isEmpty || trxId.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a valid Transaction ID (TrxID) or Bank Reference *'), backgroundColor: AppColors.error),
      );
      return;
    }

    // Receipt screenshot is optional (TrxID is verified by admin)

    final orderProvider = context.read<OrderProvider>();
    final fullAddress = '${_buildingController.text.trim()}, ${_roadController.text.trim()}, ${_areaController.text.trim()}, $_selectedDistrict - ${_postcodeController.text.trim()}';

    final itemsSubtotal = activeItems.fold(0.0, (s, i) => s + i.totalPrice);
    final totalWeightKg = activeItems.fold(0.0, (s, i) => s + i.totalWeightKg);
    final isInsideDhaka = _selectedDistrict.toLowerCase() == 'dhaka';
    final shippingCost = cart.calculateCustomShippingFee(weightKg: totalWeightKg, insideDhaka: isInsideDhaka);
    final voucherDiscount = widget.directItem != null ? 0.0 : cart.voucherDiscount;
    final totalOrderValue = (itemsSubtotal + shippingCost - voucherDiscount).clamp(0.0, double.infinity);

    final advance50 = (totalOrderValue * 0.5).roundToDouble();
    final basePayable = _paymentPlan == 'advance_50' ? advance50 : totalOrderValue;

    final paymentSettings = orderProvider.paymentSettings;
    double cashoutFee = 0.0;
    if (_paymentGateway == 'glowbay_bkash' && paymentSettings.bkashEnableCashoutFee) {
      cashoutFee = (basePayable * (paymentSettings.bkashCashoutFeePct / 100.0)).roundToDouble();
    } else if (_paymentGateway == 'glowbay_nagad' && paymentSettings.nagadEnableCashoutFee) {
      cashoutFee = (basePayable * (paymentSettings.nagadCashoutFeePct / 100.0)).roundToDouble();
    }

    final res = await orderProvider.placeOrder(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      division: _selectedDivision,
      district: _selectedDistrict,
      upazila: _selectedUpazila,
      address: fullAddress,
      paymentMethod: _paymentGateway,
      paymentPlan: _paymentPlan,
      senderNumber: sender,
      trxId: trxId,
      bankRef: (_paymentGateway == 'glowbay_bank' || _paymentGateway == 'glowbay_bangla_qr') ? trxId : null,
      receiptBase64: _receiptBase64,
      receiptFilename: _receiptImage != null ? _receiptImage!.name : 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
      shippingCost: shippingCost,
      totalWeight: totalWeightKg,
      cashoutFee: cashoutFee,
      note: 'Type: ${_addressType.toUpperCase()} | WhatsApp: ${_whatsappController.text.trim()} | Instruction: ${_noteController.text.trim()}',
      items: orderItems,
    );

    if (res['status'] == 'success') {
      final orderId = res['order_id'];
      if (widget.directItem == null) {
        cart.removeSelectedItems();
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 26),
                const SizedBox(width: 10),
                Expanded(child: Text('Order Placed Successfully!')),
              ],
            ),
            content: Text(
              context.read<LanguageProvider>().isEnglish
                  ? 'Thank you! Your pre-order (#$orderId) has been registered. Our Dhaka and Kuala Lumpur teams will verify and start processing immediately.'
                  : 'Thank you! Your pre-order (#$orderId) is recorded. Our team will verify and process it shortly.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(initialOrderId: orderId.toString()),
                    ),
                  );
                },
                child: const Text('TRACK ORDER', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFFF2D78))),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? ('Failed to complete order. Please try again.')), backgroundColor: AppColors.error),
        );
      }
    }
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
                    color: const Color(0xFFFF2D78).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: Color(0xFFFF2D78), size: 24),
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
                        'Account needed to confirm order',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              context.read<LanguageProvider>().isEnglish
                  ? 'Please log in to complete your pre-order and view live parcel tracking on GlowBay.'
                  : 'Please log in to complete your pre-order and track your parcel live.',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
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
                      backgroundColor: const Color(0xFFFF2D78),
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

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isEn = lang.isEnglish;
    final cart = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final paymentSettings = orderProvider.paymentSettings;
    final activeItems = _getActiveItems(cart);

    final itemsSubtotal = activeItems.fold(0.0, (s, i) => s + i.totalPrice);
    final totalWeightKg = activeItems.fold(0.0, (s, i) => s + i.totalWeightKg);
    final isInsideDhaka = _selectedDistrict.toLowerCase() == 'dhaka';
    final shippingCost = cart.calculateCustomShippingFee(weightKg: totalWeightKg, insideDhaka: isInsideDhaka);
    final voucherDiscount = widget.directItem != null ? 0.0 : cart.voucherDiscount;
    final totalOrderValue = (itemsSubtotal + shippingCost - voucherDiscount).clamp(0.0, double.infinity);

    final advance50 = (totalOrderValue * 0.5).roundToDouble();
    final due50 = (totalOrderValue - advance50);
    final basePayable = _paymentPlan == 'advance_50' ? advance50 : totalOrderValue;

    // Cash Out Charge Calculation (bKash & Nagad)
    double cashoutFee = 0.0;
    double cashoutFeePct = 0.0;
    if (_paymentGateway == 'glowbay_bkash' && paymentSettings.bkashEnableCashoutFee) {
      cashoutFeePct = paymentSettings.bkashCashoutFeePct;
      cashoutFee = (basePayable * (cashoutFeePct / 100.0)).roundToDouble();
    } else if (_paymentGateway == 'glowbay_nagad' && paymentSettings.nagadEnableCashoutFee) {
      cashoutFeePct = paymentSettings.nagadCashoutFeePct;
      cashoutFee = (basePayable * (cashoutFeePct / 100.0)).roundToDouble();
    }
    final totalPayableWithFee = basePayable + cashoutFee;

    // Dynamic QR URL based on payment method (includes cashout fee)
    final activeNumber = _paymentGateway == 'glowbay_bkash'
        ? paymentSettings.bkashNumber
        : (_paymentGateway == 'glowbay_nagad'
            ? paymentSettings.nagadNumber
            : (_paymentGateway == 'glowbay_bangla_qr'
                ? paymentSettings.banglaQrAccountNo
                : paymentSettings.accountNo));
    final qrColor = _paymentGateway == 'glowbay_bkash'
        ? 'D81B60'
        : (_paymentGateway == 'glowbay_nagad'
            ? 'F7941D'
            : (_paymentGateway == 'glowbay_bangla_qr' ? '059669' : '15803D'));
    final qrData = _paymentGateway == 'glowbay_bkash'
        ? 'bKash:$activeNumber?amount=${totalPayableWithFee.toInt()}'
        : (_paymentGateway == 'glowbay_nagad'
            ? 'Nagad:$activeNumber?amount=${totalPayableWithFee.toInt()}'
            : (_paymentGateway == 'glowbay_bangla_qr'
                ? 'BanglaQR:IBBL:$activeNumber?amount=${totalPayableWithFee.toInt()}'
                : 'Bank:$activeNumber?amount=${totalPayableWithFee.toInt()}'));
    final qrUrl = (_paymentGateway == 'glowbay_bangla_qr' && paymentSettings.banglaQrImageUrl.isNotEmpty)
        ? paymentSettings.banglaQrImageUrl
        : 'https://api.qrserver.com/v1/create-qr-code/?size=160x160&color=$qrColor&data=${Uri.encodeComponent(qrData)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP HEADER & 3-STEP STEPPER (100% Matching checkout_mobile_final.php)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF101936)),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF101936)),
                          children: const [
                            TextSpan(text: 'GlowBay'),
                            TextSpan(text: 'BD', style: TextStyle(color: Color(0xFFFF2D78))),
                          ],
                        ),
                      ),
                      const Icon(Icons.shield, color: Color(0xFF10B981), size: 22),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 3-Step Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
                          SizedBox(width: 4),
                          Text('Cart', style: TextStyle(color: Color(0xFF10B981), fontSize: 11.5, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('—', style: TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.w900)),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.credit_card, color: Color(0xFFFF2D78), size: 14),
                          SizedBox(width: 4),
                          Text('Checkout', style: TextStyle(color: Color(0xFFFF2D78), fontSize: 11.5, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('—', style: TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.w900)),
                      ),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.grey.shade400, size: 14),
                          const SizedBox(width: 4),
                          Text('Confirmation', style: TextStyle(color: Colors.grey.shade500, fontSize: 11.5, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEF2F6)),

            // ACTIVE BODY CONTENT (SCROLLABLE)
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CARD 1: ORDER SUMMARY (Top of page, matching web)
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardHeader(
                              icon: Icons.inventory_2_outlined,
                              title: 'Order Summary (${activeItems.length} Items)',
                              actionText: widget.directItem != null ? '' : 'Edit Cart',
                              onActionTap: widget.directItem != null ? () {} : () => Navigator.pop(context),
                            ),
                            const Divider(height: 16, color: Color(0xFFF1F5F9)),
                            ...activeItems.take(_showAllItems ? activeItems.length : 3).map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: item.displayImage,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) => Container(color: Colors.grey.shade200, width: 50, height: 50),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF101936)),
                                          ),
                                          if (item.variationText.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                item.variationText,
                                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                                              ),
                                            ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF0F5),
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(color: const Color(0xFFFFD1E3)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.local_shipping_outlined, size: 10, color: Color(0xFFFF2D78)),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Pre-Order (Malaysia)',
                                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFFF2D78)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '৳${item.totalPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF101936)),
                                        ),
                                        Text('Qty: ${item.quantity}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                            if (activeItems.length > 3) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => setState(() => _showAllItems = !_showAllItems),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _showAllItems ? 'Show less ▲' : 'Show more (+${activeItems.length - 3} items) ▼',
                                    style: const TextStyle(color: Color(0xFFFF2D78), fontWeight: FontWeight.w800, fontSize: 11.5),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // CARD 2: DELIVERY ADDRESS (Compact preview with switcher)
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardHeader(
                              icon: Icons.location_on,
                              title: 'Delivery Address',
                              actionText: 'Change',
                              onActionTap: () => _openAddressEditBottomSheet(),
                            ),
                            const Divider(height: 16, color: Color(0xFFF1F5F9)),
                            Row(
                              children: [
                                Text(
                                  _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : ('Customer Name'),
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF101936)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                    _addressType == 'office' ? '🏢 Office' : '🏠 Home',
                                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('✓ DEFAULT', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone, size: 12, color: Color(0xFFFF2D78)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _phoneController.text.isNotEmpty ? _phoneController.text : '01XXXXXXXXX',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                if (_whatsappController.text.isNotEmpty && _whatsappController.text.trim() != _phoneController.text.trim()) ...[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.chat_bubble_outline, size: 12, color: Color(0xFF25D366)),
                                      const SizedBox(width: 4),
                                      Text(_whatsappController.text, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ] else if (_whatsappController.text.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_outline, size: 11, color: Color(0xFF25D366)),
                                        SizedBox(width: 3),
                                        Text('WhatsApp Available', style: TextStyle(fontSize: 9.5, color: Color(0xFF2E7D32), fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_buildingController.text.isNotEmpty ? '${_buildingController.text}, ' : ''}${_roadController.text.isNotEmpty ? 'Road ${_roadController.text}, ' : ''}${_areaController.text.isNotEmpty ? '${_areaController.text}, ' : ''}$_selectedUpazila, $_selectedDistrict - ${_postcodeController.text.isNotEmpty ? _postcodeController.text : '1216'}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // CARD 3: DELIVERY METHOD & 10-25 DAYS TIMELINE (Matching web exactly)
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.local_shipping, size: 16, color: Color(0xFFFF2D78)),
                                    SizedBox(width: 6),
                                    Text('DELIVERY METHOD', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF101936), letterSpacing: 0.3)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('✓ Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9FB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFFD4E2)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.bolt, size: 16, color: Color(0xFFFF2D78)),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Pre-Order Home Delivery',
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF101936)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.event_available, size: 14, color: Color(0xFFD97706)),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${'Estimated Delivery: '}${_getEstimatedDeliveryRange(isEn)}',
                                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          totalWeightKg > 1
                                              ? '${isInsideDhaka ? 'Inside Dhaka' : 'Outside Dhaka'}: 1st kg ৳${isInsideDhaka ? '80' : '150'} + rest ${(totalWeightKg - 1).ceil()} kg × ৳${isInsideDhaka ? '20' : '30'}'
                                              : 'Directly sourced from Malaysia, home delivery nationwide (10–25 business days)',
                                          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '৳${shippingCost.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFFF2D78)),
                                      ),
                                      if (totalWeightKg > 0)
                                        Container(
                                          margin: const EdgeInsets.only(top: 3),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFBFDBFE), width: 0.5),
                                          ),
                                          child: Text(
                                            'Total ${totalWeightKg.toStringAsFixed(totalWeightKg.truncateToDouble() == totalWeightKg ? 0 : 1)} kg',
                                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
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
                      const SizedBox(height: 12),

                      // CARD 4: PAYMENT PLAN & GATEWAY SELECTOR (100% Matching checkout_mobile_final.php)
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.credit_card, size: 16, color: Color(0xFFFF2D78)),
                                    SizedBox(width: 6),
                                    Text('PAYMENT PLAN & METHOD', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF101936), letterSpacing: 0.3)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('🛡️ 100% Secure', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                                ),
                              ],
                            ),
                            const Divider(height: 16, color: Color(0xFFF1F5F9)),

                            // ── STEP 1: PAYMENT PLAN (50% Advance vs 100% Full) ──
                            Text(
                              '1. Select Payment Plan:',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _paymentPlan = 'advance_50'),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _paymentPlan == 'advance_50' ? const Color(0xFFFFF5F8) : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: _paymentPlan == 'advance_50' ? const Color(0xFFFF2D78) : const Color(0xFFE2E8F0),
                                          width: _paymentPlan == 'advance_50' ? 2 : 1,
                                        ),
                                        boxShadow: _paymentPlan == 'advance_50'
                                            ? [BoxShadow(color: const Color(0xFFFF2D78).withValues(alpha: 0.18), blurRadius: 14, offset: const Offset(0, 4))]
                                            : null,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _paymentPlan == 'advance_50' ? Icons.check_circle : Icons.radio_button_unchecked,
                                                      size: 13,
                                                      color: _paymentPlan == 'advance_50' ? const Color(0xFFFF2D78) : const Color(0xFF94A3B8),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Flexible(
                                                      child: Text(
                                                        '50% Advance',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFFFF2D78)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '৳${advance50.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: _paymentPlan == 'advance_50' ? const Color(0xFFFF2D78) : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Remaining 50% on Delivery COD', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF881337))),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                                            child: Text('POPULAR', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _paymentPlan = 'full_100'),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _paymentPlan == 'full_100' ? const Color(0xFFFFF5F8) : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: _paymentPlan == 'full_100' ? const Color(0xFFFF2D78) : const Color(0xFFE2E8F0),
                                          width: _paymentPlan == 'full_100' ? 2 : 1,
                                        ),
                                        boxShadow: _paymentPlan == 'full_100'
                                            ? [BoxShadow(color: const Color(0xFFFF2D78).withValues(alpha: 0.18), blurRadius: 14, offset: const Offset(0, 4))]
                                            : null,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _paymentPlan == 'full_100' ? Icons.check_circle : Icons.radio_button_unchecked,
                                                      size: 13,
                                                      color: _paymentPlan == 'full_100' ? const Color(0xFFFF2D78) : const Color(0xFF94A3B8),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Flexible(
                                                      child: Text(
                                                        '100% Full Pay',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 11.5,
                                                          fontWeight: FontWeight.w900,
                                                          color: _paymentPlan == 'full_100' ? const Color(0xFFFF2D78) : const Color(0xFF0F172A),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '৳${totalOrderValue.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: _paymentPlan == 'full_100' ? const Color(0xFFFF2D78) : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Due on Delivery ৳0 (Cashless)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                                            child: Text('CASHLESS', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // ── STEP 2: 4 GATEWAY SELECTOR (2x2 Grid) ──
                            Text(
                              '2. Select Payment Method:',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildPayGatewayBtn('glowbay_bkash', 'bKash', 'Send Money', const Color(0xFFD12053), Icons.phone_android, badgeText: '1.85% Fee', badgeColor: const Color(0xFFD12053)),
                                const SizedBox(width: 8),
                                _buildPayGatewayBtn('glowbay_nagad', 'Nagad', 'Send Money', const Color(0xFFF7941D), Icons.account_balance_wallet, badgeText: '1.5% Fee', badgeColor: const Color(0xFFF7941D)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildPayGatewayBtn('glowbay_bangla_qr', 'Bangla QR', 'bKash/Nagad/Bank', const Color(0xFF059669), Icons.qr_code_2_rounded, badgeText: '0% Fee (Free!)', badgeColor: const Color(0xFF059669)),
                                const SizedBox(width: 8),
                                _buildPayGatewayBtn('glowbay_bank', 'Islami Bank', 'Bank Deposit', const Color(0xFF15803D), Icons.account_balance, badgeText: '0% Fee', badgeColor: const Color(0xFF15803D)),
                              ],
                            ),
                            if (_paymentGateway == 'glowbay_bangla_qr')
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('🎉', style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'No Cashout Charge on Bangla QR (৳0 Fee / 0% Extra)!',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF065F46)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Scan directly using bKash, Nagad, CellFin, Rocket or any banking app with zero extra fees.',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF047857), height: 1.35),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (_paymentGateway == 'glowbay_bkash' || _paymentGateway == 'glowbay_nagad')
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('💡', style: TextStyle(fontSize: 17)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.35),
                                          children: [
                                            TextSpan(
                                              text: _paymentGateway == 'glowbay_bkash'
                                                  ? ('bKash 1.85% fee applies (৳${cashoutFee.toStringAsFixed(0)}). ')
                                                  : ('Nagad 1.5% fee applies (৳${cashoutFee.toStringAsFixed(0)}). '),
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                             TextSpan(
                                               text: 'Want to save fees? Choose Bangla QR — 0% extra fee (৳0 Fee)!',
                                               style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),

                            // ── PAYMENT DETAILS PANEL (Separate per gateway — matching website gb-pay-detail-panel) ──
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _paymentGateway == 'glowbay_bkash'
                                    ? const Color(0xFFFFF9FB)
                                    : (_paymentGateway == 'glowbay_nagad'
                                        ? const Color(0xFFFFFDF9)
                                        : (_paymentGateway == 'glowbay_bangla_qr' ? const Color(0xFFF0FDF4) : const Color(0xFFF8FCF9))),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _paymentGateway == 'glowbay_bkash'
                                      ? const Color(0xFFFFD4E2)
                                      : (_paymentGateway == 'glowbay_nagad'
                                          ? const Color(0xFFFFE4D0)
                                          : (_paymentGateway == 'glowbay_bangla_qr' ? const Color(0xFFA7F3D0) : const Color(0xFFBBF7D0))),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Account Info + QR Code (gb-pay-header-row) ──
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Left: Account details (gb-pay-info-left)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (_paymentGateway == 'glowbay_bangla_qr') ...[
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(4)),
                                                    child: Text('National Standard', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                                                  ),
                                                  const SizedBox(width: 5),
                                                    Text('Unified Bangla QR', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF065F46))),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text('Bank: ${paymentSettings.banglaQrBankName}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                                              Text('Account Name: ${paymentSettings.banglaQrAccountName}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF101936))),
                                              Text('Branch: ${paymentSettings.banglaQrBranchName}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                                              const SizedBox(height: 5),
                                              Wrap(
                                                spacing: 3,
                                                runSpacing: 3,
                                                children: (['✓ bKash', '✓ Nagad', '✓ CellFin', '✓ Rocket', '✓ Card']).map((app) => Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFA7F3D0))),
                                                  child: Text(app, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                                                )).toList(),
                                              ),
                                            ] else ...[
                                              Text(
                                                _paymentGateway == 'glowbay_bkash'
                                                    ? 'Account Type: bKash ${paymentSettings.bkashType}'
                                                    : (_paymentGateway == 'glowbay_nagad'
                                                        ? 'Account Type: Nagad ${paymentSettings.nagadType}'
                                                        : 'Bank Name: ${paymentSettings.bankName}'),
                                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w600),
                                              ),
                                              if (_paymentGateway == 'glowbay_bank') ...[
                                                const SizedBox(height: 2),
                                                Text('Account Name: ${paymentSettings.accountName}',
                                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF101936))),
                                                Text('Branch: ${paymentSettings.branchName}',
                                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                              ],
                                            ],
                                            const SizedBox(height: 4),
                                            // Number with Copy Button
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: SelectableText(
                                                    activeNumber,
                                                    style: TextStyle(
                                                      fontSize: 14.5,
                                                      fontWeight: FontWeight.w900,
                                                      color: _paymentGateway == 'glowbay_bkash'
                                                          ? const Color(0xFF101936)
                                                          : (_paymentGateway == 'glowbay_nagad'
                                                              ? const Color(0xFFF7941D)
                                                              : (_paymentGateway == 'glowbay_bangla_qr' ? const Color(0xFF059669) : const Color(0xFF15803D))),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap: () {
                                                    HapticFeedback.lightImpact();
                                                    Clipboard.setData(ClipboardData(text: activeNumber));
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('${_paymentGateway == 'glowbay_bkash' ? 'bKash' : (_paymentGateway == 'glowbay_nagad' ? 'Nagad' : (_paymentGateway == 'glowbay_bangla_qr' ? 'Bangla QR Account' : 'Bank'))} number copied! ✓'),
                                                        backgroundColor: const Color(0xFF10B981),
                                                        duration: const Duration(seconds: 2),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(color: const Color(0xFFCBD5E1)),
                                                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.copy_rounded, size: 12, color: Color(0xFF101936)),
                                                        const SizedBox(width: 4),
                                                        Text('Copy', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936))),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Right: QR Code (gb-pay-qr-right) — Interactive Tap to Zoom
                                      GestureDetector(
                                        onTap: () => _showQrZoomDialog(
                                          qrData: qrData,
                                          activeNumber: activeNumber,
                                          amount: totalPayableWithFee,
                                          gateway: _paymentGateway,
                                          qrColor: qrColor,
                                          customQrImageUrl: (_paymentGateway == 'glowbay_bangla_qr' && paymentSettings.banglaQrImageUrl.isNotEmpty) ? paymentSettings.banglaQrImageUrl : null,
                                        ),
                                        child: Container(
                                          width: 78,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: _paymentGateway == 'glowbay_bkash'
                                                ? const Color(0xFFFFF0F5)
                                                : (_paymentGateway == 'glowbay_nagad'
                                                    ? const Color(0xFFFFF8F0)
                                                    : const Color(0xFFF0FDF4)),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: _paymentGateway == 'glowbay_bkash'
                                                  ? const Color(0xFFFFD4E2)
                                                  : (_paymentGateway == 'glowbay_nagad'
                                                      ? const Color(0xFFFFE4D0)
                                                      : const Color(0xFFA7F3D0)),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(6),
                                                child: Image.network(
                                                  qrUrl,
                                                  width: 62,
                                                  height: 62,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return SizedBox(
                                                      width: 62,
                                                      height: 62,
                                                      child: Center(
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: _paymentGateway == 'glowbay_bkash'
                                                              ? const Color(0xFFD12053)
                                                              : (_paymentGateway == 'glowbay_nagad'
                                                                  ? const Color(0xFFF7941D)
                                                                  : (_paymentGateway == 'glowbay_bangla_qr' ? const Color(0xFF059669) : const Color(0xFF15803D))),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    width: 62,
                                                    height: 62,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade100,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Icon(Icons.qr_code_2_rounded, size: 40, color: Color(0xFF94A3B8)),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.zoom_in_rounded, size: 10, color: _paymentGateway == 'glowbay_bkash' ? const Color(0xFFD12053) : (_paymentGateway == 'glowbay_nagad' ? const Color(0xFFF7941D) : (_paymentGateway == 'glowbay_bangla_qr' ? const Color(0xFF059669) : const Color(0xFF15803D)))),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    'Enlarge',
                                                    style: TextStyle(
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.w800,
                                                      color: _paymentGateway == 'glowbay_bkash' ? const Color(0xFFD12053) : (_paymentGateway == 'glowbay_nagad' ? const Color(0xFFF7941D) : (_paymentGateway == 'glowbay_bangla_qr' ? const Color(0xFF059669) : const Color(0xFF15803D))),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // ── Split Pill Card (50% Advance / Due — gb-split-pill-card) ──
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: _paymentGateway == 'glowbay_bkash'
                                          ? Colors.white
                                          : (_paymentGateway == 'glowbay_nagad'
                                              ? const Color(0xFFFFF8F0)
                                              : (_paymentGateway == 'glowbay_bangla_qr' ? Colors.white : const Color(0xFFF0FDF4))),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _paymentGateway == 'glowbay_bkash'
                                            ? const Color(0xFFFFD4E2)
                                            : (_paymentGateway == 'glowbay_nagad'
                                                ? const Color(0xFFFFE4D0)
                                                : (_paymentGateway == 'glowbay_bangla_qr' ? const Color(0xFFA7F3D0) : const Color(0xFFBBF7D0))),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                _paymentPlan == 'advance_50'
                                                    ? (cashoutFee > 0 ? ('Payable (50% Adv + Fee):') : ('Payable (50% Adv):'))
                                                    : (cashoutFee > 0 ? ('Payable (100% Full + Fee):') : ('Payable (100% Full):')),
                                                style: const TextStyle(fontSize: 11, color: Color(0xFF101936), fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '৳${totalPayableWithFee.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w900,
                                                  color: _paymentGateway == 'glowbay_bkash'
                                                      ? const Color(0xFFFF2D78)
                                                      : (_paymentGateway == 'glowbay_nagad'
                                                          ? const Color(0xFFF7941D)
                                                          : (_paymentGateway == 'glowbay_bangla_qr' ? const Color(0xFF059669) : const Color(0xFF15803D))),
                                                ),
                                              ),
                                              if (cashoutFee > 0)
                                                Text(
                                                  '(Fee: ৳${cashoutFee.toStringAsFixed(0)})',
                                                  style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 30,
                                          color: _paymentGateway == 'glowbay_bkash'
                                              ? const Color(0xFFFFD4E2)
                                              : (_paymentGateway == 'glowbay_nagad'
                                                  ? const Color(0xFFFFE4D0)
                                                  : (_paymentGateway == 'glowbay_bangla_qr' ? const Color(0xFFA7F3D0) : const Color(0xFFBBF7D0))),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text('Due on Delivery:', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 2),
                                              Text(
                                                _paymentPlan == 'advance_50' ? '৳${due50.toStringAsFixed(0)}' : '৳0 (Cashless)',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // ── Step-by-Step Payment Instructions (matching website exactly) ──
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _paymentGateway == 'glowbay_bkash'
                                          ? const Color(0xFFFFF5F8)
                                          : (_paymentGateway == 'glowbay_nagad'
                                              ? const Color(0xFFFFF8F0)
                                              : (_paymentGateway == 'glowbay_bangla_qr' ? const Color(0xFFECFDF5) : const Color(0xFFF0FDF4))),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _paymentGateway == 'glowbay_bkash'
                                            ? const Color(0xFFFFE4EC)
                                            : (_paymentGateway == 'glowbay_nagad'
                                                ? const Color(0xFFFFECD5)
                                                : (_paymentGateway == 'glowbay_bangla_qr' ? const Color(0xFFA7F3D0) : const Color(0xFFD1FAE5))),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _paymentGateway == 'glowbay_bank'
                                              ? ('📋 Bank Deposit Instructions:')
                                              : (_paymentGateway == 'glowbay_bangla_qr' ? ('📋 Bangla QR Payment Steps:') : ('📋 Payment Steps:')),
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w900,
                                            color: _paymentGateway == 'glowbay_bkash'
                                                ? const Color(0xFFD12053)
                                                : (_paymentGateway == 'glowbay_nagad'
                                                    ? const Color(0xFFF7941D)
                                                    : (_paymentGateway == 'glowbay_bangla_qr' ? const Color(0xFF059669) : const Color(0xFF15803D))),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        if (_paymentGateway == 'glowbay_bkash') ...[
                                          _buildPayStep('1', 'Send Money ৳${totalPayableWithFee.toStringAsFixed(0)} via bKash App.${cashoutFee > 0 ? " (Inc. cashout fee)" : ""}', const Color(0xFFD12053)),
                                          _buildPayStep('2', 'Enter your bKash number & TrxID below.', const Color(0xFFD12053)),
                                          _buildPayStep('3', 'Upload a screenshot of payment receipt.', const Color(0xFFD12053)),
                                        ] else if (_paymentGateway == 'glowbay_nagad') ...[
                                          _buildPayStep('1', 'Send Money ৳${totalPayableWithFee.toStringAsFixed(0)} via Nagad App.${cashoutFee > 0 ? " (Inc. cashout fee)" : ""}', const Color(0xFFF7941D)),
                                          _buildPayStep('2', 'Enter your Nagad number & TrxID below.', const Color(0xFFF7941D)),
                                          _buildPayStep('3', 'Upload a screenshot of payment receipt.', const Color(0xFFF7941D)),
                                        ] else if (_paymentGateway == 'glowbay_bangla_qr') ...[
                                          _buildPayStep('1', 'Scan via "Bangla QR / QR Pay" in bKash, Nagad, CellFin or Bank app & pay ৳${totalPayableWithFee.toStringAsFixed(0)} (0% Fee).', const Color(0xFF059669)),
                                          _buildPayStep('2', 'Enter your sender number & TrxID / Reference below.', const Color(0xFF059669)),
                                          _buildPayStep('3', 'Upload a screenshot or photo of payment confirmation.', const Color(0xFF059669)),
                                        ] else ...[
                                          _buildPayStep('1', 'Deposit/transfer ৳${totalPayableWithFee.toStringAsFixed(0)} to Islami Bank A/C.', const Color(0xFF15803D)),
                                          _buildPayStep('2', 'Enter deposit reference number below.', const Color(0xFF15803D)),
                                          _buildPayStep('3', 'Upload a photo of bank deposit slip/receipt.', const Color(0xFF15803D)),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // ── Open App Button (bKash / Nagad / Bangla QR) ──
                                  if (_paymentGateway == 'glowbay_bkash' || _paymentGateway == 'glowbay_nagad') ...[
                                    GestureDetector(
                                      onTap: () async {
                                        final Uri appUri = _paymentGateway == 'glowbay_bkash'
                                            ? Uri.parse('https://www.bkash.com/app')
                                            : Uri.parse('https://nagad.com.bd/app');
                                        try {
                                          await launchUrl(appUri, mode: LaunchMode.externalApplication);
                                        } catch (_) {
                                          if (mounted) {
                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Could not open ${_paymentGateway == 'glowbay_bkash' ? 'bKash' : 'Nagad'} app. Please open manually.")),
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: _paymentGateway == 'glowbay_bkash'
                                                ? [const Color(0xFFE2136E), const Color(0xFFD12053)]
                                                : [const Color(0xFFF7941D), const Color(0xFFED7B08)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (_paymentGateway == 'glowbay_bkash' ? const Color(0xFFE2136E) : const Color(0xFFF7941D)).withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.white),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Open ${_paymentGateway == 'glowbay_bkash' ? 'bKash' : 'Nagad'} App',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text('📲', style: TextStyle(fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  // ── Sender Number Input ──
                                  Text(
                                    isEn
                                        ? (_paymentGateway == 'glowbay_bkash'
                                            ? 'Your bKash Number (Used for Payment) *'
                                            : (_paymentGateway == 'glowbay_nagad'
                                                ? 'Your Nagad Number (Used for Payment) *'
                                                : (_paymentGateway == 'glowbay_bangla_qr'
                                                    ? 'Sender Phone / Bank Account Number *'
                                                    : 'Deposit Reference / Sender A/C Name *')))
                                        : (_paymentGateway == 'glowbay_bkash'
                                            ? 'Your bKash Number (used to pay) *'
                                            : (_paymentGateway == 'glowbay_nagad'
                                                ? 'Your Nagad Number (used to pay) *'
                                                : (_paymentGateway == 'glowbay_bangla_qr'
                                                    ? 'Your Sender Phone / Bank Account Number *'
                                                    : 'Deposit Reference / Sender Account Name *'))),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936)),
                                  ),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _senderNumberController,
                                    keyboardType: _paymentGateway == 'glowbay_bank' ? TextInputType.text : TextInputType.phone,
                                    decoration: _inputDeco(
                                      _paymentGateway == 'glowbay_bank'
                                          ? 'e.g. Ref #12345 / Sender Name'
                                          : (_paymentGateway == 'glowbay_bangla_qr' ? '01XXXXXXXXX / Bank A/C' : '01XXXXXXXXX'),
                                      _paymentGateway == 'glowbay_bank' ? Icons.person_outline : Icons.phone_android,
                                    ),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required *' : null,
                                  ),
                                  const SizedBox(height: 10),

                                  // ── TrxID Input ──
                                  Text(
                                    isEn
                                        ? (_paymentGateway == 'glowbay_bkash'
                                            ? 'bKash Transaction ID (TrxID) *'
                                            : (_paymentGateway == 'glowbay_nagad'
                                                ? 'Nagad Transaction ID (TrxID) *'
                                                : (_paymentGateway == 'glowbay_bangla_qr'
                                                    ? 'Transaction ID (TrxID) / Reference *'
                                                    : 'Bank Transaction ID / Slip Ref *')))
                                        : (_paymentGateway == 'glowbay_bkash'
                                            ? 'bKash Transaction ID (TrxID) *'
                                            : (_paymentGateway == 'glowbay_nagad'
                                                ? 'Nagad Transaction ID (TrxID) *'
                                                : (_paymentGateway == 'glowbay_bangla_qr'
                                                    ? 'Transaction ID (TrxID) / Reference Number *'
                                                    : 'Bank Transaction ID / Slip Ref *'))),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936)),
                                  ),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _trxIdController,
                                    textCapitalization: TextCapitalization.characters,
                                    decoration: _inputDeco('e.g. BL9A7K8XYZ / REF-12345', Icons.receipt_long),
                                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, letterSpacing: 1.2),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required *' : null,
                                  ),
                                  const SizedBox(height: 12),

                                  // ── PAYMENT RECEIPT SCREENSHOT UPLOAD BOX (Mandatory — matching gb-file-upload-box) ──
                                  Row(
                                    children: [
                                      Icon(Icons.cloud_upload_outlined, size: 14, color: _paymentGateway == 'glowbay_bkash' ? const Color(0xFFFF2D78) : (_paymentGateway == 'glowbay_nagad' ? const Color(0xFFF7941D) : const Color(0xFF15803D))),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Upload Payment Receipt Screenshot (Optional)',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF101936)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: _showImagePickerModal,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: _receiptImage != null ? const Color(0xFF10B981) : const Color(0xFFFFB6C1),
                                          width: 1.5,
                                          strokeAlign: BorderSide.strokeAlignInside,
                                        ),
                                      ),
                                      child: _receiptImage != null
                                          ? Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(6),
                                                  child: Image.file(
                                                    File(_receiptImage!.path),
                                                    width: 44,
                                                    height: 44,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                                                          SizedBox(width: 4),
                                                          Text('Receipt Selected ✓', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                                                        ],
                                                      ),
                                                      Text(
                                                        _receiptImage!.name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () => setState(() {
                                                    _receiptImage = null;
                                                    _receiptBase64 = null;
                                                  }),
                                                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                Icon(
                                                  Icons.add_photo_alternate_outlined,
                                                  size: 28,
                                                  color: _paymentGateway == 'glowbay_bkash'
                                                      ? const Color(0xFFFF2D78)
                                                      : (_paymentGateway == 'glowbay_nagad' ? const Color(0xFFF7941D) : const Color(0xFF15803D)),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Click to select receipt screenshot (JPG, PNG)',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF101936)),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '(Max 5MB)',
                                                  style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // CARD 6: TOTALS BREAKDOWN
                      _buildCard(
                        color: const Color(0xFFFAFCFF),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Section 1: Order Summary ──
                            Row(
                              children: [
                                const Icon(Icons.receipt_long_outlined, size: 16, color: Color(0xFF1E293B)),
                                const SizedBox(width: 6),
                                Text(
                                  'Order Price Details (Order Summary)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildSummaryRow(
                              'Product Subtotal (${activeItems.length} Items)',
                              '৳${itemsSubtotal.toStringAsFixed(0)}',
                            ),
                            const SizedBox(height: 6),
                            _buildSummaryRow(
                              'Delivery Charge (${isInsideDhaka ? 'Dhaka' : 'Outside Dhaka'} • ${totalWeightKg.toStringAsFixed(totalWeightKg.truncateToDouble() == totalWeightKg ? 0 : 1)} kg)',
                              '৳${shippingCost.toStringAsFixed(0)}',
                            ),
                            if (voucherDiscount > 0) ...[
                              const SizedBox(height: 6),
                              _buildSummaryRow(
                                'Voucher Discount',
                                '-৳${voucherDiscount.toStringAsFixed(0)}',
                                isDiscount: true,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Order Value:',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    '৳${totalOrderValue.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                            ),

                            // ── Section 2: Payment Plan Breakdown ──
                            Row(
                              children: [
                                Icon(
                                  _paymentPlan == 'advance_50' ? Icons.pie_chart_outline : Icons.check_circle_outline,
                                  size: 16,
                                  color: const Color(0xFFFF2D78),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _paymentPlan == 'advance_50'
                                      ? ('Payment Breakdown (50% Advance Plan)')
                                      : ('Payment Breakdown (100% Full Payment)'),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFFF2D78),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildSummaryRow(
                              _paymentPlan == 'advance_50' ? ('50% Advance Base Amount') : ('100% Full Pay Base Amount'),
                              '৳${basePayable.toStringAsFixed(0)}',
                            ),
                            const SizedBox(height: 6),
                            if (cashoutFee > 0)
                              _buildSummaryRow(
                                '${_paymentGateway == 'glowbay_bkash' ? 'bKash' : 'Nagad'} Cashout Fee (${cashoutFeePct.toStringAsFixed(2)}%)',
                                '+৳${cashoutFee.toStringAsFixed(0)}',
                              )
                            else if (_paymentGateway == 'glowbay_bangla_qr')
                              _buildSummaryRow(
                                'Bangla QR Cashout Fee (0% Fee)',
                                '৳0 (Free! 🎉)',
                                isDiscount: true,
                              )
                            else if (_paymentGateway == 'glowbay_bank')
                              _buildSummaryRow(
                                'Bank Deposit Charge',
                                '৳0 (Free)',
                                isDiscount: true,
                              ),
                            const SizedBox(height: 10),

                            // HIGHLIGHT BOX: Payable Today
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFFD1E3), width: 1.2),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '👉 Payable Today:',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF881337),
                                        ),
                                      ),
                                      Text(
                                        _paymentPlan == 'advance_50'
                                            ? (isEn
                                                ? (cashoutFee > 0 ? '(50% Advance + Cashout Fee)' : '(50% Advance)')
                                                : (cashoutFee > 0 ? '(50% Adv + Fee)' : '(50% Advance)'))
                                            : (isEn
                                                ? (cashoutFee > 0 ? '(100% Full + Cashout Fee)' : '(100% Full Payment)')
                                                : (cashoutFee > 0 ? '(100% Full + Fee)' : '(100% Full Payment)')),
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF9F1239), fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '৳${totalPayableWithFee.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFE11D48),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // COD / DUE ROW: Due on Delivery
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _paymentPlan == 'advance_50' ? const Color(0xFFF8FAFC) : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _paymentPlan == 'advance_50' ? const Color(0xFFE2E8F0) : const Color(0xFFA7F3D0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _paymentPlan == 'advance_50' ? ('📦 Due on Delivery to Courier:') : ('📦 Due on Delivery:'),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: _paymentPlan == 'advance_50' ? const Color(0xFF334155) : const Color(0xFF065F46),
                                    ),
                                  ),
                                  Text(
                                    _paymentPlan == 'advance_50' ? '৳${due50.toStringAsFixed(0)}' : ('৳0 (Cashless 🎉)'),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      color: _paymentPlan == 'advance_50' ? const Color(0xFF0F172A) : const Color(0xFF059669),
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
                ),
              ),
            ),
          ],
        ),
      ),

      // FIXED BOTTOM STICKY ACTION BAR (Matching web layout)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFEEF0F6))),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101936).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _paymentPlan == 'advance_50'
                      ? (isEn
                          ? (cashoutFee > 0 ? 'Total Payable (50% Advance + Fee):' : 'Total Payable (50% Advance):')
                          : (cashoutFee > 0 ? 'Total Payable (50% Adv + Fee):' : 'Total Payable (50% Advance):'))
                      : (isEn
                          ? (cashoutFee > 0 ? 'Total Payable (100% Full + Fee):' : 'Total Payable (100% Full):')
                          : (cashoutFee > 0 ? 'Total Payable (100% Full + Fee):' : 'Total Payable (100% Full):')),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                ),
                Text(
                  '৳${totalPayableWithFee.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFFF2D78)),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A00), Color(0xFFFF2D68)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF2D68).withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: orderProvider.isCreatingOrder ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: orderProvider.isCreatingOrder
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _paymentPlan == 'advance_50' ? ('Place Order (50% Advance)') : ('Place Order (100% Full Pay)'),
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          const Text('🔒'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Address Switcher & In-place Add Address Modal Sheet
  void _openAddressEditBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFFFF2D78), size: 20),
                          const SizedBox(width: 6),
                          Text('Update Delivery Address', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF101936))),
                        ],
                      ),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const Divider(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDeco('Customer Full Name *', Icons.person_outline),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDeco('Mobile Phone *', Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _whatsappController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDeco('WhatsApp Number *', Icons.chat_outlined),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _buildingController,
                          decoration: _inputDeco('Building / Flat *', Icons.apartment_outlined),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _roadController,
                          decoration: _inputDeco('Road / Block *', Icons.signpost_outlined),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _areaController,
                    decoration: _inputDeco('Area / Landmark * (e.g. Dhanmondi / Mirpur)', Icons.explore_outlined),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDivision,
                    decoration: _inputDeco('Division *', Icons.map_outlined),
                    items: BangladeshRegions.divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _selectedDivision = val!;
                        _selectedDistrict = BangladeshRegions.districtsByDivision[_selectedDivision]?.first ?? '';
                        _selectedUpazila = BangladeshRegions.upazilasByDistrict[_selectedDistrict]?.first ?? '';
                      });
                      setState(() {
                        context.read<CartProvider>().setShippingLocation(_selectedDistrict.toLowerCase() == 'dhaka');
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedDistrict,
                          decoration: _inputDeco('District *', Icons.location_city_outlined),
                          items: (BangladeshRegions.districtsByDivision[_selectedDivision] ?? ['Dhaka'])
                              .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12.5))))
                              .toList(),
                          onChanged: (val) {
                            setModalState(() {
                              _selectedDistrict = val!;
                              _selectedUpazila = BangladeshRegions.upazilasByDistrict[_selectedDistrict]?.first ?? '';
                            });
                            setState(() {
                              context.read<CartProvider>().setShippingLocation(_selectedDistrict.toLowerCase() == 'dhaka');
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: _selectedUpazila,
                          decoration: _inputDeco('Thana / Upazila *', Icons.place_outlined),
                          onChanged: (val) => _selectedUpazila = val.trim(),
                        ),
                      ),
                    ],
                  ),
                  if (BangladeshRegions.upazilasByDistrict[_selectedDistrict] != null &&
                      BangladeshRegions.upazilasByDistrict[_selectedDistrict]!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: BangladeshRegions.upazilasByDistrict[_selectedDistrict]!.map((upazila) {
                          final isSel = _selectedUpazila == upazila;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text(upazila, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w800 : FontWeight.w500, color: isSel ? const Color(0xFFFF2D78) : const Color(0xFF334155))),
                              backgroundColor: isSel ? const Color(0xFFFFF0F5) : const Color(0xFFF1F5F9),
                              side: BorderSide(color: isSel ? const Color(0xFFFF2D78) : Colors.transparent),
                              onPressed: () {
                                setModalState(() => _selectedUpazila = upazila);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _postcodeController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco('Postcode * (e.g. 1216)', Icons.markunread_mailbox_outlined),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildModalAddressTypeBtn('home', '🏠 Home', setModalState),
                      const SizedBox(width: 8),
                      _buildModalAddressTypeBtn('office', '🏢 Office', setModalState),
                      const SizedBox(width: 8),
                      _buildModalAddressTypeBtn('other', '📍 Other', setModalState),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF2D78),
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Save & Use Address', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModalAddressTypeBtn(String typeKey, String label, StateSetter setModalState) {
    final isSelected = _addressType == typeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setModalState(() => _addressType = typeKey);
          setState(() => _addressType = typeKey);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF0F5) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF2D78) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? const Color(0xFFFF2D78) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, Color color = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101936).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardHeader({
    required IconData icon,
    required String title,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFFFF2D78)),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF101936), letterSpacing: 0.3),
            ),
          ],
        ),
        if (actionText != null && onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Row(
              children: [
                const Icon(Icons.edit, size: 12, color: Color(0xFFFF2D78)),
                const SizedBox(width: 3),
                Text(actionText, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFFF2D78))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPayGatewayBtn(
    String key,
    String title,
    String subtitle,
    Color color,
    IconData icon, {
    String? badgeText,
    Color? badgeColor,
  }) {
    final isSelected = _paymentGateway == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentGateway = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badgeText != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: (badgeColor ?? color).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: badgeColor ?? color,
                    ),
                  ),
                ),
              ],
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? color : const Color(0xFF101936),
                  ),
                ),
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 8.5, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayStep(String stepNum, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(stepNum, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155), height: 1.3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: isDiscount ? const Color(0xFF10B981) : const Color(0xFF101936))),
      ],
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, color: const Color(0xFFFF2D78), size: 16),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF2D78), width: 1.5)),
    );
  }
}
