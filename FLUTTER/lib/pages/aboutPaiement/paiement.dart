import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Remplacez ces valeurs par les informations de paiement réelles
  double amount = 100.0;
  String currency = 'usd';
  String paymentMethod = 'pm_card_visa';

  Future<void> processPayment() async {
    final String apiUrl = 'http://localhost:3000/process_payment'; // Remplacez par l'URL de votre serveur

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'paymentMethod': paymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        // Le paiement a été traité avec succès
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          // Gérer le succès du paiement
          print('Paiement réussi');
        } else {
          // Gérer l'échec du paiement
          print('Erreur lors du paiement');
        }
      } else {
        // Gérer les erreurs de requête vers le serveur
        print('Erreur lors de la requête au serveur: ${response.reasonPhrase}');
      }
    } catch (error) {
      // Gérer les erreurs d'exception
      print('Erreur inattendue: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Processing Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Appeler la fonction de traitement du paiement
            processPayment();
          },
          child: Text('Process Payment'),
        ),
      ),
    );
  }
}
