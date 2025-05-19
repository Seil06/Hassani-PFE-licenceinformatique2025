import 'package:flutter/material.dart';
import 'package:myapp/screens/utilisateur/beneficiaire/beneficiaire_home.dart';
import 'package:myapp/screens/utilisateur/beneficiaire/profile_beneficiaire.dart';
import 'package:myapp/screens/utilisateur/beneficiaire/Gestion_post_demande.dart';
import 'package:myapp/screens/auth/connexion.dart';
import 'package:myapp/widgets/pages/campagne_page.dart';
import 'package:myapp/screens/utilisateur/beneficiaire/map_page.dart';
import 'package:myapp/widgets/pages/post_page.dart';
import 'package:myapp/screens/utilisateur/beneficiaire/search_page.dart';
import 'package:myapp/screens/utilisateur/beneficiaire/seetings_page.dart';


class RouteGeneratorBeneficiaire {
  static const String login = '/login';
  static const String home = '/beneficiaire-home';
  static const String profile = '/beneficiaire-profile';
  static const String gestionPostDemande = '/gestion-post-demande';
  static const String search = '/beneficiaire-search';
  static const String map = '/beneficiaire-map';
  static const String campagneDetails = '/campagne-details';
  static const String postDetails = '/post-details';
  static const String setting = '/beneficiaire-settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const Connexion());
      case home:
        return MaterialPageRoute(builder: (_) => const BeneficiaireHome());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileBeneficiaire());
      case gestionPostDemande:
        return MaterialPageRoute(builder: (_) => const GestionPostDemande());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPageBeneficiaire());
      case map:
        return MaterialPageRoute(builder: (_) => const MapPageBeneficiaire());
      case campagneDetails:
        return MaterialPageRoute(builder: (_) => CampagneDetailsPage(campagne: args?['campagne']));
      case postDetails:
        return MaterialPageRoute(builder: (_) => PostDetailsPage(post: args?['post']));
      case setting:
        return MaterialPageRoute(builder: (_) => const SettingsPageBeneficiaire());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))),
        );
    }
  }
}