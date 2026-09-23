import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_service.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/language_provider.dart';
import '../product_detail/product_detail_screen.dart';
import 'order_tracking_screen.dart';

class QrScannerScreen extends StatefulWidget {
  final bool returnCodeOnScan;
  final bool initialStaffMode;
  final String? initialStaffAction;
  const QrScannerScreen({
    super.key,
    this.returnCodeOnScan = false,
    this.initialStaffMode = false,
    this.initialStaffAction,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _animationController;

  final TextEditingController _manualInputCtrl = TextEditingController();
  bool _isProcessing = false;
  bool _isTorchOn = false;
  double _currentZoom = 1.0;
  String _scanStatusText = 'Align barcode inside frame';
  late String _currentMode; // 'lookup', 'dispatch_kl_to_dhaka', 'arrive_dhaka'

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.noDuplicates,
      detectionTimeoutMs: 1200,
      formats: const [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.qrCode,
        BarcodeFormat.dataMatrix,
      ],
      autoStart: true,
    );

    _currentMode = widget.initialStaffAction ?? (widget.initialStaffMode ? 'dispatch_kl_to_dhaka' : 'lookup');

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    _manualInputCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final Barcode barcode = barcodes.first;
    final String? rawValue = barcode.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    final String normalizedCode = rawValue.trim().replaceAll(' ', '');
    final String barcodeFormatName = barcode.format.name.toUpperCase();

    if (widget.returnCodeOnScan) {
      Navigator.pop(context, normalizedCode);
      return;
    }

    // Branch 1: Staff Logistics Scanner (KL Hub Dispatch or Dhaka Hub Arrive)
    if (_currentMode == 'dispatch_kl_to_dhaka' || _currentMode == 'arrive_dhaka') {
      HapticFeedback.heavyImpact();
      final isEn = context.read<LanguageProvider>().isEnglish;
      setState(() {
        _isProcessing = true;
        _scanStatusText = isEn
            ? 'Staff scan processing ($normalizedCode)...'
            : 'স্টাফ স্ক্যান প্রসেসিং হচ্ছে ($normalizedCode)...';
      });
      await _scannerController.stop();
      await _performStaffHubScan(normalizedCode, action: _currentMode);
      return;
    }

    // Branch 2: Customer / Catalog Barcode Product Lookup
    setState(() {
      _isProcessing = true;
      _scanStatusText = 'Analyzing barcode $normalizedCode...';
    });

    // Pause camera stream during network lookup
    await _scannerController.stop();

    await _performProductLookup(normalizedCode, format: barcodeFormatName);
  }

