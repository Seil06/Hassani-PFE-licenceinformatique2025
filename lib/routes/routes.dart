import 'package:flutter/material.dart';
import 'package:myapp/routes/routes_admin.dart';
import 'package:myapp/routes/routes_association.dart';
import 'package:myapp/routes/routes_beneficiaire.dart';
import 'package:myapp/routes/routes_donateur.dart';
import 'package:myapp/screens/admin/admin_home.dart';
import 'package:myapp/screens/admin/Gestion_avertissement.dart';
import 'package:myapp/screens/admin/Gestion_post_officiel.dart';
import 'package:myapp/screens/admin/map_page.dart';
import 'package:myapp/screens/admin/profile_admin.dart';
import 'package:myapp/screens/admin/search_page.dart';
import 'package:myapp/screens/admin/seetings_page.dart';
import 'package:myapp/screens/auth/connexion.dart';
import 'package:myapp/screens/auth/inscription.dart';
import 'package:myapp/screens/utilisateur/association/association_home.dart';
import 'package:myapp/screens/utilisateur/association/map_page.dart';
import 'package:myapp/screens/utilisateur/association/profile_association.dart';
import 'package:myapp/screens/utilisateur/association/Gestion_campagne.dart';
import 'package:myapp/screens/utilisateur/association/search_page.dart';
import 'package:myapp/screens/utilisateur/association/seetings_page.dart';
import 'package:myapp/screens/utilisateur/beneficiaire/beneficiaire_home.dart';
import 'package:myapp/screens/utilisateur/beneficiaire/map_page.dart';
import 'package:myapp/screens/utilisateur/beneficiaire/profile_beneficiaire.dart';
import 'package:myapp/screens/utilisateur/beneficiaire/Gestion_post_demande.dart';
import 'package:myapp/screens/utilisateur/beneficiaire/search_page.dart';
import 'package:myapp/screens/utilisateur/beneficiaire/seetings_page.dart';
import 'package:myapp/screens/utilisateur/donateur/donateur_home.dart';
import 'package:myapp/screens/utilisateur/donateur/map_page.dart';
import 'package:myapp/screens/utilisateur/donateur/profile_donateur.dart';
import 'package:myapp/screens/utilisateur/donateur/Gestion_post.dart';
import 'package:myapp/screens/utilisateur/donateur/calculateur_zakat_screen.dart';
import 'package:myapp/screens/utilisateur/donateur/search_page.dart';
import 'package:myapp/screens/utilisateur/donateur/seetings_page.dart';
import 'package:myapp/splash_screen.dart';
import 'package:myapp/onboarding_screen.dart';
import 'package:myapp/screens/auth/AuthGateScreen.dart';
import 'package:myapp/widgets/pages/campagne_page.dart';
import 'package:myapp/widgets/pages/post_page.dart';

