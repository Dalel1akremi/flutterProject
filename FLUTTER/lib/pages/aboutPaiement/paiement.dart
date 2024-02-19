import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './../aboutRestaurant/acceuil.dart';


// ignore: must_be_immutable
class PaymentScreen extends StatefulWidget {
   String selectedRetraitMode;
  final Restaurant restaurant;
  final TimeOfDay selectedTime;
 final int totalPrice;
  PaymentScreen({
    Key? key,
    required this.totalPrice,
    required this.selectedRetraitMode,
    required this.restaurant,
    required this.selectedTime,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  double montantAPayer = 0.0; // Initialisez le montant à payer
  String selectedRetraitMode = '';

  TimeOfDay? newSelectedTime;

  @override
  void initState() {
    super.initState();
    // Appelez une fonction pour récupérer le montant du panier
    getMontantPanier();
    print('Selected Retrait Mode: ${widget.selectedRetraitMode}');
  }

  Future<void> getMontantPanier() async {
    const String apiUrl =
        'http://localhost:3000/recupererMontantPanier'; // Mettez à jour l'URL de l'API

    try {
      final response = await http.get(
        Uri.parse('$apiUrl'),
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
          print(
              'Erreur lors de la récupération du montant du panier: ${responseData['message']}');
        }
      } else {
        print('Erreur lors de la requête au serveur: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Erreur inattendue: $error');
    }
  }

  Future<void> processPayment() async {
    const String apiUrl =
        'http://localhost:3000/recupererCarte'; // Mettez à jour l'URL de l'API

    try {
      final response = await http.get(
        Uri.parse('$apiUrl'),
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
              'montant':
                  montantAPayer, // Utilisez le montant du panier récupéré
              'carte': responseData['carte'],
              // Utilisez le détail de la carte récupérée
            }),
          );

          final paymentData = jsonDecode(paymentResponse.body);

          if (paymentData['success'] == true) {
            print('Paiement réussi');
          } else {
            print('Erreur lors du paiement: ${paymentData['message']}');
          }
        } else {
          print(
              'Erreur lors de la récupération de la carte: ${responseData['message']}');
        }
      } else {
        print('Erreur lors de la requête au serveur: ${response.reasonPhrase}');
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
      // Add other cases as needed
      default:
        return value;
    }
  }

  Future<void> showEditDialog() async {
    Map<String, dynamic>? newSelections = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedRetraitMode = widget.selectedRetraitMode;
        TimeOfDay? selectedTime = newSelectedTime ?? widget.selectedTime;

        return AlertDialog(
          title: Text('Modifier la commande'),
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
                  // Affichez le sélecteur d'heure et mettez à jour la nouvelle heure
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
                child: Text('Modifier l\'heure'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
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
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (newSelections != null) {
      setState(() {
        widget.selectedRetraitMode = newSelections['retraitMode'];
        newSelectedTime = newSelections['selectedTime'];
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
                        'Commande ${mapRetraitMode(widget.selectedRetraitMode)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Heure de retrait : ${newSelectedTime ?? widget.selectedTime.format(context)}',
                          ),
                          Divider(), // Divider after "Heure de retrait"
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    showEditDialog();
                  },
                ),
              ],
            ),
          ),
          Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total', // Replace with your variable
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                '\$${montantAPayer.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Divider(), // Divider after "Total"
          Spacer(), // Spacer to push the button to the bottom
          Container(
            width: double.infinity,
            color: Colors.green, // Set the background color to green
            child: ElevatedButton(
              onPressed: () {
                // Utilize the processPayment function
                processPayment();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green, // Set the button color to green
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
