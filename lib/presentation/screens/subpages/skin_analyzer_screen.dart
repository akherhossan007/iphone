import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../catalog/catalog_screen.dart';

class SkinAnalyzerScreen extends StatefulWidget {
  const SkinAnalyzerScreen({super.key});

  @override
  State<SkinAnalyzerScreen> createState() => _SkinAnalyzerScreenState();
}

class _SkinAnalyzerScreenState extends State<SkinAnalyzerScreen> {
  int _currentStep = 0;
  String? _selectedSkinType;
  String? _selectedConcern;

  final List<String> _skinTypes = ['Oily / Acne-Prone', 'Dry & Dehydrated', 'Combination', 'Sensitive'];
  final List<String> _concerns = ['Acne & Blemishes', 'Brightening & Dark Spots', 'Anti-Aging & Wrinkles', 'Sun Protection & Barrier Repair'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Skin Consultation Quiz', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Find Your Perfect Routine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('Answer 2 quick questions to get personalized Malaysian skincare recommendations.', style: TextStyle(color: Colors.white, fontSize: 11, height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_currentStep == 0) ...[
              const Text('Step 1: What is your primary skin type?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 12),
              ..._skinTypes.map((type) => _buildOptionCard(
                    title: type,
                    isSelected: _selectedSkinType == type,
                    onTap: () => setState(() => _selectedSkinType = type),
                  )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedSkinType == null ? null : () => setState(() => _currentStep = 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('NEXT QUESTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ] else if (_currentStep == 1) ...[
              const Text('Step 2: What is your main skin concern?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 12),
              ..._concerns.map((concern) => _buildOptionCard(
                    title: concern,
                    isSelected: _selectedConcern == concern,
                    onTap: () => setState(() => _selectedConcern = concern),
                  )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedConcern == null ? null : () => setState(() => _currentStep = 2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SEE MY TAILORED ROUTINE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.verified, color: AppColors.authenticGreen, size: 36),
                    const SizedBox(height: 8),
                    const Text('Recommended Routine Found!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Tailored for $_selectedSkinType with concern: $_selectedConcern', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const Divider(height: 24),
                    _buildRoutineStepCard(
                      step: '1',
                      title: 'Step 1: Gentle Hydrating Cleanser',
                      categorySlug: 'facial-cleanser',
                      desc: 'Essential for resetting pore cleanliness without stripping skin moisture.',
                    ),
                    const SizedBox(height: 12),
                    _buildRoutineStepCard(
                      step: '2',
                      title: 'Step 2: Barrier Repair & Moisturizer',
                      categorySlug: 'skincare-moisturizer',
                      desc: 'Hydrates deeply and strengthens the protective lipid moisture barrier.',
                    ),
                    const SizedBox(height: 12),
                    _buildRoutineStepCard(
                      step: '3',
                      title: 'Step 3: UV Shield Sunscreen',
                      categorySlug: 'sunscreen',
                      desc: 'Crucial daily SPF defense against dark spots and premature skin aging.',
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => setState(() {
                        _currentStep = 0;
                        _selectedSkinType = null;
                        _selectedConcern = null;
                      }),
                      icon: const Icon(Icons.restart_alt, size: 16),
                      label: const Text('RETAKE CONSULTATION QUIZ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderSubtle, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontSize: 13, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
            Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? AppColors.primary : AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineStepCard({
    required String step,
    required String title,
    required String categorySlug,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFFECFDF5),
                child: Text(step, style: const TextStyle(color: AppColors.authenticGreen, fontWeight: FontWeight.w900, fontSize: 11)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CatalogScreen(initialCategory: categorySlug)),
                );
              },
              icon: const Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.primary),
              label: const Text('BROWSE PRODUCTS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
