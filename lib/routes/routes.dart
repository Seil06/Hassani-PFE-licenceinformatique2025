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
import 'package:myapp/widgets/pages/campagne_page.dart';
import 'package:myapp/widgets/pages/feed_page.dart';
import 'package:myapp/widgets/pages/post_page.dart';
import 'package:myapp/screens/admin/profile_admin.dart'; 
import 'package:myapp/screens/utilisateur/association/profile_association.dart'; 
import 'package:myapp/screens/utilisateur/beneficiaire/profile_beneficiaire.dart';
import 'package:myapp/screens/utilisateur/donateur/profile_donateur.dart';
import 'package:myapp/widgets/pages/profile_page.dart'; 


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
  static const String campagneDetails = '/campagne-details';
  static const String postDetails = '/post-details';
  static const String profileAdmin = '/profile-admin';
  static const String profileAssociation = '/profile-association';
  static const String profileBeneficiaire = '/profile-beneficiaire';
  static const String profileDonateur = '/profile-donateur';
  static const String profile = '/profile';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings, {required String userType}) {
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
      case campagneDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => CampagneDetailsPage(campagne: args?['campagne']));
      case postDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => PostDetailsPage(post: args?['post']));
      case profileAdmin:
        return MaterialPageRoute(builder: (_) => const ProfileAdmin());
      case profileAssociation:
        return MaterialPageRoute(builder: (_) => const ProfileAssociation());
      case profileBeneficiaire:
        return MaterialPageRoute(builder: (_) => const ProfileBeneficiaire());
      case profileDonateur:
        return MaterialPageRoute(builder: (_) => const ProfileDonateur());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case home :
        return MaterialPageRoute(builder: (_) => FeedPage(userType: userType));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}