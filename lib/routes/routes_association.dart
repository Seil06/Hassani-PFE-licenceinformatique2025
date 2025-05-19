import 'package:flutter/material.dart';
import 'package:myapp/screens/utilisateur/association/association_home.dart';
import 'package:myapp/screens/utilisateur/association/profile_association.dart';
import 'package:myapp/screens/utilisateur/association/Gestion_campagne.dart';
import 'package:myapp/screens/auth/connexion.dart';
import 'package:myapp/widgets/pages/campagne_page.dart';
import 'package:myapp/screens/utilisateur/association/map_page.dart';
import 'package:myapp/widgets/pages/post_page.dart';
import 'package:myapp/screens/utilisateur/association/search_page.dart';
import 'package:myapp/screens/utilisateur/association/seetings_page.dart';


class RouteGeneratorAssociation {
  static const String login = '/login';
  static const String home = '/association-home';
  static const String profile = '/association-profile';
  static const String gestionPostCampagne = '/gestion-campagne';
  static const String search = '/association-search';
  static const String map = '/association-map';
  static const String campagneDetails = '/campagne-details';
  static const String postDetails = '/post-details';
  static const String setting = '/association-settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const Connexion());
      case home:
        return MaterialPageRoute(builder: (_) => const AssociationHome());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileAssociation());
      case gestionPostCampagne:
        return MaterialPageRoute(builder: (_) => const GestionCampagne());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPageAssociation());
      case map:
        return MaterialPageRoute(builder: (_) => const MapPageAssociation());
      case campagneDetails:
        return MaterialPageRoute(builder: (_) => CampagneDetailsPage(campagne: args?['campagne']));
      case postDetails:
        return MaterialPageRoute(builder: (_) => PostDetailsPage(post: args?['post']));
      case setting:
        return MaterialPageRoute(builder: (_) => const SettingsPageAssociation());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))),
        );
    }
  }
}