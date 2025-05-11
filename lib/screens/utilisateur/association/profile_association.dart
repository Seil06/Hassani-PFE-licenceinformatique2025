import 'package:flutter/material.dart';

class ProfileAssociation extends StatelessWidget {
  const ProfileAssociation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Association'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: const Text(
          'Association Profile Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}