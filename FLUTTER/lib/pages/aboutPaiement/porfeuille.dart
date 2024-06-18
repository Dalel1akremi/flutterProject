// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api

import 'dart:convert';
import 'package:demo/pages/aboutRestaurant/RestaurantList.dart';
import 'package:demo/pages/aboutUser/auth_provider.dart';
import 'package:demo/pages/aboutUser/profile.dart';
import 'package:demo/pages/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class Portefeuille extends StatefulWidget {
  const Portefeuille({super.key});

  @override
  _PortefeuilleState createState() => _PortefeuilleState();
}

class _PortefeuilleState extends State<Portefeuille> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationDateController =
      TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Panier panier = Panier();
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
void initState() {
  super.initState();
  expirationDateController.addListener(() {
    final text = expirationDateController.text;
    if (text.length == 2 && !text.contains('/')) {
      expirationDateController.value = expirationDateController.value.copyWith(
        text: '$text/',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    Text('Email: ${authProvider.email}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('Portefeuille payline'),
      ),
     body: SingleChildScrollView(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: MediaQuery.of(context).size.width, 
        height: MediaQuery.of(context).size.width / 2,  
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('images/paiement.png'), 
            fit: BoxFit.contain,  
          ),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ), 
      const Divider(),
      const Text(
        'Enregistre ma carte',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
      const SizedBox(height: 8.0),  
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              TextFormField(
                controller: cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de carte',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: validateCardNumber,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16)
                ],
              ),
             TextFormField(
    controller: expirationDateController,
    decoration: const InputDecoration(
      labelText: 'Date d\'expiration (MM/YY)',
      prefixIcon: Icon(Icons.calendar_today),
    ),
    validator: validateExpirationDate,
    keyboardType: TextInputType.number,
    inputFormatters: [LengthLimitingTextInputFormatter(5)],
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4)
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      await sendPaymentRequest();
                      panier.origine = 'profil';
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RestaurantScreen(index: 2,)),
         
        );
                    } catch (error) {
                      print('Erreur lors du paiement: $error');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  'Enregistrer la carte',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16.0),
         ],
            ),
          ),
        ],
      ),
    ),
  );
}
Future<void> sendPaymentRequest() async {
  String myIp = Global.myIp;
   SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');
  String apiUrl =
      'http://$myIp:3000/porfeuille?email=$email';

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

      if (responseData['success']) {
         Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilPage()),
          );
       
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
            backgroundColor: Colors.red,
          ),
        );
        throw Exception(responseData['message']);
      }
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['message']),
          backgroundColor: Colors.red,
        ),
      );
      throw Exception(responseData['message']);
    } else {
      throw Exception(
          "Erreur lors de la requête HTTP : ${response.statusCode}");
    }
  } catch (error) {
    print("Erreur lors de la requête HTTP : $error");
    rethrow;
  }
}

}
