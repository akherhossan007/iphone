import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/launcher_helper.dart';
import '../../../data/services/api_service.dart';
import '../../../logic/language_provider.dart';
import '../product_detail/product_detail_screen.dart';

class VisualSearchScreen extends StatefulWidget {
  final ImageSource? initialSource;
  const VisualSearchScreen({super.key, this.initialSource});

  @override
  State<VisualSearchScreen> createState() => _VisualSearchScreenState();
}

class _VisualSearchScreenState extends State<VisualSearchScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _api = ApiService();
  final TextEditingController _searchCtrl = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  String _activeKeyword = 'CeraVe';
  List<dynamic> _products = [];

  final List<String> _quickPills = [
    'CeraVe',
    'Anua',
    'COSRX',
    'Cetaphil',
    'Torriden',
    'The Ordinary',
    'Fino',
    'Sunplay',
    'Bioderma',
    'Simple',
    'Sunscreen',
    'Cleanser',
    'Serum',
    'Moisturizer',
    'Toner',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImage(widget.initialSource!);
      });
    } else {
      _performSearch(_activeKeyword);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1400,
        maxHeight: 1400,
        imageQuality: 88,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
        });
        await _performSearch(_activeKeyword);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _performSearch(String term) async {
    final clean = term.trim();
    if (clean.isEmpty) return;

    setState(() {
      _isLoading = true;
      _activeKeyword = clean;
    });

    final res = await _api.smartSearch(clean);
    final prods = res['products'] as List? ?? [];

    if (mounted) {
      setState(() {
        _products = prods;
        _isLoading = false;
      });
    }
  }

  void _openProduct(int id) {
    if (id > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.watch<LanguageProvider>().isEnglish;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEn ? 'Visual Skincare Search' : 'ভিজুয়াল স্কিনকেয়ার সার্চ',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_outlined, color: AppColors.primary),
            tooltip: isEn ? 'Change Photo' : 'ছবি পরিবর্তন করুন',
            onPressed: () => _showSourceSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Top Hero / Photo Preview Card
          _buildHeroHeader(isEn),

          // 1.5. AI Skin Consultant Smart Integration Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: InkWell(
              onTap: () => LauncherHelper.openAiSkinConsultant(context: context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF1F2), Color(0xFFFDF2F8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFECDD3), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF2A6D), Color(0xFFFF7A00)],
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isEn ? 'AI Skincare Analysis Studio' : 'এআই স্কিন অ্যানালাইসিস স্টুডিও',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF2A6D),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('AI NEW', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEn ? 'Want custom routine & skin diagnosis? Tap here' : 'কাস্টম রুটিন ও ত্বকের নির্ভুল বিশ্লেষণ চান? ট্যাপ করুন',
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFFF2A6D)),
                  ],
                ),
              ),
            ),
          ),

          // 2. Search Input Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: isEn ? 'Filter by bottle or packaging name...' : 'বোতল বা বক্সের নাম দিয়ে ফিল্টার করুন...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    _performSearch(val);
                  }
                },
              ),
            ),
          ),

          // 3. Quick Brand & Category Filter Pills
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickPills.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final pill = _quickPills[index];
                final isSelected = pill.toLowerCase() == _activeKeyword.toLowerCase();
                return GestureDetector(
                  onTap: () {
                    _searchCtrl.text = pill;
                    _performSearch(pill);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF2374) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFF2374) : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF2374).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      pill,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 4. Products Result Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Text(
                      'Matching Authentic Cosmetics (${_products.length})',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Keyword: $_activeKeyword',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // 5. Products List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFFF2374)),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Searching authentic store products...',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                        ),
                      ],
                    ),
                  )
                : _products.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shopping_bag_outlined, size: 48, color: Color(0xFFCBD5E1)),
                              const SizedBox(height: 12),
                              Text(
                                isEn ? 'No direct products found matching "$_activeKeyword"' : '"$_activeKeyword" এর সাথে কোনো প্রোডাক্ট সরাসরি পাওয়া যায়নি',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isEn ? 'Try tapping other brand chips above' : 'উপরের অন্যান্য ব্র্যান্ড চিপসে ট্যাপ করে ট্রাই করুন',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _products.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final p = _products[index];
                          final id = p['id'] is int ? p['id'] as int : int.tryParse(p['id']?.toString() ?? '0') ?? 0;
                          final title = p['title']?.toString() ?? p['name']?.toString() ?? 'GlowBay Authentic Skincare';
                          final image = p['image']?.toString() ?? '';
                          final price = p['price']?.toString() ?? '0';

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _openProduct(id),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x06000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      color: const Color(0xFFF8FAFC),
                                      child: image.isNotEmpty
                                          ? Image.network(
                                              image,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => const Icon(Icons.broken_image, color: Color(0xFFCBD5E1)),
                                            )
                                          : const Icon(Icons.shopping_bag_outlined, color: Color(0xFFCBD5E1)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '৳$price',
                                              style: const TextStyle(
                                                color: Color(0xFFFF2374),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFECFDF5),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: const Color(0xFFA7F3D0)),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.verified, size: 10, color: Color(0xFF059669)),
                                                  SizedBox(width: 2),
                                                  Text('100% Authentic', style: TextStyle(fontSize: 9.5, color: Color(0xFF047857), fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => _openProduct(id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF2374),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('VIEW', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(bool isEn) {
    if (_selectedImage != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECDD3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _selectedImage!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 60,
                  height: 60,
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(Icons.broken_image, size: 24, color: Color(0xFF94A3B8)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFFFF2374), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        isEn ? 'Photo Analyzed' : 'ছবি বিশ্লেষণ সম্পন্ন',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEn
                        ? 'Select a brand or keyword chip to find the exact product'
                        : 'ব্র্যান্ড বা কীওয়ার্ড নির্বাচন করে সঠিক প্রোডাক্টটি খুঁজে নিন',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => _showSourceSheet(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF2374)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                isEn ? 'Change' : 'পরিবর্তন',
                style: const TextStyle(color: Color(0xFFFF2374), fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    // Default Banner if no image selected yet
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF2374),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Visual Skincare Search' : 'ভিজুয়াল স্কিনকেয়ার সার্চ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEn
                          ? 'Take or upload a photo to find any skincare product'
                          : 'ছবি তুলে বা আপলোড করে যেকোনো স্কিনকেয়ার প্রোডাক্ট খুঁজুন',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, size: 17, color: Colors.white),
                  label: Text(
                    isEn ? 'Take Photo' : 'ছবি তুলুন',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2374),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 17, color: Color(0xFF1E293B)),
                  label: Text(
                    isEn ? 'Gallery' : 'গ্যালারি',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF1E293B)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSourceSheet() {
    final isEn = context.read<LanguageProvider>().isEnglish;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEn ? 'Select Product Photo' : 'প্রোডাক্টের ছবি নিন',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEF3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFFF2374)),
                ),
                title: Text(
                  isEn ? 'Take photo with camera' : 'ক্যামেরা দিয়ে ছবি তুলুন',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                subtitle: Text(
                  isEn ? 'Snap bottle or packaging' : 'প্রোডাক্ট বা বোতলের ছবি তুলুন',
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF2563EB)),
                ),
                title: Text(
                  isEn ? 'Choose from gallery' : 'গ্যালারি থেকে ছবি নিন',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                subtitle: Text(
                  isEn ? 'Select photo from device storage' : 'ফোন মেমোরি থেকে প্রোডাক্টের ছবি বাছাই করুন',
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
