import 'package:flutter/material.dart';
import 'package:myapp/routes/routes_donateur.dart';
import 'package:myapp/routes/routes_admin.dart';
import 'package:myapp/routes/routes_association.dart';
import 'package:myapp/routes/routes_beneficiaire.dart';
import 'package:myapp/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/main.dart';
import 'package:myapp/routes/routes.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'inscription.dart';

class Connexion extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const Connexion(),
      );

  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = emailController.text.trim().toLowerCase();
      final password = passwordController.text.trim();

      // Sign in with Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Query the acteur table to determine the user type
      final acteurResponse = await supabase
          .from('acteur')
          .select('type_acteur, id_acteur')
          .eq('supabase_user_id', response.user!.id)
          .single();

      final typeActeur = acteurResponse['type_acteur'] as String;
      final idActeur = acteurResponse['id_acteur'] as int;

      if (typeActeur == 'admin') {
        Navigator.pushReplacementNamed(context, RouteGeneratorAdmin.home);
      } else {
        final userResponse = await supabase
            .from('utilisateur')
            .select('type_utilisateur')
            .eq('id_acteur', idActeur)
            .single();

        final typeUtilisateur = userResponse['type_utilisateur'] as String;

        switch (typeUtilisateur) {
          case 'donateur':
            Navigator.pushReplacementNamed(context, RouteGeneratorDonateur.home);
            break;
          case 'association':
            Navigator.pushReplacementNamed(context, RouteGeneratorAssociation.home);
            break;
          case 'beneficiaire':
            Navigator.pushReplacementNamed(context, RouteGeneratorBeneficiaire.home);
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Type d’utilisateur inconnu')),
            );
        }
      }
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur inattendue s’est produite'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBackground(
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Transparent to show gradient
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 20,
                vertical: 20,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: LightAppPallete.background,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.favorite,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Se connecter',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connectez-vous à Mazal Kayn Elkhir',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email requis';
                          } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return "Format d'email invalide";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mot de passe requis';
                          } else if (value.length < 8) {
                            return 'Le mot de passe doit avoir au moins 8 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, RouteGenerator.forgetPw);
                          },
                          child: const Text('Mot de passe oublié ?'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          child: Text(_isLoading ? 'Connexion...' : 'Se connecter'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, Inscription.route());
                        },
                        child: const Text('Pas de compte ? S\'inscrire'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}