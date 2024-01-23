import 'package:flutter/material.dart';

class NouveauPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau Mot de Passe'),
        backgroundColor: Color.fromARGB(222, 212, 133, 14),
      ),
      body: Center(
        child: Text(
          'Bienvenue sur la page Nouveau Mot de Passe!',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}