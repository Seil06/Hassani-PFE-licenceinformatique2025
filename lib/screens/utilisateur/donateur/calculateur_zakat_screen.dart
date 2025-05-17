import 'package:flutter/material.dart';

class CalculateurZakatScreen extends StatefulWidget {
  const CalculateurZakatScreen({Key? key}) : super(key: key);

  @override
  _CalculateurZakatScreenState createState() => _CalculateurZakatScreenState();
}

class _CalculateurZakatScreenState extends State<CalculateurZakatScreen> {
  @override
  Widget build(BuildContext context) {
    // your code here
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculateur Zakat'),
      ),
      body: Center(
        child: Text('Calculateur Zakat Content'),
      ),
    );
  }
}