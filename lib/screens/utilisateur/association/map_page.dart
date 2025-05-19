import 'package:flutter/material.dart';

class MapPageAssociation extends StatefulWidget {
  const MapPageAssociation({Key? key}) : super(key: key);

  @override
  _MapPageAssociationState createState() => _MapPageAssociationState();
}

class _MapPageAssociationState extends State<MapPageAssociation> {
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