import 'package:flutter/material.dart';
import 'package:myapp/routes/routes.dart';
import 'package:myapp/widgets/pages/feed_page.dart';
import 'package:myapp/widgets/buttons/sign_out_button.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Admin'),
        actions: [
          SignOutButton(routeAfterSignOut: RouteGenerator.login),
        ],
      ),
      body: const FeedPage(userType: 'admin'), 
    );
  }
}