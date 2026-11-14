# Implementation notes

## Ownership and decisions

Only startup/onboarding/auth/Home and necessary shared infrastructure were implemented. The explicit architecture decisions in `Agentic/docs/01_ARCHITECTURE.md` and the team contract take precedence over the pasted generic repository-pattern suggestion: services and injected SDK clients are used throughout.

Screenshots were inspected. The approved palette from document 10, bundled Plus Jakarta Sans, rounded white cards, mint fields, leaf branding, calorie ring, seven-day chart and macro rows are implemented. Unsupported mockup claims (clinical security, biometric login, photo scanning, adaptive targeting, fabricated streaks and AI recommendations) are omitted. Onboarding uses a local vector food illustration and one introduction; the docs do not specify a slide count. No claim of pixel-perfect reproduction is made.

## Important files

- `lib/main.dart`, `lib/core/firebase_bootstrap.dart`, `tool/connect_firebase.dart`: recoverable initialization and real configuration connection.
- `lib/app.dart`, `lib/app/app_gate.dart`, `lib/app/cubit/`: injected dependencies and session lifecycle.
- `lib/features/splash/`, `lib/features/onboarding/`, `lib/features/auth/`, `lib/features/home/`: owned features.
- `lib/core/data/`: shared profile/goals/meal read contracts and transactional profile service.
- `lib/core/navigation/`: shell, stable destination enum, teammate screen registration.
- `lib/core/theme/`, `assets/fonts/`: approved design tokens and bundled font.
- `test/`: isolated service/Cubit/calculation and widget/navigation tests.
- `android/app/src/main/AndroidManifest.xml`: release Internet permission and app label.

## Remaining external work

Real Firebase project configuration, Console Email/Password setup, Firestore creation, reviewed rules deployment and two-account/emulator verification remain required. The existing example rules were preserved. Optional Storage was not configured. No live authentication or database operation is claimed to have been tested.

The Meals owner's service and Analytics/Coach/Profile/Add Meal screens have not been supplied. The callback and widget-builder integration points are ready; placeholders identify missing modules. UI tests use test-only data. Production Home never presents test fixtures as logged nutrition.

The workspace has no Git repository metadata, so branch/diff/commit checks are unavailable. No commits were made.
