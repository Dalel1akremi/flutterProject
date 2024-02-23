// paiement.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './../aboutRestaurant/acceuil.dart';
import './../aboutRestaurant/commande.dart';
import './../global.dart';

class PaymentScreen extends StatefulWidget {

  final List<Article> panier;
  final int totalPrice;
  PaymentScreen({
    Key? key,
    required this.totalPrice,
    required this.panier,
  }) : super(key: key);
  
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  double montantAPayer = 0.0;
  TimeOfDay? newSelectedTime;
  String? newSelectedMode;
  Panier panier = Panier();

  @override
  void initState() {
    super.initState();
  }

  Future<void> processPayment() async {
    final email = 'yakinebenali5@gmail.com';
    try {
      final paymentResponse = await http.post(
        Uri.parse('http://localhost:3000/recupererCarteParId?email=$email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'montant': widget.totalPrice,
        }),
      );

      final paymentData = jsonDecode(paymentResponse.body);

      if (paymentData['success'] == true) {
        print('Paiement réussi');
        panier.printPanier();
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CommandeApp(),
          ),
        );
      } else {
        print('Erreur lors du paiement: ${paymentData['message']}');
      }
    } catch (error) {
      print('Erreur inattendue: $error');
    }
  }

  String mapRetraitMode(String value) {
    switch (value) {
      case 'Option 1':
        return 'A Emporter';
      case 'Option 2':
        return 'Sur place';
      case 'Option 3':
        return 'en livraison';
      default:
        return value;
    }
  }

  Future<void> showEditDialog() async {
    Map<String, dynamic>? newSelections = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedRetraitMode =newSelectedMode?? panier.getSelectedRetraitMode() ?? "";
        TimeOfDay? selectedTime = newSelectedTime ?? panier.selectedTime;
     

        return AlertDialog(
          title: const Text('Modifier la commande'),
          content: Column(
            children: [
              DropdownButton<String>(
                value: selectedRetraitMode,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRetraitMode = newValue!;
                  });
                },
                items: <String>['Option 1', 'Option 2', 'Option 3']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(mapRetraitMode(value)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      selectedTime = pickedTime;
                    });
                  }
                },
                child: const Text('Modifier l\'heure'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  {
                    'retraitMode': selectedRetraitMode,
                    'selectedTime': selectedTime,
                  },
                );
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (newSelections != null) {
      setState(() {
        newSelectedMode = newSelections['retraitMode'];
        newSelectedTime = newSelections['selectedTime'];
        panier.updateCommandeDetails(panier.getSelectedRetraitMode() ?? '',
            newSelectedTime ?? panier.getCurrentSelectedTime());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text("Récapitulatif de la commande "),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
  'Commande ${mapRetraitMode(newSelectedMode ?? panier.getSelectedRetraitMode() ?? '')}',
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Heure de retrait : ${newSelectedTime ?? panier.getCurrentSelectedTime().format(context)}',
                          ),
                          const Divider(),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showEditDialog();
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '\$${widget.totalPrice}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(),
          const Spacer(),
          Container(
            width: double.infinity,
            color: Colors.green,
            child: ElevatedButton(
              onPressed: () {
                processPayment();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Valider la commande',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
