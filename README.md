# Nutrition & AI Coach

Flutter Material 3 implementation of **Splash, Onboarding, Login / Sign Up, and Home Dashboard**. Specifications and visual references are in [Agentic](Agentic/README.md).

## Structure

`lib/app` owns the single session Cubit and state-driven gate. `lib/features` separates presentation screens/widgets/Cubits and data services/models. `lib/core` contains the shared theme, models, profile service, day helpers, and navigation contracts. Constructor injection connects `Screen → Cubit → Service → Firebase/Hive`; there are no repositories or domain layers.

The app uses bundled Plus Jakarta Sans (license in `assets/fonts/OFL.txt`). Onboarding is a single scrollable introduction, as the spec does not prescribe multiple slides. It persists only its completion preference in Hive. Auth sessions belong to Firebase.

## Firebase setup required

No Firebase project or client configuration was supplied. Until configured, startup shows a recoverable setup error rather than a simulated session.

1. Select the team's Firebase project, register the intended Android/Web apps, and enable Email/Password Authentication. The starter Android application ID is `com.example.nutration_ai`; agree the final ID before registering.
2. Create Cloud Firestore in the agreed region. Review and emulator-test the owner-only examples in `Agentic/firebase/` before deploying them. They have **not** been deployed by this implementation.
3. Install the Firebase and FlutterFire CLIs, authenticate, and run from this project root:

   ```sh
   flutter pub get
   flutterfire configure
   dart run tool/connect_firebase.dart
   dart format lib/core/firebase_bootstrap.dart
   flutter run
   ```

   The helper connects bootstrap to the real generated `firebase_options.dart`. It refuses to run without that file. No generated options or project IDs are invented. Native Android initialization can also use the real platform config produced by FlutterFire.
4. Verify registration, restored sessions, sign-out, and account isolation with two test accounts. Align the Firebase password policy with the UI minimum of 8 characters and a number; stricter server-policy errors are handled.

Storage is optional and has not been added. There are no AI credentials or extra auth providers. Native iOS/macOS scaffolding is not present in the supplied workspace; add/configure those platforms separately if needed. Linux is not a supported Firebase Auth target here; use Android or configured Web.

## Team integration

`App` accepts these constructor parameters:

- `mealReader`: a `MealPeriodReader` callback matching `MealService.watchMealsForPeriod(uid, firstDayKey, lastDayKey)`. Inject the Meals owner's method tear-off. The minimal shared `MealEntry` read DTO exactly follows the documented fields; coordinate it with the Meals owner. No production meal service or CRUD has been created.
- `screens`: `TeamScreens(analytics:, coach:, profile:, addMeal:)` widget builders. Replace the clearly labeled integration placeholders with teammate screens.

Example wiring after teammates merge:

```dart
App(
  auth: authService,
  profiles: profileService,
  onboarding: onboardingService,
  mealReader: mealService.watchMealsForPeriod,
  screens: TeamScreens(
    analytics: (_) => const AnalyticsScreen(),
    coach: (_) => const CoachScreen(),
    profile: (_) => const ProfileScreen(),
    addMeal: (_) => const AddMealScreen(),
  ),
)
```

The shell and Home use one Add Meal navigation action. It pushes above the entire shell on the session-scoped navigator and has no navbar. Session changes dispose that navigator and its pushed routes, preventing Back from revealing another account. Analytics owns its Trends/Meal History internal tabs. No teammate features have been implemented.

Home listens to profile/goals and a single seven-calendar-day meal stream, recalculates after edits, and refreshes its range at local midnight or resume. Stored `localDayKey` controls grouping. Missing days are labeled unlogged; today's values are partial. Streaks and personalized AI advice are omitted because the required history/backend is unavailable. Home shows **No meal data connected** until the real service is injected; an injected empty stream represents a genuinely empty meal history.

`UserProfileService` atomically creates missing profiles and preserves existing goals/identity on login. Signup waits for profile/name writes before Home. Partial registration failure offers profile retry without creating a second account. Profile teammates should use `updateGoals`, `updateName`, and the shared auth/session sign-out action.

## Verification

```sh
dart format .
flutter pub get
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

Tests use mocks and an in-memory Firestore fake for startup/auth ordering, goal persistence, nutrition calculations, live streams, account changes, day boundaries, forms, responsive layouts, onboarding persistence, and shell navigation. They do not replace real Firebase integration or Emulator Security Rules tests. See [IMPLEMENTATION.md](IMPLEMENTATION.md) for actual verification results and remaining dependencies.
