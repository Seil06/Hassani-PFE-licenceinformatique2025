import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/routes/routes.dart';
import 'package:myapp/theme/app_pallete.dart';

class SplashScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      );

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    if (hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, RouteGenerator.authGate);
    } else {
      Navigator.pushReplacementNamed(context, RouteGenerator.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBackground(
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 200,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.favorite,
                  size: 200,
                  color: LightAppPallete.background,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mazal Kayen Elkhir',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: LightAppPallete.background,
                      fontSize: 32,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}