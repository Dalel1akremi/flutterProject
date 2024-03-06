// ignore_for_file: avoid_print, library_private_types_in_public_api, use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './../aboutRestaurant/commande.dart';
import './../global.dart';
import './../aboutUser/auth_provider.dart';

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
  bool enableInStoreCheckbox = false; // Variable pour activer/désactiver la case à cocher "En magasin"

// Définir une fonction pour vérifier si l'une des options de la liste de sélection radio est sélectionnée
bool isPaymentMethodSelected() {
  return selectedPaymentMethod != null;
}
  @override
  void initState() {
    super.initState();
    initAuthProvider();
  }

  Future<void> initAuthProvider() async {
    await authProvider.initTokenFromStorage();
    setState(() {});
  }

  Future<List<dynamic>> recupererCartesUtilisateur() async {
    try {
      await authProvider.initTokenFromStorage();
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/recupererCartesUtilisateur?email=${authProvider.email}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['cards'];
      } else {
        throw Exception('Failed to load user cards');
      }
    } catch (error) {
      throw Exception('Failed to load user cards: $error');
    }
  }

  Future<String?> showCVVInputDialog() async {
    TextEditingController cvvController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Entrez votre code confidentiel'),
          content: TextField(
            controller: cvvController,
            decoration: const InputDecoration(labelText: 'Code confidentiel'),
            keyboardType: TextInputType.number,
            obscureText:
                true, // Pour cacher les caractères du code confidentiel
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
                Navigator.pop(context, cvvController.text);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  Future<void> processPayment() async {
    try {
      final userCards = await recupererCartesUtilisateur();
      if (userCards.isEmpty) {
        print('Aucune carte trouvée pour cet utilisateur');
        return;
      }

      final selectedCard = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sélectionnez une carte'),
            content: DropdownButton<dynamic>(
              value:
                  userCards.first, // Sélectionnez par défaut la première carte
              onChanged: (value) {
                Navigator.of(context).pop(value);
              },
              items: userCards.map<DropdownMenuItem<dynamic>>((card) {
                return DropdownMenuItem<dynamic>(
                  value: card,
                  child: Text('${card['cardNumber']}'),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(userCards.first);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      // Demander le code confidentiel
      if (selectedCard != null) {
        final enteredCVV = await showCVVInputDialog();
        if (enteredCVV == selectedCard['cvv']) {
          // Si la carte sélectionnée et le code confidentiel sont valides, effectuez le paiement
          print(
              selectedCard['_id']); // Vérifiez la valeur de selectedCard['_id']
          final paymentResponse = await http.post(
            Uri.parse(
                'http://localhost:3000/recupererCarteParId?email=${authProvider.email}&cardId=${selectedCard["_id"]}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'montant': panier.getTotalPrix(),
              // Assurez-vous que selectedCard contient un _id valide
              // Ajoutez d'autres détails comme le code confidentiel ici si nécessaire
            }),
          );

          final paymentData = jsonDecode(paymentResponse.body);
          print('Résultat de l\'appel API : $paymentData');

          if (paymentData['success'] == true) {
            print('Paiement réussi');
            panier.printPanier();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CommandeApp(),
              ),
            );
          } else {
            // Afficher un message d'erreur
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Erreur de paiement'),
                  content:
                      const Text('Une erreur est survenue lors du paiement.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          // Afficher un message d'erreur
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Erreur de paiement'),
                content: const Text(
                    'Le code confidentiel est incorrect. Veuillez réessayer.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
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
                  processPayment();
                }
              });
            },
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
