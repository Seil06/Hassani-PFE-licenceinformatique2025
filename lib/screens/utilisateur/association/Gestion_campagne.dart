import 'package:flutter/material.dart';

class GestionCampagne extends StatefulWidget {
  const GestionCampagne({Key? key}) : super(key: key);

  @override
  _GestionCampagneState createState() => _GestionCampagneState();
}

class _GestionCampagneState extends State<GestionCampagne> {
  @override
  Widget build(BuildContext context) {
    // your code here
    return Scaffold(
      appBar: AppBar(
        title: Text('GestionCampagne'),
      ),
      body: Center(
        child: Text('GestionCampagne Content'),
      ),
    );
  }
}