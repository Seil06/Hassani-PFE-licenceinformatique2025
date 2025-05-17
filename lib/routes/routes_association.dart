import 'package:flutter/material.dart';
import 'package:myapp/screens/utilisateur/association/association_home.dart';
import 'package:myapp/screens/utilisateur/association/profile_association.dart';
import 'package:myapp/screens/utilisateur/association/Gestion_campagne.dart';
import 'package:myapp/screens/auth/connexion.dart';
import 'package:myapp/widgets/pages/campagne_page.dart';
import 'package:myapp/widgets/pages/map_page.dart';
import 'package:myapp/widgets/pages/post_page.dart';
import 'package:myapp/widgets/pages/search_page.dart';
import 'package:myapp/widgets/pages/seetings_page.dart';



class RouteGeneratorAssociation {
  static const String login = '/association-login';
  static const String home = '/association-home';
  static const String profile = '/association-profile';
  static const String gestionPostCampagne = '/gestion-campagne';
  static const String search = '/search';
  static const String map = '/map';
  static const String campagneDetails = '/campagne-details';
  static const String postDetails = '/post-details';
  static const String setting = '/settings';

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
        return MaterialPageRoute(builder: (_) => const SearchPage());
      case map:
        return MaterialPageRoute(builder: (_) => const MapPage());
      case campagneDetails:
        return MaterialPageRoute(builder: (_) => CampagneDetailsPage(campagne: args?['campagne']));
      case postDetails:
        return MaterialPageRoute(builder: (_) => PostDetailsPage(post: args?['post']));
      case setting:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))),
        );
    }
  }
}