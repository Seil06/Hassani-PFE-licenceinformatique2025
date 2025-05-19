import 'package:flutter/material.dart';
import 'package:myapp/routes/routes.dart';
import 'package:myapp/widgets/buttons/sign_out_button.dart';
import 'package:myapp/widgets/buttons/modify_profile_button.dart'; 

class SettingsPageAdmin extends StatefulWidget {
  const SettingsPageAdmin({Key? key}) : super(key: key);

  @override
  _SettingsPageAdminState createState() => _SettingsPageAdminState();
}

class _SettingsPageAdminState extends State<SettingsPageAdmin> {
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