import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/api_service.dart';

class RequestProductScreen extends StatefulWidget {
  const RequestProductScreen({super.key});

  @override
  State<RequestProductScreen> createState() => _RequestProductScreenState();
}

class _RequestProductScreenState extends State<RequestProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prodNameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _prodNameCtrl.dispose();
    _brandCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final api = ApiService();
    final res = await api.submitProductRequest(
      _prodNameCtrl.text.trim(),
      _brandCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      _notesCtrl.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.authenticGreen, size: 24),
              SizedBox(width: 8),
              Text('Request Received!'),
            ],
          ),
          content: Text(res['message'] ?? 'We will source it from Kuala Lumpur for you.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Request Malaysian Sourcing', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 22, color: Color(0xFF0F172A)),
            tooltip: 'Home',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.infoBlueBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.infoBlue.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.travel_explore_rounded, color: AppColors.infoBlue, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Looking for a specific cosmetic or health supplement from Malaysia? Tell us and our KL team will source it for you!',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF1E3A8A), height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInput('Product Name *', _prodNameCtrl, 'e.g. CeraVe SA Cleanser 473ml'),
              const SizedBox(height: 12),
              _buildInput('Brand Name', _brandCtrl, 'e.g. CeraVe / Blackmores'),
              const SizedBox(height: 12),
              _buildInput('Your WhatsApp / Mobile Number *', _phoneCtrl, 'e.g. 01712345678', keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildInput('Additional Notes / Specific Size', _notesCtrl, 'e.g. 500ml bottle or 2 packs', maxLines: 3),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SUBMIT SOURCING REQUEST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, String hint, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: (v) => (label.contains('*') && (v == null || v.trim().isEmpty)) ? 'Required field' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderSubtle)),
          ),
        ),
      ],
    );
  }
}
