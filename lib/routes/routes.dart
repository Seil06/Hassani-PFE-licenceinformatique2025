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
import 'package:myapp/widgets/pages/notifications_page.dart';
import 'package:myapp/widgets/pages/post_page.dart';
import 'package:myapp/widgets/pages/profile_page.dart';
import 'package:myapp/screens/utilisateur/donateur/Gestion_post.dart';
import 'package:myapp/widgets/pages/search_page.dart';

class RouteGenerator {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String authGate = '/auth-gate';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String adminHome = '/admin-home';
  static const String donateurHome = '/donateur-home';
  static const String associationHome = '/association-home';
  static const String beneficiaireHome = '/beneficiaire-home';
  static const String forgetPw = '/forget-pw';
  static const String home = '/home';
  static const String campagneDetails = '/campagne-details';
  static const String postDetails = '/post-details';
  static const String profile = '/profile';
  static const String search = '/search';
  static const String gestionPost = '/gestion-post';
  static const String map = '/map';
  static const String notifications = '/notifications';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

     
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
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHome());
      case donateurHome:
        return MaterialPageRoute(builder: (_) => const DonateurHome());
      case associationHome:
        return MaterialPageRoute(builder: (_) => const AssociationHome());
      case beneficiaireHome:
        return MaterialPageRoute(builder: (_) => const BeneficiaireHome());
      case forgetPw:
        return MaterialPageRoute(builder: (_) => const Placeholder());
      case home:
        return MaterialPageRoute(builder: (_) => const FeedPage());
      case campagneDetails:
        return MaterialPageRoute(builder: (_) => CampagneDetailsPage(campagne: args?['campagne']));
      case postDetails:
        return MaterialPageRoute(builder: (_) => PostDetailsPage(post: args?['post']));
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPage()); // TODO: Implement SearchPage
      case gestionPost:
        return MaterialPageRoute(builder: (_) => const GestionPost());
      case map:
        return MaterialPageRoute(builder: (_) => const Placeholder()); // TODO: Implement MapPage
      case notifications:
      return MaterialPageRoute(builder: (_) => const NotificationsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}