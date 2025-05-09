import 'package:flutter/material.dart';
import 'package:myapp/main.dart';

class SignOutButton extends StatelessWidget {
  final String routeAfterSignOut;

  const SignOutButton({super.key, required this.routeAfterSignOut});

  Future<void> _signOut(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      Navigator.pushReplacementNamed(context, routeAfterSignOut);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déconnexion réussie !')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion : ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Se déconnecter',
      onPressed: () => _signOut(context),
    );
  }
}