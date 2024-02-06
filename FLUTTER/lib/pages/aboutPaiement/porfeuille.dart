import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Portefeuille extends StatefulWidget {
  @override
  _PortefeuilleState createState() => _PortefeuilleState();
}

class _PortefeuilleState extends State<Portefeuille> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationDateController =
      TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: Text('Portfeuille payline'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           TextField(
  controller: cardNumberController,
  decoration: InputDecoration(
    labelText: 'Numéro de carte',
    prefixIcon: Icon(Icons.credit_card), // Icône de carte de crédit
  ),
),
TextField(
  controller: expirationDateController,
  decoration: InputDecoration(
    labelText: 'Date d\'expiration (MM/YY)',
    prefixIcon: Icon(Icons.calendar_today), // Icône du calendrier
  ),
),
TextField(
  controller: cvvController,
  decoration: InputDecoration(
    labelText: 'CVV',
    prefixIcon: Icon(Icons.lock), // Icône de verrou
  ),
),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await sendPaymentRequest();
              },
              child: Text('Enregistrer la carte'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendPaymentRequest() async {
    final String apiUrl = 'http://localhost:3000/porfeuille';

    Map<String, dynamic> paymentData = {
      "cardNumber": cardNumberController.text,
      "expirationDate": expirationDateController.text,
      "cvv": cvvController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(responseData['success'] ? 'Succès' : 'Erreur'),
              content: Text(responseData['message']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception(
            "Erreur lors de la requête HTTP : ${response.statusCode}");
      }
    } catch (error) {
      print("Erreur lors de la requête HTTP : $error");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Erreur lors de la requête HTTP'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
