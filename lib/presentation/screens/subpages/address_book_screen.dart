import '../../../logic/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/local_storage_service.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  final List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    final list = await LocalStorageService().getAddressesRaw();
    if (list.isNotEmpty) {
      if (mounted) {
        setState(() {
          _addresses.clear();
          _addresses.addAll(list);
          _isLoading = false;
        });
      }
    } else {
      // Default initial address
      final defaultAddr = [
        {
          'id': '1',
          'full_name': 'Akher Hossain',
          'phone': '01722429259',
          'whatsapp_phone': '01722429259',
          'building_name': 'Flat 4A',
          'road_number': 'Road 4, Sector 7',
          'area': 'Uttara',
          'thana': 'Uttara',
          'district_name': 'Dhaka',
          'postcode': '1230',
          'address_type': 'home',
          'is_default': true,
          'delivery_instruction': 'কল দিয়ে আসবেন',
        },
      ];
      await LocalStorageService().saveAddressesRaw(defaultAddr);
      if (mounted) {
        setState(() {
          _addresses.clear();
          _addresses.addAll(defaultAddr);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _persistAddresses() async {
    await LocalStorageService().saveAddressesRaw(_addresses);
  }

  void _confirmDeleteAddress(Map<String, dynamic> addr) {
    final isEn = context.read<LanguageProvider>().isEnglish;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            Text(isEn ? 'Delete Address?' : 'ঠিকানা মুছে ফেলবেন?', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Text(isEn
            ? 'Are you sure you want to permanently delete this delivery address for "${addr['full_name']}"?'
            : 'আপনি কি নিশ্চিত যে "${addr['full_name']}"-এর এই ডেলিভারি ঠিকানাটি স্থায়ীভাবে মুছে ফেলতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'Cancel' : 'বাতিল', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _addresses.removeWhere((a) => a['id'] == addr['id']);
                if (_addresses.isNotEmpty && addr['is_default'] == true) {
                  _addresses.first['is_default'] = true;
                }
              });
              await _persistAddresses();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEn ? '✓ Delivery address deleted successfully!' : '✓ ডেলিভারি ঠিকানা সফলভাবে মুছে ফেলা হয়েছে!'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isEn ? 'Delete' : 'মুছে ফেলুন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _openAddAddressModal([Map<String, dynamic>? editItem]) {
    final isEn = context.read<LanguageProvider>().isEnglish;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: editItem?['full_name'] ?? '');
    final phoneCtrl = TextEditingController(text: editItem?['phone'] ?? '');
    final waCtrl = TextEditingController(text: editItem?['whatsapp_phone'] ?? '');
    final bldCtrl = TextEditingController(text: editItem?['building_name'] ?? '');
    final roadCtrl = TextEditingController(text: editItem?['road_number'] ?? '');
    final areaCtrl = TextEditingController(text: editItem?['area'] ?? '');
    final thanaCtrl = TextEditingController(text: editItem?['thana'] ?? '');
    final distCtrl = TextEditingController(text: editItem?['district_name'] ?? 'Dhaka');
    final postCtrl = TextEditingController(text: editItem?['postcode'] ?? '1216');
    final instCtrl = TextEditingController(text: editItem?['delivery_instruction'] ?? '');
    String addrType = editItem?['address_type'] ?? 'home';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 16,
            right: 16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            editItem == null ? (isEn ? 'Add New Delivery Address' : 'নতুন ডেলিভারি ঠিকানা যোগ করুন') : (isEn ? 'Edit Delivery Address' : 'ঠিকানা পরিবর্তন করুন'),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 16),

                  // Full Name *
                  _buildInputLabel(isEn ? 'Customer Full Name *' : 'গ্রাহকের পূর্ণ নাম (Full Name) *'),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: _inputDeco(isEn ? 'Enter full name' : 'আপনার পূর্ণ নাম লিখুন', Icons.person_outline),
                    validator: (v) => (v == null || v.trim().isEmpty) ? (isEn ? 'Full name is required *' : 'পূর্ণ নাম বাধ্যতামূলক *') : null,
                  ),
                  const SizedBox(height: 10),

                  // Phone & WhatsApp *
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel(isEn ? 'Active Mobile Number *' : 'সচল মোবাইল নম্বর *'),
                            TextFormField(
                              controller: phoneCtrl,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                              decoration: _inputDeco('01XXXXXXXXX', Icons.phone_outlined),
                              validator: (v) => (v == null || v.trim().length < 11) ? (isEn ? '11 digits required *' : '১১ ডিজিট বাধ্যতামূলক *') : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel(isEn ? 'WhatsApp Number *' : 'হোয়াটসঅ্যাপ নম্বর *'),
                            TextFormField(
                              controller: waCtrl,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                              decoration: _inputDeco('01XXXXXXXXX', Icons.chat_outlined),
                              validator: (v) => (v == null || v.trim().length < 11) ? (isEn ? '11 digits required *' : '১১ ডিজিট বাধ্যতামূলক *') : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Building & Road *
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel(isEn ? 'Building / Flat No. *' : 'বিল্ডিং / ফ্ল্যাট নম্বর *'),
                            TextFormField(
                              controller: bldCtrl,
                              decoration: _inputDeco('e.g. Flat 4A / Floor 3', Icons.apartment_outlined),
                              validator: (v) => (v == null || v.trim().isEmpty) ? (isEn ? 'Building required *' : 'বিল্ডিং বাধ্যতামূলক *') : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel(isEn ? 'Road / Block / Sector *' : 'রোড / ব্লক / সেক্টর *'),
                            TextFormField(
                              controller: roadCtrl,
                              decoration: _inputDeco('e.g. Road 5, Block C', Icons.signpost_outlined),
                              validator: (v) => (v == null || v.trim().isEmpty) ? (isEn ? 'Road required *' : 'রোড বাধ্যতামূলক *') : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Area & Thana / Upazila *
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel(isEn ? 'Area / Neighborhood *' : 'এলাকা / মহল্লা *'),
                            TextFormField(
                              controller: areaCtrl,
                              decoration: _inputDeco('e.g. Sector 7 / Mirpur-10', Icons.explore_outlined),
                              validator: (v) => (v == null || v.trim().isEmpty) ? (isEn ? 'Area required *' : 'এলাকা বাধ্যতামূলক *') : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel(isEn ? 'Thana / Upazila *' : 'থানা / উপজেলা (Thana) *'),
                            TextFormField(
                              controller: thanaCtrl,
                              decoration: _inputDeco(isEn ? 'e.g. Uttara / Sadar / Gulshan' : 'e.g. Uttara / সদর / গুলশান', Icons.place_outlined),
                              validator: (v) => (v == null || v.trim().isEmpty) ? (isEn ? 'Thana required *' : 'থানা বাধ্যতামূলক *') : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // District & Postcode *
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel(isEn ? 'District *' : 'জেলা (District) *'),
                            TextFormField(
                              controller: distCtrl,
                              decoration: _inputDeco('e.g. Dhaka / Bogura / Sylhet', Icons.location_city_outlined),
                              validator: (v) => (v == null || v.trim().isEmpty) ? (isEn ? 'District required *' : 'জেলা বাধ্যতামূলক *') : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel(isEn ? 'Postal Code *' : 'পোস্টাল কোড *'),
                            TextFormField(
                              controller: postCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                              decoration: _inputDeco('e.g. 1230', Icons.markunread_mailbox_outlined),
                              validator: (v) => (v == null || v.trim().isEmpty) ? (isEn ? 'Postcode required *' : 'পোস্টকোড বাধ্যতামূলক *') : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Address Type *
                  _buildInputLabel(isEn ? 'Address Type *' : 'ঠিকানার ধরণ *'),
                  Row(
                    children: [
                      _buildModalTypeBtn('home', '🏠 Home', addrType, (val) => setModalState(() => addrType = val)),
                      const SizedBox(width: 8),
                      _buildModalTypeBtn('office', '🏢 Office', addrType, (val) => setModalState(() => addrType = val)),
                      const SizedBox(width: 8),
                      _buildModalTypeBtn('other', '📍 Other', addrType, (val) => setModalState(() => addrType = val)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Courier Note
                  _buildInputLabel(isEn ? 'Delivery Instructions (Optional)' : 'ডেলিভারি নির্দেশনা (ঐচ্ছিক)'),
                  TextFormField(
                    controller: instCtrl,
                    decoration: _inputDeco(isEn ? 'Special note e.g. Call before delivery' : 'জরুরি নির্দেশনা যেমন: কল দিয়ে আসবেন', Icons.note_outlined),
                  ),
                  const SizedBox(height: 18),

                  // Save Button
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final isFirstAddr = _addresses.isEmpty;
                      final newAddr = {
                        'id': editItem?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        'full_name': nameCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'whatsapp_phone': waCtrl.text.trim(),
                        'building_name': bldCtrl.text.trim(),
                        'road_number': roadCtrl.text.trim(),
                        'area': areaCtrl.text.trim(),
                        'thana': thanaCtrl.text.trim(),
                        'district_name': distCtrl.text.trim(),
                        'postcode': postCtrl.text.trim(),
                        'address_type': addrType,
                        'delivery_instruction': instCtrl.text.trim(),
                        'is_default': editItem?['is_default'] ?? isFirstAddr,
                      };

                      setState(() {
                        if (editItem != null) {
                          final idx = _addresses.indexWhere((a) => a['id'] == editItem['id']);
                          if (idx != -1) _addresses[idx] = newAddr;
                        } else {
                          _addresses.add(newAddr);
                        }
                      });

                      await _persistAddresses();
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEn ? '✓ Delivery address saved successfully!' : '✓ ডেলিভারি ঠিকানা সফলভাবে সংরক্ষণ করা হয়েছে!'),
                            backgroundColor: AppColors.authenticGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isEn ? 'Save & Confirm Address' : 'ঠিকানা সংরক্ষণ ও নিশ্চিত করুন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
    );
  }

  Widget _buildModalTypeBtn(String key, String label, String current, Function(String) onSelect) {
    final isSelected = key == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF0F5) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.accentPink : AppColors.borderSubtle,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.accentPink : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 16),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderSubtle)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderSubtle)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.watch<LanguageProvider>().isEnglish;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEn ? 'Saved Address Book' : 'সংরক্ষিত ঠিকানা', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
            tooltip: isEn ? 'Home' : 'হোম পেজ',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _openAddAddressModal(),
            tooltip: isEn ? 'New Address' : 'নতুন ঠিকানা',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _addresses.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_off_outlined, color: AppColors.primary, size: 48),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isEn ? 'No Saved Addresses' : 'কোনো সংরক্ষিত ঠিকানা নেই',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEn ? 'Tap below to add a new delivery address' : 'নতুন ডেলিভারি ঠিকানা যোগ করতে নিচের বাটনে চাপুন',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _openAddAddressModal(),
                          icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white, size: 18),
                          label: Text(isEn ? 'Add Address' : 'ঠিকানা যোগ করুন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ..._addresses.map((addr) {
                      final typeStr = addr['address_type'] == 'office' ? '🏢 Office' : (addr['address_type'] == 'other' ? '📍 Other' : '🏠 Home');
                      final thanaPart = (addr['thana'] != null && addr['thana'].toString().isNotEmpty)
                          ? (isEn ? 'Thana: ${addr['thana']}, ' : 'থানা: ${addr['thana']}, ')
                          : '';
                      final fullText = '${addr['building_name']}, ${addr['road_number']}, ${addr['area']}, $thanaPart${addr['district_name']} - ${addr['postcode']}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: addr['is_default'] == true ? AppColors.accentPink : AppColors.borderSubtle,
                            width: addr['is_default'] == true ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
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
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(typeStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1E40AF))),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(addr['full_name'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                  ],
                                ),
                                if (addr['is_default'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.authenticGreen.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('DEFAULT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.authenticGreen)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(addr['phone'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                                if (addr['whatsapp_phone'] != null && addr['whatsapp_phone'].toString().isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  const Icon(Icons.chat_outlined, size: 14, color: Color(0xFF25D366)),
                                  const SizedBox(width: 4),
                                  Text(addr['whatsapp_phone'], style: const TextStyle(fontSize: 12, color: Color(0xFF065F46), fontWeight: FontWeight.w700)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(fullText, style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.4)),
                            if (addr['delivery_instruction'] != null && addr['delivery_instruction'].toString().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Note: ${addr['delivery_instruction']}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                            ],
                            const Divider(height: 18),
                            Row(
                              children: [
                                // Delete button
                                TextButton.icon(
                                  onPressed: () => _confirmDeleteAddress(addr),
                                  icon: const Icon(Icons.delete_outline, size: 15, color: AppColors.error),
                                  label: Text(isEn ? 'Delete' : 'মুছে ফেলুন', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.error)),
                                ),
                                const Spacer(),
                                // Edit button
                                TextButton.icon(
                                  onPressed: () => _openAddAddressModal(addr),
                                  icon: const Icon(Icons.edit_outlined, size: 14),
                                  label: Text(isEn ? 'Edit' : 'এডিট', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                                ),
                                const SizedBox(width: 6),
                                // Set default button
                                TextButton.icon(
                                  onPressed: () async {
                                    setState(() {
                                      for (var a in _addresses) {
                                        a['is_default'] = (a['id'] == addr['id']);
                                      }
                                    });
                                    await _persistAddresses();
                                  },
                                  icon: Icon(addr['is_default'] == true ? Icons.check_circle : Icons.radio_button_unchecked, size: 14),
                                  label: Text(addr['is_default'] == true ? (isEn ? 'Default' : 'ডিফল্ট') : (isEn ? 'Set Default' : 'ডিফল্ট করুন'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                  style: TextButton.styleFrom(foregroundColor: addr['is_default'] == true ? AppColors.authenticGreen : AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => _openAddAddressModal(),
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: Text(isEn ? '+ Add New Delivery Address' : '+ নতুন ডেলিভারি ঠিকানা যোগ করুন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
    );
  }
}
