// ignore_for_file: avoid_print, library_private_types_in_public_api, use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './../global.dart';
import './../aboutUser/auth_provider.dart';
class CreditCard {
  final String fullCardNumber;
  final String cvv; // Ajouter le champ CVV
  String get maskedCardNumber {
    return '*' * (fullCardNumber.length - 4) + fullCardNumber.substring(fullCardNumber.length - 4);
  }

  CreditCard(this.fullCardNumber, this.cvv); // Mettre à jour le constructeur
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    Key? key,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  double montantAPayer = 0.0;
  TimeOfDay? newSelectedTime;
  String? newSelectedMode;
  Panier panier = Panier();
  AuthProvider authProvider = AuthProvider();
  bool useCreditCard = false;
  bool payInStore = false;
  String? selectedPaymentMethod;
  bool enableInStoreCheckbox = false;
   List<CreditCard> userCreditCards = [];  // Variable pour activer/désactiver la case à cocher "En magasin"
 String? selectedCreditCard;
// Définir une fonction pour vérifier si l'une des options de la liste de sélection radio est sélectionnée
bool isPaymentMethodSelected() {
  return selectedPaymentMethod != null;
}
  @override
  void initState() {
    super.initState();
    initAuthProvider();
    fetchUserCreditCards();
  }
Future<void> showCVVDialog(String cvv) async {
  String enteredCVV = ''; // Variable pour stocker le code confidentiel entré
  final TextEditingController controller = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Entrez votre code confidentiel'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true, // Masquer le texte saisi
          onChanged: (value) {
            enteredCVV = value;
          },
          decoration: const InputDecoration(
            hintText: 'Code confidentiel',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(enteredCVV); // Renvoyer le code confidentiel entré
            },
            child: const Text('Valider'),
          ),
        ],
      );
    },
  ).then((value) {
    // Vérifiez le code confidentiel saisi après la fermeture de la boîte de dialogue
    if (value != null && value == cvv) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Code correcte'),
            content: const Text('Merci pour votre confiance.'),
            actions: <Widget>[
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Code confidentiel incorrect'),
            content: const Text('Veuillez réessayer !'),
            actions: <Widget>[
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
  });
}

Future<void> fetchUserCreditCards() async {
  // Retrieve user's email from AuthProvider
  String? userEmail = authProvider.email;
  if (userEmail != null) {
    try {
      var response = await http.get(Uri.parse('http://localhost:3000/recupererCartesUtilisateur?email=$userEmail'));
      if (response.statusCode == 200) {
        // Parse JSON response and update userCreditCards list
        var responseData = json.decode(response.body);
        if (responseData is Map && responseData.containsKey('cards')) {
          setState(() {
            userCreditCards = (responseData['cards'] as List)
                .map((data) => CreditCard(data['cardNumber'], data['cvv']))
                .toList();
          });
        } else {
          throw Exception('Invalid response format: $responseData');
        }
      } else {
        throw Exception('Failed to load user credit cards: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user credit cards: $e');
    }
  }
}

 Future<void> initAuthProvider() async {
    await authProvider.initTokenFromStorage();
    setState(() {});
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
        String? selectedRetraitMode =
            newSelectedMode ?? panier.getSelectedRetraitMode() ?? "";
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
                    DateTime currentTime = DateTime.now();
                    DateTime selectedDateTime = DateTime(
                      currentTime.year,
                      currentTime.month,
                      currentTime.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    if (selectedDateTime.isAfter(
                        currentTime.add(const Duration(minutes: 15)))) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Heure invalide'),
                            content: const Text(
                                'Veuillez choisir une heure au moins 15 minutes plus tard.'),
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
                            'Heure de retrait : ${newSelectedTime != null ? newSelectedTime!.format(context) : panier.getCurrentSelectedTime().format(context)}',
                          ),
                          const Divider(),
                        ],
                      ),
                      Text(
                        (newSelectedMode ??
                                    panier.getSelectedRetraitMode() ??
                                    '') ==
                                'Option 3'
                            ? 'Adresse: ${panier.getUserAddress()}'
                            : '',
                        style: const TextStyle(fontSize: 16),
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
                '\$${panier.getTotalPrix()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(),
          const Text(
            'Moyens de paiement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          CheckboxListTile(
            title: const Text('Carte bancaire'),
            value: useCreditCard,
            onChanged: (value) {
              setState(() {
                useCreditCard = value ?? false;
                if (useCreditCard) {
                  payInStore = false;
                fetchUserCreditCards();
                 
                }
              });
            },
          ),
           if (useCreditCard && userCreditCards.isNotEmpty)
            // Inside the build method where you display the credit card list
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      'Sélectionnez une carte bancaire :',
      style: TextStyle(fontSize: 16, color: Colors.blue),
    ),
    // Display the masked card numbers
    ...userCreditCards.map((card) => RadioListTile(
      title: Text(card.maskedCardNumber), // Use maskedCardNumber here
      value: card.fullCardNumber, // Use fullCardNumber as the value
      groupValue: selectedCreditCard,
      onChanged: (value) {
        setState(() {
          selectedCreditCard = value.toString();
          showCVVDialog(card.cvv);
        });
      },
    )),
  ],
),

          CheckboxListTile(
            title: const Text('En magasin'),
            value: payInStore,
            onChanged: (value) {
              setState(() {
                payInStore = value ?? false;
                if (payInStore) {
                  useCreditCard = false;
                }
              });
            },
          ),
          if (payInStore)
            Column(
              children: [
                RadioListTile(
                  title: const Text('Espèces'),
                  value: 'cash',
                  groupValue: selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value;
                    });
                  },
                ),
                
                RadioListTile(
                  title: const Text('Carte bancaire'),
                  value: 'credit_card',
                  groupValue: selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Tickets Restaurant'),
                  value: 'meal_tickets',
                  groupValue: selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value ;
                    });
                  },
                ),
              ],
            ),
          const Divider(),
          const Spacer(),
          Container(
            width: double.infinity,
            color: Colors.green,
            child: ElevatedButton(
              onPressed: () {},
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
