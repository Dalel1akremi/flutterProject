import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // Import this

class Portefeuille extends StatefulWidget {
  final String email;
  const Portefeuille({Key? key, required this.email}) : super(key: key);

  @override
  _PortefeuilleState createState() => _PortefeuilleState();
}

class _PortefeuilleState extends State<Portefeuille> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir le numéro de carte';
    }
    if (value.length != 16) {
      return 'Le numéro de carte doit contenir 16 chiffres';
    }
    if (!value.startsWith('41')) {
      return 'Le numéro de carte doit commencer par 41';
    }
    return null;
  }

String? validateExpirationDate(String? value) {
  if (value == null || value.isEmpty) {
    return 'Veuillez saisir la date d\'expiration';
  }

  final RegExp regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');

  if (!regex.hasMatch(value)) {
    return 'Format de date invalide. Utilisez MM/YY';
  }

  final List<String> parts = value.split('/');
  final int month = int.tryParse(parts[0]) ?? 0;
  final int year = int.tryParse(parts[1]) ?? 0;

  final DateTime now = DateTime.now();
  final int currentYear = now.year % 100;
  final int currentMonth = now.month;

  if (year < currentYear || (year == currentYear && month < currentMonth)) {
    return 'La date d\'expiration est déjà passée';
  }

  if (month < 1 || month > 12) {
    return 'Mois invalide. Utilisez un mois entre 01 et 12';
  }

  return null;
}


  String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir le CVV';
    }

    final RegExp regex = RegExp(r'^\d{4}$');

    if (!regex.hasMatch(value)) {
      return 'Le CVV doit contenir exactement 4 chiffres';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('Portefeuille payline'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de carte',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: validateCardNumber,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
              ),
              TextFormField(
                controller: expirationDateController,
                decoration: const InputDecoration(
                  labelText: 'Date d\'expiration (MM/YY)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: validateExpirationDate,
                keyboardType: TextInputType.number,
                inputFormatters: [ LengthLimitingTextInputFormatter(5)],
              ),
              TextFormField(
                controller: cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: validateCVV,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                  
                    await sendPaymentRequest();
                  }
                },
                child: const Text('Enregistrer la carte'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendPaymentRequest() async {
    String apiUrl = 'http://localhost:3000/porfeuille?email=${Uri.encodeQueryComponent(widget.email)}';

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
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception("Erreur lors de la requête HTTP : ${response.statusCode}");
      }
    } catch (error) {
      print("Erreur lors de la requête HTTP : $error");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: const Text('Erreur lors de la requête HTTP'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
