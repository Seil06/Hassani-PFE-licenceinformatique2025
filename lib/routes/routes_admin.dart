import 'package:flutter/material.dart';
import 'package:myapp/screens/admin/Gestion_avertissement.dart';
import 'package:myapp/screens/admin/Gestion_post_officiel.dart';
import 'package:myapp/screens/admin/admin_home.dart';
import 'package:myapp/screens/admin/profile_admin.dart';
import 'package:myapp/screens/auth/connexion.dart';
import 'package:myapp/widgets/pages/campagne_page.dart';
import 'package:myapp/screens/admin/map_page.dart';
import 'package:myapp/widgets/pages/post_page.dart';
import 'package:myapp/screens/admin/search_page.dart';
import 'package:myapp/screens/admin/seetings_page.dart';

// Route generator for admin-specific navigation
class RouteGeneratorAdmin {
  static const String login = '/login';
  static const String home = '/admin-home';
  static const String profile = '/admin-profile';
  static const String search = '/admin-search';
  static const String map = '/admin-map';
  static const String campagneDetails = '/campagne-details';
  static const String gestionPostOfficiel = '/gestion-post-officiel';
  static const String gestionAvertissement = '/gestion-avertissement';
  static const String gestionUtilisateur = '/gestion-utilisateur';
  static const String postDetails = '/post-details';
  static const String setting = '/admin-settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const Connexion());
      case home:
        return MaterialPageRoute(builder: (_) => const AdminHome());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileAdmin());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPageAdmin());
      case map:
        return MaterialPageRoute(builder: (_) => const MapPageAdmin());
      case gestionPostOfficiel:
        return MaterialPageRoute(builder: (_) => const GestionPostOfficiel());
      case gestionAvertissement:
        return MaterialPageRoute(builder: (_) => const GestionAvertissement());
      case campagneDetails:
        return MaterialPageRoute(builder: (_) => CampagneDetailsPage(campagne: args?['campagne']));
      case postDetails:
        return MaterialPageRoute(builder: (_) => PostDetailsPage(post: args?['post']));
      case setting:
        return MaterialPageRoute(builder: (_) => const SettingsPageAdmin());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))),
        );
    }
  }
}