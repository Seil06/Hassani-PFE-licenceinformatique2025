import 'package:flutter/material.dart';

class GestionPostDemande extends StatefulWidget {
  const GestionPostDemande({Key? key}) : super(key: key);

  @override
  _GestionPostDemandeState createState() => _GestionPostDemandeState();
}

class _GestionPostDemandeState extends State<GestionPostDemande> {
  @override
  Widget build(BuildContext context) {
    // your code here
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Postes de Demande'),
      ),
      body: Center(
        child: Text('Gestion des Postes de Demande Content'),
      ),
    );
  }
}