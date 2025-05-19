import 'package:flutter/material.dart';

class MapPageBeneficiaire extends StatefulWidget {
  const MapPageBeneficiaire({Key? key}) : super(key: key);

  @override
  _MapPageBeneficiaireState createState() => _MapPageBeneficiaireState();
}

class _MapPageBeneficiaireState extends State<MapPageBeneficiaire> {
  @override
  Widget build(BuildContext context) {
    // your code here
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Center(
        child: Text('Map Content'),
      ),
    );
  }
}