import 'package:flutter/material.dart';

class GestionAvertissement extends StatefulWidget {
  const GestionAvertissement({Key? key}) : super(key: key);

  @override
  _GestionAvertissementState createState() => _GestionAvertissementState();
}

class _GestionAvertissementState extends State<GestionAvertissement> {
  @override
  Widget build(BuildContext context) {
    // your code here
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion Avertissement'),
      ),
      body: Center(
        child: Text('Gestion Avertissement Content'),
      ),
    );
  }
}