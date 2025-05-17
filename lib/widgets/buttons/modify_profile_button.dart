import 'package:flutter/material.dart';
import 'package:myapp/routes/routes_donateur.dart';
import 'package:myapp/theme/app_pallete.dart';

class ModifyProfileButton extends StatelessWidget {
  const ModifyProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, RouteGeneratorDonateur.setting);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: LightAppPallete.accentDark,
        foregroundColor: Colors.white,
      ),
      child: const Text('Modifier le profil'),
    );
  }
}