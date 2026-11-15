import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutration_ai/core/data/services/user_profile_service.dart';
import 'package:nutration_ai/core/data/models/nutrition_goals.dart';

void main() {
  test('ensure is idempotent; name repair and goal edits preserve identity and creation', () async {
    final firestore = FakeFirebaseFirestore(),
        service = UserProfileService(FakeFirebaseFirestore());
    final actual = UserProfileService(firestore);
    final first = await actual.ensureProfile(uid: 'a', email: 'a@example.com');
    const edited = NutritionGoals(
      calories: 2300,
      proteinG: 140,
      carbsG: 250,
      fatG: 70,
    );
    await actual.updateGoals('a', edited);
    await actual.saveRegisteredName('a', 'Mona');
    final second = await actual.ensureProfile(
      uid: 'a',
      email: 'a@example.com',
      preferredName: 'Wrong',
    );
    expect(second.dailyGoals.calories, 2300);
    expect(second.name, 'Mona');
    expect(second.createdAt, first.createdAt);
    expect((await actual.watchProfile('a').first).email, 'a@example.com');
    expect(
      () => service.updateGoals(
        'b',
        const NutritionGoals(calories: -1, proteinG: 1, carbsG: 1, fatG: 1),
      ),
      throwsArgumentError,
    );
    final shortName = await actual.ensureProfile(
      uid: 'short',
      email: 's@example.com',
      preferredName: 'A',
    );
    expect(shortName.name, 'User');
    final longName = await actual.ensureProfile(
      uid: 'long',
      email: 'l@example.com',
      preferredName: 'N' * 100,
    );
    expect(longName.name.length, 80);
  });
}
