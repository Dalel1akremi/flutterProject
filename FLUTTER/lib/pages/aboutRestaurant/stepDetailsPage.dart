import 'package:flutter/material.dart';

class StepDetailsPage extends StatelessWidget {
  final String nomMenu;
  final String img;

  const StepDetailsPage({Key? key, required this.nomMenu, required this.img})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'étape'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              img,
              width: 200, // Adjust the width as needed
              height: 150, // Adjust the height as needed
            ),
            SizedBox(height: 20),
            Text(
              'Nom du menu: $nomMenu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
