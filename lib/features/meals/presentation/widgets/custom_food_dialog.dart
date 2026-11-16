import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CustomFoodDraft {
  const CustomFoodDraft({
    required this.name,
    required this.servingGrams,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final String name;
  final double servingGrams;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
}

Future<CustomFoodDraft?> showCustomFoodDialog(
  BuildContext context, {
  required String mealType,
}) => showDialog<CustomFoodDraft>(
  context: context,
  builder: (_) => _CustomFoodDialog(mealType: mealType),
);

class _CustomFoodDialog extends StatefulWidget {
  const _CustomFoodDialog({required this.mealType});

  final String mealType;

  @override
  State<_CustomFoodDialog> createState() => _CustomFoodDialogState();
}

class _CustomFoodDialogState extends State<_CustomFoodDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _grams = TextEditingController(text: '100');
  final _calories = TextEditingController();
  final _protein = TextEditingController(text: '0');
  final _carbs = TextEditingController(text: '0');
  final _fat = TextEditingController(text: '0');

  @override
  void dispose() {
    for (final c in [_name, _grams, _calories, _protein, _carbs, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validateNumber(
    String? v, {
    required double max,
    bool positive = false,
  }) {
    final parsed = double.tryParse((v ?? '').trim());
    if (parsed == null) return 'Invalid';
    if (positive && parsed <= 0) return '> 0';
    if (!positive && parsed < 0) return '>= 0';
    if (parsed > max) return '<= ${max.round()}';
    return null;
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      CustomFoodDraft(
        name: _name.text.trim(),
        servingGrams: double.parse(_grams.text.trim()),
        calories: double.parse(_calories.text.trim()),
        proteinG: double.parse(_protein.text.trim()),
        carbsG: double.parse(_carbs.text.trim()),
        fatG: double.parse(_fat.text.trim()),
      ),
    );
  }

  InputDecoration _fieldDecoration(
    String label, {
    String? hint,
    String? suffixText,
    Color? labelColor,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    suffixText: suffixText,
    isDense: true,
    filled: true,
    fillColor: AppColors.surfaceVariant,
    labelStyle: TextStyle(
      fontSize: 13,
      color: labelColor ?? AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 1.5,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.white,
    insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.mintBadge,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Custom ${widget.mealType}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          'Enter nutrition for your serving',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration(
                  'Meal or food name',
                  hint: 'e.g. Homemade Shakshuka',
                ),
                validator: (v) {
                  final trimmed = (v ?? '').trim();
                  if (trimmed.isEmpty) return 'Enter a meal name';
                  if (trimmed.length > 200) return 'Max 200 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _grams,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        'Serving (g)',
                        suffixText: 'g',
                      ),
                      validator: (v) =>
                          _validateNumber(v, max: 20000, positive: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _calories,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        'Calories (kcal)',
                        suffixText: 'kcal',
                      ),
                      validator: (v) => _validateNumber(v, max: 50000),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'MACROS (GRAMS)',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _protein,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        'Protein',
                        suffixText: 'g',
                        labelColor: AppColors.protein,
                      ),
                      validator: (v) => _validateNumber(v, max: 10000),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _carbs,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        'Carbs',
                        suffixText: 'g',
                        labelColor: AppColors.carbs,
                      ),
                      validator: (v) => _validateNumber(v, max: 10000),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fat,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                      decoration: _fieldDecoration(
                        'Fat',
                        suffixText: 'g',
                        labelColor: AppColors.fats,
                      ),
                      validator: (v) => _validateNumber(v, max: 10000),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Add Meal'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
