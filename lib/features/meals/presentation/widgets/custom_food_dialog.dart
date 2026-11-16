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
    if (parsed == null) return 'Enter a number';
    if (positive && parsed <= 0) return 'Must be > 0';
    if (!positive && parsed < 0) return 'Must be >= 0';
    if (parsed > max) return 'Max ${max.round()}';
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

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    title: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.mintBadge,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Add Custom ${widget.mealType}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
    content: SingleChildScrollView(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Meal or food name',
                hintText: 'e.g. Homemade Shakshuka',
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
                    decoration: const InputDecoration(labelText: 'Serving (g)'),
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
                    decoration: const InputDecoration(
                      labelText: 'Calories (kcal)',
                    ),
                    validator: (v) => _validateNumber(v, max: 50000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _protein,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Protein (g)'),
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
                    decoration: const InputDecoration(labelText: 'Carbs (g)'),
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
                    decoration: const InputDecoration(labelText: 'Fat (g)'),
                    validator: (v) => _validateNumber(v, max: 10000),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _save,
        style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
        child: const Text('Add Meal'),
      ),
    ],
  );
}
