enum CoachRole { user, assistant }

class CoachMessage {
  const CoachMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.badge,
    this.showMacroChart = false,
    this.fuelIdeaTitle,
    this.fuelIdeaSubtitle,
  });

  final String id;
  final CoachRole role;
  final String text;
  final DateTime timestamp;
  final String? badge;
  final bool showMacroChart;
  final String? fuelIdeaTitle;
  final String? fuelIdeaSubtitle;
}
