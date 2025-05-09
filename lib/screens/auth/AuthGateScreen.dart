import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:myapp/routes/routes.dart';
import 'package:myapp/theme/app_pallete.dart';

class AuthGateScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const AuthGateScreen(),
      );

  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Delay slightly to ensure Supabase client is ready
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(context).pushReplacementNamed(RouteGenerator.login);
    } else {
      try {
        // Query the acteur table to determine the user type
        final response = await supabase
            .from('acteur')
            .select('type_acteur, id_acteur')
            .eq('supabase_user_id', session.user.id)
            .single();

        final typeActeur = response['type_acteur'] as String;
        final idActeur = response['id_acteur'] as int;

        if (typeActeur == 'admin') {
          Navigator.of(context).pushReplacementNamed(RouteGenerator.adminHome);
        } else {
          final userResponse = await supabase
              .from('utilisateur')
              .select('type_utilisateur')
              .eq('id_acteur', idActeur)
              .single();

          final typeUtilisateur = userResponse['type_utilisateur'] as String;

          switch (typeUtilisateur) {
            case 'donateur':
              Navigator.of(context).pushReplacementNamed(RouteGenerator.donateurHome);
              break;
            case 'association':
              Navigator.of(context).pushReplacementNamed(RouteGenerator.associationHome);
              break;
            case 'beneficiaire':
              Navigator.of(context).pushReplacementNamed(RouteGenerator.beneficiaireHome);
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Type d’utilisateur inconnu'))
              );
              Navigator.of(context).pushReplacementNamed(RouteGenerator.login);
          }
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la vérification du profil'))
        );
        Navigator.of(context).pushReplacementNamed(RouteGenerator.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightAppPallete.primaryDark,
      body: const Center(
        child: CircularProgressIndicator(
          color: LightAppPallete.background,
        ),
      ),
    );
  }
}