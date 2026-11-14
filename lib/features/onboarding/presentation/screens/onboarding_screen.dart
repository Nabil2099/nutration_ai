import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../widgets/onboarding_illustration.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const BrandMark(size: 36),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Nutrition & AI Coach',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton(
                      onPressed: onComplete,
                      child: const Text('Skip'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const OnboardingIllustration(),
                      const SizedBox(height: 20),
                      Text(
                        'A little awareness. A healthier rhythm.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.eco_outlined),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your meals and daily goals, together in one place.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Transform how you nourish your body',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Build mindful habits with meal logging, nutrition goals and a clearer view of your daily intake.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 20),
                for (final item in [
                  (
                    Icons.restaurant_outlined,
                    'Mindful meal logging',
                    'Keep track of the meals you eat.',
                  ),
                  (
                    Icons.tune_rounded,
                    'Personal goals',
                    'Follow your calorie and macro targets.',
                  ),
                  (
                    Icons.insights_outlined,
                    'See your progress',
                    'Explore your logged nutrition over time.',
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tileColor: Colors.white,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(item.$1, color: AppColors.primary),
                      ),
                      title: Text(item.$2),
                      subtitle: Text(item.$3),
                    ),
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onComplete,
                  child: const Text('Get Started →'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onComplete,
                  child: const Text('Already have an account? Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
