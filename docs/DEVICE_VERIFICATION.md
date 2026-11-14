# Device verification still to run

Use the generated debug APK for `com.example.nutration_ai`. The user approved installation. On the connected 2201117TG (Android 13), installation and cold launch succeeded. Verified Onboarding → Get Started → Login; empty login fields show email/password validation; Sign Up opens with name/email/password/confirmation fields; after force-stop and cold relaunch, Login appears without repeating onboarding. The app was left on Login. No personal account was used.

Authenticated native restart, Home navigation with a real account, keyboard/rotation checks and logout on-device remain unverified. The checklist below includes both completed and remaining scenarios.

1. Install/update the APK and confirm the supplied mint leaf icon and Nutrition & AI Coach label.
2. On a fresh installation, confirm Splash → Onboarding; Skip/Get Started should persist completion and open Login.
3. Register a dedicated test account. Confirm the supplied name appears after Firestore profile initialization, with a clear missing-meal-connection state.
4. Force-stop and relaunch. Confirm Splash → authenticated shell without Login or repeated onboarding.
5. Sign out, press system Back, and relaunch. Confirm Login remains the root.
6. Sign in with the same account; verify its name/goals remain intact. Invalid credentials should retain the form and show a readable error.
7. Open Add Meal from Home and the center action; verify no navbar appears over the placeholder and Back restores the previous shell tab.
8. Check keyboard scrolling and large text on Login/Sign Up; rotate the device and inspect Home for overflow.
9. Clean up only the dedicated test account/documents. Do not remove unrelated records or change deployed rules.

Live Firebase SDK checks, automated Flutter tests, and the build results are listed separately in IMPLEMENTATION.md. Teammate-owned meal CRUD and screens are not supplied and cannot be certified by this checklist.
