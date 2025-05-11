import 'package:flutter/material.dart';

class ProfileBeneficiaire extends StatelessWidget {
  const ProfileBeneficiaire({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Beneficiaire'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: const Text(
          'Beneficiary Profile Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}