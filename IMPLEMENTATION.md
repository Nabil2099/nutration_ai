# Phase 2 implementation report

## Current status

Android and Web use `nutration-ai-36e01` through real generated FlutterFire configuration. Android package remains `com.example.nutration_ai`. Authentication Email/Password is enabled; the default Firestore database is available in `nam5`.

The four owned features are implemented: Splash startup gate, locally persisted Onboarding, email/password Authentication, and reactive Home Dashboard. Meals, Analytics, AI Coach and Profile screens remain teammate-owned integrations. Home shows a disconnected state until the real meal stream is supplied.

## Findings and fixes

- Bootstrap had no generated options and rejected Web. Registered Android/Web clients with the explicitly authorized project and connected `lib/core/firebase_bootstrap.dart` to generated options. Services are constructed after initialization.
- HomeCubit could hide a meal-stream failure on the next profile emission and reuse stale totals. Invalidated both cached inputs on failure and added a regression test.
- Phase 2 palette values applied to background, primary and main text.
- Added sensitive-local-file exclusions to `.gitignore` while preserving public Firebase client configuration.
- Added `flutter_launcher_icons` and generated Android/Web icons from an exact tracked copy of the provided artwork.
- Existing feature-first Cubits, injected services, Hive preferences and teammate boundaries preserved. No repository layer or teammate module was added.

## Files created or modified for Phase 2 and icons

Created: `lib/firebase_options.dart`, `android/app/google-services.json`, `firebase.json`, `flutter_launcher_icons.yaml`, `assets/icons/app_icon.png`, `test/firebase_rules/live_check.mjs`.

Modified: `lib/core/firebase_bootstrap.dart`, `lib/features/home/presentation/cubit/home_cubit.dart`, `lib/core/theme/app_colors.dart`, `test/home_cubit_test.dart`, Android Gradle plugin configuration, `.gitignore`, `pubspec.yaml`, `pubspec.lock`, Android launcher PNGs, Web favicon/icons/manifest, README and this report. Pre-existing user changes were preserved. No source files were deleted as part of these tasks.

## Verified results

- Baseline: 26 Flutter tests passed.
- Updated analyzer: no issues; 27 Flutter tests passed.
- Firestore emulator: five tests passed against local owner-only rules, including cross-account denial and invalid writes.
- Flutter Web debug build: passed after Firebase configuration.
- Launcher generator: succeeded for Android and Web.
- Live Firebase: two explicitly approved temporary accounts passed registration, display-name update, server profile creation, goal update, idempotent profile initialization, preservation of creation timestamp, logout and login. Distinct UID profile paths verified. Both accounts and profiles were deleted successfully.
- Android device smoke check: installed the final debug APK on the approved 2201117TG (Android 13); cold startup, onboarding completion, login validation, Sign Up navigation and onboarding persistence across force-stop/relaunch passed. Left the app on Login. Authenticated native restart remains unverified.
- Live checks used the Firebase JavaScript SDK and the generated Web configuration. They do not prove the Flutter UI works on a device or native session restoration after process restart.
- Final Android debug build: succeeded with generated Firebase configuration and the supplied launcher icon. Artifact: `build/app/outputs/flutter-apk/app-debug.apk`. Corrupt Gradle transform metadata was moved aside for regeneration before this successful build. FlutterFire Kotlin-plugin migration warnings remain non-fatal.

## Rules and security

Deployed Firestore rules are Console test-mode rules allowing access until December 15, 2026. The user explicitly requested leaving them unchanged. No live access-isolation claim is made; the tested local owner-only rules are not deployed. No rules deployment occurred.

Credential-signature scan of application/tests/tools/rules found no private-key or refresh-token signatures. Earlier Firebase CLI account JSON exposed credential fields in conversation history; values were not copied into application source or reports. Revoke the old CLI authorization from Google Account connections and reauthenticate if needed. Public Firebase client identifiers are retained. Live test credentials remain only in process memory.

## Remaining work

1. Run the Flutter UI on target devices to confirm signup/login, keyboard behavior and restored sessions after restart.
2. Integrate the Meals owner's stream and Analytics/Coach/Profile/Add Meal builders; no mock nutrition is presented as live data.
3. Configure release signing when preparing a release. Review deployed rules before private or production use; they remain unchanged per user instruction.

Storage is optional and not used by the owned features. No Storage readiness claim is made.
