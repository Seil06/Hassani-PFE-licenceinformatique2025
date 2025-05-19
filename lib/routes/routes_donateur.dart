import 'package:flutter/material.dart';
import 'package:myapp/screens/utilisateur/donateur/donateur_home.dart';
import 'package:myapp/screens/utilisateur/donateur/profile_donateur.dart';
import 'package:myapp/screens/utilisateur/donateur/Gestion_post.dart';
import 'package:myapp/screens/utilisateur/donateur/calculateur_zakat_screen.dart';
import 'package:myapp/screens/auth/connexion.dart';
import 'package:myapp/screens/utilisateur/donateur/search_page.dart';
import 'package:myapp/widgets/pages/campagne_page.dart';
import 'package:myapp/screens/utilisateur/donateur/map_page.dart';
import 'package:myapp/widgets/pages/post_page.dart';
import 'package:myapp/screens/utilisateur/donateur/seetings_page.dart';

class RouteGeneratorDonateur {
  static const String login = '/login';
  static const String home = '/donateur-home';
  static const String profile = '/donateur-profile';
  static const String gestionPostoffreEtInvite = '/gestion-post';
  static const String calculateurZakat = '/calculateur-zakat';
  static const String search = '/donatur-search';
  static const String map = '/doanteur-map';
  static const String campagneDetails = '/campagne-details';
  static const String postDetails = '/post-details';
  static const String setting = '/doanteur-settings';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const Connexion());
      case home:
        return MaterialPageRoute(builder: (_) => const DonateurHome());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileDonateur());
      case gestionPostoffreEtInvite:
        return MaterialPageRoute(
          builder: (_) => GestionPost(
            idActeur: args?['idActeur'],
            userData: args?['userData'],
          ),
        );
      case calculateurZakat:
        return MaterialPageRoute(builder: (_) => const CalculateurZakatScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPageDonateur());
      case map:
        return MaterialPageRoute(builder: (_) => const MapPageDonateur());
      case campagneDetails:
        return MaterialPageRoute(builder: (_) => CampagneDetailsPage(campagne: args?['campagne']));
      case postDetails:
        return MaterialPageRoute(builder: (_) => PostDetailsPage(post: args?['post']));
      case setting:
        return MaterialPageRoute(builder: (_) => const SettingsPageDonateur());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))),
        );
    }
  }
}





