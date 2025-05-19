import 'package:flutter/material.dart';

class GestionPostOfficiel extends StatefulWidget {
  const GestionPostOfficiel({Key? key}) : super(key: key);

  @override
  _GestionPostOfficielState createState() => _GestionPostOfficielState();
}

class _GestionPostOfficielState extends State<GestionPostOfficiel> {
  @override
  Widget build(BuildContext context) {
    // your code here
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion Post Officiel'),
      ),
      body: Center(
        child: Text('Gestion Post Officiel Content'),
      ),
    );
  }
}