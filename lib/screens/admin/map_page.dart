import 'package:flutter/material.dart';

class MapPageAdmin extends StatefulWidget {
  const MapPageAdmin({Key? key}) : super(key: key);

  @override
  _MapPageAdminState createState() => _MapPageAdminState();
}

class _MapPageAdminState extends State<MapPageAdmin> {
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