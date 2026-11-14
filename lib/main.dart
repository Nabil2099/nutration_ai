import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/firebase_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_error_view.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/onboarding/data/services/onboarding_service.dart';
import 'core/data/services/user_profile_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Bootstrap());
}

class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  late Future<Widget> _startup;
  @override
  void initState() {
    super.initState();
    _startup = _initialize();
  }

  Future<Widget> _initialize() async {
    await initializeFirebase().timeout(const Duration(seconds: 25));
    await Hive.initFlutter();
    final preferences = await Hive.openBox<dynamic>('preferences');
    final profiles = UserProfileService(FirebaseFirestore.instance);
    return App(
      auth: AuthService(FirebaseAuth.instance, profiles),
      profiles: profiles,
      onboarding: OnboardingService(preferences),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget>(
    future: _startup,
    builder: (context, snapshot) {
      if (snapshot.hasData) return snapshot.data!;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: snapshot.hasError
            ? Scaffold(
                body: AppErrorView(
                  message: 'App services could not start. Check your connection and Firebase platform configuration. See README for setup.',
                  onRetry: () => setState(() => _startup = _initialize()),
                ),
              )
            : const SplashScreen(),
      );
    },
  );
}