class RouteGenerator {
  // Global routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String authGate = '/auth-gate';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgetPw = '/forget-pw';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    // Delegate to actor-specific route generators
    switch (settings.name) {
      // Global routes
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
        return MaterialPageRoute(builder: (_) => const Placeholder());

      // Donateur routes
      case RouteGeneratorDonateur.home:
        return MaterialPageRoute(builder: (_) => const DonateurHome());
      case RouteGeneratorDonateur.profile:
        return MaterialPageRoute(builder: (_) => const ProfileDonateur());
      case RouteGeneratorDonateur.gestionPostoffreEtInvite:
        return MaterialPageRoute(
          builder: (_) => GestionPost(
            idActeur: args?['idActeur'],
            userData: args?['userData'],
          ),
        );
      case RouteGeneratorDonateur.calculateurZakat:
        return MaterialPageRoute(builder: (_) => const CalculateurZakatScreen());
      case RouteGeneratorDonateur.search:
        return MaterialPageRoute(builder: (_) => const SearchPageDonateur());
      case RouteGeneratorDonateur.map:
        return MaterialPageRoute(builder: (_) => const MapPageDonateur());
      case RouteGeneratorDonateur.campagneDetails:
        return MaterialPageRoute(builder: (_) => CampagneDetailsPage(campagne: args?['campagne']));
      case RouteGeneratorDonateur.postDetails:
        return MaterialPageRoute(builder: (_) => PostDetailsPage(post: args?['post']));
      case RouteGeneratorDonateur.setting:
        return MaterialPageRoute(builder: (_) => const SettingsPageDonateur());

      // Admin routes
      case RouteGeneratorAdmin.home:
        return MaterialPageRoute(builder: (_) => const AdminHome());
      case RouteGeneratorAdmin.profile:
        return MaterialPageRoute(builder: (_) => const ProfileAdmin());
      case RouteGeneratorAdmin.search:
        return MaterialPageRoute(builder: (_) => const SearchPageAdmin());
      case RouteGeneratorAdmin.map:
        return MaterialPageRoute(builder: (_) => const MapPageAdmin());
      case RouteGeneratorAdmin.gestionPostOfficiel:
        return MaterialPageRoute(builder: (_) => const GestionPostOfficiel());
      case RouteGeneratorAdmin.gestionAvertissement:
        return MaterialPageRoute(builder: (_) => const GestionAvertissement());
      case RouteGeneratorAdmin.campagneDetails:
        return MaterialPageRoute(builder: (_) => CampagneDetailsPage(campagne: args?['campagne']));
      case RouteGeneratorAdmin.postDetails:
        return MaterialPageRoute(builder: (_) => PostDetailsPage(post: args?['post']));
      case RouteGeneratorAdmin.setting:
        return MaterialPageRoute(builder: (_) => const SettingsPageAdmin());

      // Association routes
      case RouteGeneratorAssociation.home:
        return MaterialPageRoute(builder: (_) => const AssociationHome());
      case RouteGeneratorAssociation.profile:
        return MaterialPageRoute(builder: (_) => const ProfileAssociation());
      case RouteGeneratorAssociation.gestionPostCampagne:
        return MaterialPageRoute(builder: (_) => const GestionCampagne());
      case RouteGeneratorAssociation.search:
        return MaterialPageRoute(builder: (_) => const SearchPageAssociation());
      case RouteGeneratorAssociation.map:
        return MaterialPageRoute(builder: (_) => const MapPageAssociation());
      case RouteGeneratorAssociation.campagneDetails:
        return MaterialPageRoute(builder: (_) => CampagneDetailsPage(campagne: args?['campagne']));
      case RouteGeneratorAssociation.postDetails:
        return MaterialPageRoute(builder: (_) => PostDetailsPage(post: args?['post']));
      case RouteGeneratorAssociation.setting:
        return MaterialPageRoute(builder: (_) => const SettingsPageAssociation());

      // Beneficiaire routes
      case RouteGeneratorBeneficiaire.home:
        return MaterialPageRoute(builder: (_) => const BeneficiaireHome());
      case RouteGeneratorBeneficiaire.profile:
        return MaterialPageRoute(builder: (_) => const ProfileBeneficiaire());
      case RouteGeneratorBeneficiaire.gestionPostDemande:
        return MaterialPageRoute(builder: (_) => const GestionPostDemande());
      case RouteGeneratorBeneficiaire.search:
        return MaterialPageRoute(builder: (_) => const SearchPageBeneficiaire());
      case RouteGeneratorBeneficiaire.map:
        return MaterialPageRoute(builder: (_) => const MapPageBeneficiaire());
      case RouteGeneratorBeneficiaire.campagneDetails:
        return MaterialPageRoute(builder: (_) => CampagneDetailsPage(campagne: args?['campagne']));
      case RouteGeneratorBeneficiaire.postDetails:
        return MaterialPageRoute(builder: (_) => PostDetailsPage(post: args?['post']));
      case RouteGeneratorBeneficiaire.setting:
        return MaterialPageRoute(builder: (_) => const SettingsPageBeneficiaire());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}