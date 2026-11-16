import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/data/models/meal_entry.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/coach_message.dart';
import 'coach_macro_chart.dart';

class CoachMessageBubble extends StatelessWidget {
  const CoachMessageBubble({
    super.key,
    required this.message,
    required this.meals,
    required this.carbsGoalG,
    this.onQuickPrompt,
  });

  final CoachMessage message;
  final List<MealEntry> meals;
  final double carbsGoalG;
  final ValueChanged<String>? onQuickPrompt;

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(message.timestamp);
    if (message.role == CoachRole.user) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0A5438),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'AI Coach',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (message.badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mintBadge,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              message.badge!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _FormattedCoachText(text: message.text),
            if (message.showMacroChart) ...[
              const SizedBox(height: 14),
              CoachMacroChart(meals: meals, carbsGoalG: carbsGoalG),
            ],
            if (message.fuelIdeaTitle != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardTint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.mintBadge,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.fuelIdeaTitle!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (message.fuelIdeaSubtitle != null)
                            Text(
                              message.fuelIdeaSubtitle!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.verified_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Informational guidance only · Non-medical advice',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (onQuickPrompt != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(
                      Icons.restaurant_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Show food ideas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    backgroundColor: AppColors.mintBadge,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => onQuickPrompt!(
                      'Suggest 3 quick high-protein meal ideas for my remaining calories today.',
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(
                      Icons.chat_bubble_outline,
                      size: 15,
                      color: AppColors.textPrimary,
                    ),
                    label: const Text(
                      'Analyze my macros',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    backgroundColor: AppColors.surfaceVariant,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => onQuickPrompt!(
                      'How are my macros looking today compared to my daily goals?',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Renders `**bold**` spans and clean bullet points without raw markdown symbols.
class _FormattedCoachText extends StatelessWidget {
  const _FormattedCoachText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final baseStyle = const TextStyle(
      fontSize: 14,
      height: 1.55,
      color: AppColors.textPrimary,
    );
    final boldStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    );

    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          if (lines[i].trim().isEmpty)
            const SizedBox(height: 6)
          else
            _buildLine(lines[i], baseStyle, boldStyle),
          if (i < lines.length - 1 && lines[i].trim().isNotEmpty)
            const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _buildLine(String rawLine, TextStyle baseStyle, TextStyle boldStyle) {
    var line = rawLine.trimRight();
    var isBullet = false;

    final trimmedLeft = line.trimLeft();
    if (trimmedLeft.startsWith('- ') ||
        trimmedLeft.startsWith('* ') ||
        trimmedLeft.startsWith('• ')) {
      isBullet = true;
      line = trimmedLeft.substring(2);
    } else if (trimmedLeft.startsWith('#')) {
      line = trimmedLeft.replaceFirst(RegExp(r'^#+\s*'), '');
      return Text.rich(
        TextSpan(text: line.replaceAll('**', ''), style: boldStyle),
      );
    }

    final spans = _parseBoldSpans(line, baseStyle, boldStyle);
    if (!isBullet) {
      return Text.rich(TextSpan(children: spans));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: boldStyle.copyWith(color: AppColors.primary)),
          Expanded(child: Text.rich(TextSpan(children: spans))),
        ],
      ),
    );
  }

  List<InlineSpan> _parseBoldSpans(
    String input,
    TextStyle baseStyle,
    TextStyle boldStyle,
  ) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*');
    var cursor = 0;

    for (final match in pattern.allMatches(input)) {
      if (match.start > cursor) {
        spans.add(
          TextSpan(
            text: input.substring(cursor, match.start),
            style: baseStyle,
          ),
        );
      }
      spans.add(TextSpan(text: match.group(1), style: boldStyle));
      cursor = match.end;
    }

    if (cursor < input.length) {
      spans.add(TextSpan(text: input.substring(cursor), style: baseStyle));
    }
    return spans;
  }
}
