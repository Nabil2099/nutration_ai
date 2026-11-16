import '../../../../core/data/models/meal_entry.dart';
import '../../../../core/data/models/user_profile.dart';
import '../../data/models/coach_message.dart';

class CoachState {
  const CoachState({
    required this.messages,
    this.meals = const [],
    this.profile,
    this.sending = false,
    this.errorMessage,
  });

  final List<CoachMessage> messages;
  final List<MealEntry> meals;
  final UserProfile? profile;
  final bool sending;
  final String? errorMessage;

  CoachState copyWith({
    List<CoachMessage>? messages,
    List<MealEntry>? meals,
    UserProfile? profile,
    bool? sending,
    String? errorMessage,
    bool clearError = false,
  }) => CoachState(
    messages: messages ?? this.messages,
    meals: meals ?? this.meals,
    profile: profile ?? this.profile,
    sending: sending ?? this.sending,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}
