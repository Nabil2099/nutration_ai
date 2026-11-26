import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/meal_analysis.dart';
import '../../data/services/meal_photo_picker.dart';

/// Bottom sheet asking whether to capture a new photo or pick one from the
/// gallery. Returns `null` when dismissed without a choice.
Future<MealPhotoSource?> showMealPhotoSourceSheet(BuildContext context) =>
    showModalBottomSheet<MealPhotoSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add a meal photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Snap the plate or pick an existing photo',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              _SourceTile(
                icon: Icons.photo_camera_outlined,
                title: 'Take photo',
                subtitle: 'Use the camera to capture your meal',
                onTap: () =>
                    Navigator.of(sheetContext).pop(MealPhotoSource.camera),
              ),
              const SizedBox(height: 10),
              _SourceTile(
                icon: Icons.photo_library_outlined,
                title: 'Choose from gallery',
                subtitle: 'Pick a photo you already have',
                onTap: () =>
                    Navigator.of(sheetContext).pop(MealPhotoSource.gallery),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.scanContainer,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.scan),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Hero card for the meal-photo scan: gradient CTA at rest, progress while
/// analyzing, and a success summary (with rescan/clear) once results arrive.
class MealScanCard extends StatelessWidget {
  const MealScanCard({
    super.key,
    required this.analyzing,
    required this.analysis,
    required this.onTapScan,
    required this.onClearScan,
  });

  final bool analyzing;
  final MealAnalysis? analysis;
  final VoidCallback onTapScan;
  final VoidCallback onClearScan;

  @override
  Widget build(BuildContext context) {
    if (analyzing) return const _AnalyzingCard();
    final result = analysis;
    if (result != null) {
      return _ResultCard(
        analysis: result,
        onRescan: onTapScan,
        onClear: onClearScan,
      );
    }
    return _CtaCard(onTap: onTapScan);
  }
}

BoxDecoration get _scanGradient => BoxDecoration(
  gradient: const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.scanGradientStart, AppColors.scanGradientEnd],
  ),
  borderRadius: BorderRadius.circular(20),
);

class _CtaCard extends StatelessWidget {
  const _CtaCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: Ink(
      // Painted on the Material above, so the InkWell splash shows through.
      decoration: _scanGradient,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              _ScanIcon(icon: Icons.photo_camera_outlined),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan your meal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Snap a photo — AI estimates calories & macros',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AnalyzingCard extends StatelessWidget {
  const _AnalyzingCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _scanGradient,
    child: const Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analyzing your meal…',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Finding foods, calories & macros',
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.analysis,
    required this.onRescan,
    required this.onClear,
  });

  final MealAnalysis analysis;
  final VoidCallback onRescan;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final itemCount = analysis.items.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.scanContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.scan.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const TextSpan(
                            text: '  ·  ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text:
                                '${analysis.totalCaloriesKcal.round()} kcal',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.scan,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${analysis.totalProteinG.round()}g P · '
                      '${analysis.totalCarbsG.round()}g C · '
                      '${analysis.totalFatG.round()}g F',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Scan another photo',
                onPressed: onRescan,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.scan,
                  minimumSize: const Size(34, 34),
                  maximumSize: const Size(34, 34),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Clear scan results',
                onPressed: onClear,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textSecondary,
                  minimumSize: const Size(34, 34),
                  maximumSize: const Size(34, 34),
                ),
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 13, color: AppColors.warning),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'AI estimate — adjust portions before saving if needed.',
                  style: TextStyle(fontSize: 10.5, color: AppColors.warning),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanIcon extends StatelessWidget {
  const _ScanIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 21, color: AppColors.scanGradientStart),
  );
}