  Future<void> _performStaffHubScan(String code, {required String action}) async {
    final result = await ApiService().scanStaffBarcode(
      barcode: code,
      action: action,
    );
    if (!mounted) return;

    final isEn = context.read<LanguageProvider>().isEnglish;
    final isSuccess = result['success'] == true;
    final isKl = action == 'dispatch_kl_to_dhaka';
    final confirmationTitle = isKl
        ? (isEn ? 'Dispatched from Kuala Lumpur' : 'কুয়ালালামপুর থেকে পাঠানো হয়েছে')
        : (isEn ? 'Received at Dhaka Hub' : 'ঢাকা হাবে রিসিভ করা হয়েছে');
    final serverMsg = result['message'] ?? '';

    HapticFeedback.mediumImpact();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSuccess ? const Color(0xFFD1FAE5) : const Color(0xFFFFE4E6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                    color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFFF2D78),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSuccess ? confirmationTitle : (isEn ? 'Scan Error' : 'স্ক্যান এরর'),
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isSuccess ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                        ),
                      ),
                      Text(
                        isEn ? 'Barcode / Consignment: $code' : 'বারকোড / কনসাইনমেন্ট: $code',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              serverMsg.isNotEmpty
                  ? serverMsg
                  : (isKl
                      ? (isEn
                          ? 'In transit from Kuala Lumpur to Dhaka (arriving in 2-4 days).'
                          : 'কুয়ালালামপুর থেকে ঢাকায় পাঠানো হচ্ছে (২–৪ দিনের মধ্যে ঢাকায় পৌঁছাবে)।')
                      : (isEn
                          ? 'Product arrived at Dhaka Hub, courier pickup preparation in progress.'
                          : 'প্রোডাক্ট ঢাকা হাবে এসে পৌঁছেছে, কুরিয়ার পিকআপের প্রস্তুতি চলছে।')),
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                height: 1.45,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18, color: Colors.white),
                label: Text(
                  isEn ? 'Scan Next Parcel' : 'পরবর্তী পার্সেল স্ক্যান করুন',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? const Color(0xFF10B981) : const Color(0xFFFF2D78),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Resume camera scanning after modal closes
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _scanStatusText = 'Align barcode inside frame';
      });
      await _scannerController.start();
    }
  }

  Future<void> _performProductLookup(String code, {String format = 'BARCODE'}) async {
    final startTime = DateTime.now();

    // 1. Query exact barcode from WooCommerce API
    final ProductModel? product = await ApiService().lookupProductByBarcode(code);
    final lookupElapsedMs = DateTime.now().difference(startTime).inMilliseconds;

    if (!mounted) return;

    if (product != null) {
      // EXACT PRODUCT MATCH FOUND
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.authenticGreen, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exact Product Matched',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '$format: $code (${lookupElapsedMs}ms)',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.image.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.image,
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 75,
                          height: 75,
                          color: AppColors.borderSubtle,
                          child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        if (product.brands.isNotEmpty)
                          Text(
                            'Brand: ${product.brands.first}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        if (product.sku.isNotEmpty)
                          Text(
                            'SKU: ${product.sku}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          productId: product.id,
                          initialProduct: product,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'VIEW PRODUCT DETAILS',
                    style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('SCAN ANOTHER PRODUCT', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Check if this scanned barcode/QR code is an Order / Parcel ID or Tracking Code
      String detectedOrderId = '';
      if (code.contains('order_id=')) {
        final match = RegExp(r'order_id=([0-9]+)').firstMatch(code);
        if (match != null) detectedOrderId = match.group(1)!;
      } else if (code.contains('steadfast.com.bd/t/')) {
        final parts = code.split('/t/');
        if (parts.length > 1) detectedOrderId = parts[1].split('?').first.trim();
      } else if (RegExp(r'^(?:GB|ORD)?-?([0-9]{4,8})$', caseSensitive: false).hasMatch(code)) {
        final match = RegExp(r'^(?:GB|ORD)?-?([0-9]{4,8})$', caseSensitive: false).firstMatch(code);
        if (match != null) detectedOrderId = match.group(1)!;
      }

      if (detectedOrderId.isNotEmpty) {
        // ORDER / TRACKING MATCH FOUND
        final isEn = context.read<LanguageProvider>().isEnglish;
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          isDismissible: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF16A34A), size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'Order / Parcel Code Detected' : 'অর্ডার বা পার্সেল কোড শনাক্ত হয়েছে',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Order ID / Tracking # $detectedOrderId',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF16A34A), fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  isEn
                      ? 'The scanned code is recognized as a GlowBayBD parcel or pre-order tracking number. Would you like to view its live tracking status?'
                      : 'স্ক্যান করা কোডটি একটি GlowBayBD পার্সেল বা প্রি-অর্ডার ট্র্যাকিং নম্বর হিসেবে শনাক্ত হয়েছে। আপনি কি এই অর্ডারের লাইভ ট্র্যাকিং স্ট্যাটাস দেখতে চান?',
                  style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingScreen(initialOrderId: detectedOrderId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.track_changes_rounded, color: Colors.white, size: 18),
                    label: Text(
                      isEn ? 'View Live Tracking (Track Order)' : 'লাইভ ট্র্যাকিং দেখুন (Track Order)',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('SCAN ANOTHER CODE', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // PRODUCT NOT FOUND MODAL (Strict Exact Match Rule - No Fake Results)
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          isDismissible: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Not Found',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Scanned $format: $code',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'This barcode was scanned successfully ($code), but is not currently indexed or available in the GlowBay BD catalog.',
                  style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'SCAN AGAIN',
                      style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // Resume camera scanning after modal closes
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _scanStatusText = 'Align barcode inside frame';
      });
      await _scannerController.start();
    }
  }

  void _setZoom(double zoom) async {
    setState(() => _currentZoom = zoom);
    await _scannerController.setZoomScale(zoom);
  }

  Widget _buildModeTab(String modeKey, String label, IconData icon) {
    final isSelected = _currentMode == modeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_currentMode == modeKey) return;
          HapticFeedback.selectionClick();
          final isEn = context.read<LanguageProvider>().isEnglish;
          setState(() {
            _currentMode = modeKey;
            _scanStatusText = modeKey == 'lookup'
                ? (isEn ? 'Align barcode inside frame' : 'ফ্রেমের ভেতর বারকোড রাখুন')
                : (modeKey == 'dispatch_kl_to_dhaka'
                    ? (isEn ? 'Scan KL packing slip barcode' : 'কেএল প্যাকিং স্লিপ বারকোড স্ক্যান করুন')
                    : (isEn ? 'Scan Dhaka parcel barcode' : 'ঢাকা পার্সেল বারকোড স্ক্যান করুন'));
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF2D78) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: isSelected ? Colors.white : Colors.white70),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isEn = context.watch<LanguageProvider>().isEnglish;
    final isStaff = (auth.currentUser?.isStaff == true) || widget.initialStaffMode;

    String screenTitle = isEn ? 'Product Barcode Scanner' : 'পণ্য বারকোড স্ক্যানার';
    if (_currentMode == 'dispatch_kl_to_dhaka') {
      screenTitle = isEn ? '🇲🇾 KL Hub Dispatch Scanner' : '🇲🇾 কেএল হাব ডিসপ্যাচ স্ক্যানার';
    } else if (_currentMode == 'arrive_dhaka') {
      screenTitle = isEn ? '🇧🇩 Dhaka Hub Receive Scanner' : '🇧🇩 ঢাকা হাব রিসিভ স্ক্যানার';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        foregroundColor: Colors.white,
        title: Text(
          screenTitle,
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
            tooltip: 'Toggle Torch',
            onPressed: () async {
              await _scannerController.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            tooltip: 'Switch Camera',
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Live CameraX Barcode Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 54, color: Colors.white54),
                      const SizedBox(height: 16),
                      Text(
                        'Camera Permission Required',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please allow camera access in device settings to scan product barcodes.\n(${error.errorCode.name})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Clear Viewfinder Framing with Corner Reticles & Laser
          Center(
            child: SizedBox(
              width: 270,
              height: 270,
              child: Stack(
                children: [
                  // Corner brackets
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.authenticGreen, width: 4),
                          left: BorderSide(color: AppColors.authenticGreen, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.authenticGreen, width: 4),
                          right: BorderSide(color: AppColors.authenticGreen, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.authenticGreen, width: 4),
                          left: BorderSide(color: AppColors.authenticGreen, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.authenticGreen, width: 4),
                          right: BorderSide(color: AppColors.authenticGreen, width: 4),
                        ),
                      ),
                    ),
                  ),

                  // Animated Scanning Laser Bar
                  if (!_isProcessing)
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Positioned(
                          top: 10 + (_animationController.value * 240),
                          left: 10,
                          right: 10,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.authenticGreen.withValues(alpha: 0.1),
                                  AppColors.authenticGreen,
                                  AppColors.authenticGreen.withValues(alpha: 0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.authenticGreen.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  if (_isProcessing)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.authenticGreen),
                    ),
                ],
              ),
            ),
          ),

          // 2.5 Staff Hub Mode Selector (Visible to Staff & Hub Managers)
          if (isStaff)
            Positioned(
              top: 12,
              left: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF101936).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildModeTab('lookup', isEn ? 'Lookup' : 'পণ্য সার্চ', Icons.search_rounded),
                    _buildModeTab('dispatch_kl_to_dhaka', isEn ? '🇲🇾 KL Hub' : '🇲🇾 কেএল হাব', Icons.flight_takeoff_rounded),
                    _buildModeTab('arrive_dhaka', isEn ? '🇧🇩 Dhaka Hub' : '🇧🇩 ঢাকা হাব', Icons.warehouse_rounded),
                  ],
                ),
              ),
            ),

          // 3. Status Badge & Distance Guidance
          Positioned(
            top: isStaff ? 74 : 20,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isProcessing ? Icons.sync : Icons.qr_code_scanner,
                      color: _isProcessing ? AppColors.accentPink : AppColors.authenticGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _scanStatusText,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Zoom Controls (1x, 2x, 3x)
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildZoomButton(1.0, '1x'),
                    const SizedBox(width: 8),
                    _buildZoomButton(2.0, '2x'),
                    const SizedBox(width: 8),
                    _buildZoomButton(3.0, '3x'),
                  ],
                ),
              ),
            ),
          ),

          // 5. Manual Barcode Entry Bar
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualInputCtrl,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Or enter barcode / SKU...',
                        hintStyle: TextStyle(color: Colors.white54, fontSize: 11.5),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          _onManualSubmit(val.trim());
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final val = _manualInputCtrl.text.trim();
                      if (val.isNotEmpty) {
                        _onManualSubmit(val);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('SEARCH', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton(double zoom, String label) {
    final isSelected = (_currentZoom - zoom).abs() < 0.1;
    return GestureDetector(
      onTap: () => _setZoom(zoom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _onManualSubmit(String code) async {
    if (widget.returnCodeOnScan) {
      Navigator.pop(context, code);
      return;
    }
    setState(() {
      _isProcessing = true;
      _scanStatusText = 'Looking up $code...';
    });
    await _scannerController.stop();
    await _performProductLookup(code, format: 'MANUAL');
  }
}
