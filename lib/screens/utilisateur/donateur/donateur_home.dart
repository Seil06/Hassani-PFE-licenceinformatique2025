import 'package:flutter/material.dart';
import 'package:myapp/routes/routes.dart';
import 'package:myapp/widgets/pages/feed_page.dart';
import 'package:myapp/widgets/buttons/sign_out_button.dart';

class DonateurHome extends StatelessWidget {
  const DonateurHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Donateur'),
        actions: [
          SignOutButton(routeAfterSignOut: RouteGenerator.login),
        ],
      ),
      body: const FeedPage(userType: 'donateur'),
    );
  }
}