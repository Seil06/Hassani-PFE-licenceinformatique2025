import 'package:flutter/material.dart';
import 'package:myapp/routes/routes.dart';
import 'package:myapp/widgets/buttons/sign_out_button.dart';
import 'package:myapp/widgets/buttons/modify_profile_button.dart'; // Add this import

class SettingsPageAssociation extends StatefulWidget {
  const SettingsPageAssociation({Key? key}) : super(key: key);

  @override
  _SettingsPageAssociationState createState() => _SettingsPageAssociationState();
}

class _SettingsPageAssociationState extends State<SettingsPageAssociation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          SignOutButton(routeAfterSignOut: RouteGenerator.login),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ModifyProfileButton(), // Use the button here
            SizedBox(height: 16),
            Text('Settings Content'),
          ],
        ),
      ),
    );
  }
}