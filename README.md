# Nutrition & AI Coach

Flutter Material 3 implementation of **Splash, Onboarding, Login / Sign Up, and Home Dashboard**. Specifications and visual references are in [Agentic](Agentic/README.md).

## Structure

`lib/app` owns the single session Cubit and state-driven gate. `lib/features` separates presentation screens/widgets/Cubits and data services/models. `lib/core` contains the shared theme, models, profile service, day helpers, and navigation contracts. Constructor injection connects `Screen → Cubit → Service → Firebase/Hive`; there are no repositories or domain layers.

The app uses bundled Plus Jakarta Sans (license in `assets/fonts/OFL.txt`). Onboarding is a single scrollable introduction, as the spec does not prescribe multiple slides. It persists only its completion preference in Hive. Auth sessions belong to Firebase.

## Firebase project configuration

Android and Web are registered with **`nutration-ai-36e01`**. Generated `lib/firebase_options.dart`, `android/app/google-services.json`, and `firebase.json` target that project. Android retains `com.example.nutration_ai`. Bootstrap initializes Firebase once before constructing services. Client configuration contains public identifiers, not admin credentials.

Live checks found two required Console steps:

1. In Firebase Console → Authentication → Get started, enable **Email/Password**. The live sign-in endpoint currently returns `CONFIGURATION_NOT_FOUND`.
2. In Firestore Database → Create database, choose the team's region and production mode. The Firestore API currently returns HTTP 403 because it is disabled or unused. After database creation, review `firebase/firestore.rules` and approve deployment before running `firebase deploy --only firestore:rules --project nutration-ai-36e01` with an appropriate deployment configuration. No production rules have been deployed.
3. Then verify signup/profile creation, login, restart/session restoration and logout using two test accounts. Align the server password policy with the UI minimum of eight characters and one number.

```sh
flutter pub get
flutter run -d chrome
flutter run -d <android-device-id>
```

To regenerate configuration: `flutterfire configure --project=nutration-ai-36e01 --platforms=android,web --android-package-name=com.example.nutration_ai`.

Storage remains optional and unconfigured. iOS/macOS scaffolding is absent; Linux Firebase Auth is unsupported here. Meal and teammate screen integration remains as described below.

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

### Local Firestore rules checks

These tests run only against the explicit `demo-nutrition-ai` emulator namespace. They do not configure or deploy a production project.

```sh
npm ci --prefix test/firebase_rules
firebase emulators:exec --project demo-nutrition-ai --config firebase.emulators.json --only firestore 'npm test --prefix test/firebase_rules'
```

A Java 21+ runtime must be on PATH. This machine uses `/opt/android-studio/jbr/bin`. The test package overrides the Firebase SDK's older gRPC dependency with a patched compatible release; `npm audit` is clean.

### Render previews

```sh
flutter test tool/render_previews.dart
```

This utility writes the five screen images into `docs/previews/`. Home uses an explicitly test-only fixture and the images are review artifacts, not live account screenshots.
