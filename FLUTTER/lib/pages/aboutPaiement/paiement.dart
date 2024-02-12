// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './../aboutRestaurant/acceuil.dart';

class PaymentScreen extends StatefulWidget {
  final String selectedRetraitMode;
  final Restaurant restaurant;
  final TimeOfDay selectedTime;

  const PaymentScreen({
    Key? key,
    required this.selectedRetraitMode,
    required this.restaurant,
    required this.selectedTime,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}


class _PaymentScreenState extends State<PaymentScreen> {
  double montantAPayer = 0.0; // Initialisez le montant à payer

  @override
  void initState() {
    super.initState();
    // Appelez une fonction pour récupérer le montant du panier
    getMontantPanier();
  }

  Future<void> getMontantPanier() async {
    const String apiUrl = 'http://localhost:3000/recupererMontantPanier'; // Mettez à jour l'URL de l'API

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?email=${widget.email}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          setState(() {
            // Mettez à jour le montant à payer avec la valeur du panier
            montantAPayer = responseData['montantPanier'];
          });
        } else {
          print('Erreur lors de la récupération du montant du panier: ${responseData['message']}');
        }
      } else {
        print('Erreur lors de la requête au serveur: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Erreur inattendue: $error');
    }
  }

  Future<void> processPayment() async {
    const String apiUrl = 'http://localhost:3000/recupererCarte'; // Mettez à jour l'URL de l'API

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?email=${widget.email}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Le paiement a été traité avec succès
          final paymentResponse = await http.post(
            Uri.parse('http://localhost:3000/effecuterPaiement'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'montant': montantAPayer, // Utilisez le montant du panier récupéré
              'carte': responseData['carte'], // Utilisez le détail de la carte récupérée
            }),
          );

          final paymentData = jsonDecode(paymentResponse.body);

          if (paymentData['success'] == true) {
            print('Paiement réussi');
          } else {
            print('Erreur lors du paiement: ${paymentData['message']}');
          }
        } else {
          print('Erreur lors de la récupération de la carte: ${responseData['message']}');
        }
      } else {
        print('Erreur lors de la requête au serveur: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Erreur inattendue: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: Text(widget.restaurant.name),
      ),
      body: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
           
              Text('Heure de retrait : ${widget.selectedTime.format(context)}'),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Appeler la fonction de traitement du paiement
              processPayment();
            },
            child: const Text('Valider la commande'),
          ),
        ], // Correction de la balise < ici
      ),
    );
  }
}
