import 'package:flutter/material.dart';
import 'package:myapp/screens/admin/admin_home.dart';
import 'package:myapp/screens/auth/connexion.dart';
import 'package:myapp/screens/auth/inscription.dart';
import 'package:myapp/screens/utilisateur/association/association_home.dart'; 
import 'package:myapp/screens/utilisateur/beneficiaire/beneficiaire_home.dart';
import 'package:myapp/screens/utilisateur/donateur/donateur_home.dart';
import 'package:myapp/splash_screen.dart';
import 'package:myapp/onboarding_screen.dart';
import 'package:myapp/screens/auth/AuthGateScreen.dart';

class RouteGenerator {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String authGate = '/auth-gate'; 
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgetPw = '/forget-password';
  static const String adminHome = '/admin-Home';
  static const String donateurHome = '/donateur-Home';
  static const String associationHome = '/association-Home';
  static const String beneficiaireHome = '/beneficiaire-Home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case authGate:
        return MaterialPageRoute(builder: (_) => const AuthGateScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const Connexion());
      case signup:
        return MaterialPageRoute(builder: (_) => const Inscription());
      case forgetPw:
        return MaterialPageRoute(builder: (_) => const Placeholder()); // Implement forgot password screen
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHome()); 
      case donateurHome:
        return MaterialPageRoute(builder: (_) => const DonateurHome()); 
      case associationHome:
        return MaterialPageRoute(builder: (_) => const AssociationHome()); 
      case beneficiaireHome:
        return MaterialPageRoute(builder: (_) => const BeneficiaireHome()); 
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}