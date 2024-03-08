// ignore_for_file: avoid_print, library_private_types_in_public_api, use_build_context_synchronously
import 'dart:convert';
import 'package:demo/pages/aboutRestaurant/commande.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './../global.dart';
import './../aboutUser/auth_provider.dart';

class CreditCard {
  final String fullCardNumber;
  final String cvv;
  final String _id;
  String get maskedCardNumber {
    return '*' * (fullCardNumber.length - 4) +
        fullCardNumber.substring(fullCardNumber.length - 4);
  }

  CreditCard(
    this.fullCardNumber,
    this.cvv,
    this._id,
  );
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
  List<CreditCard> userCreditCards = [];
  String? selectedCreditCard;
  bool isPaymentMethodSelected() {
    return selectedPaymentMethod != null;
  }

  @override
  void initState() {
    super.initState();
    initAuthProvider();
    fetchUserCreditCards();
    panier.printPanier();
  }

Future<void> createCommande() async {
  try {
    String? userId = authProvider.userId;

    if (userId == null) {
      print('User ID not available.');
      return;
    }

    List<Map<String, dynamic>> idItems = panier.articles.map((article) {
      return {
        'id_item': article.id_item,
        'quantite': article.quantite,
        'temps': panier.getCurrentSelectedTime().format(context),
         'mode_retrait': mapRetraitMode(panier.getSelectedRetraitMode()?? ''),
         'montant_Total':panier.getTotalPrix(),
      };
    }).toList();

    var response = await http.post(
      Uri.parse('http://localhost:3000/createCommande?id_user=$userId'),
      body: jsonEncode({'id_items': idItems}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      print('Commande created successfully.');
    } else {
      print('Failed to create Commande: ${response.statusCode}');
    }
  } catch (error) {
    print('Error creating Commande: $error');
  }
}

  Future<void> handlePayment() async {
 
   if (useCreditCard && selectedCreditCard != null) {
      makePaymentWithCreditCard();
        panier.printPanier();
      await createCommande(); 
    } else if (payInStore && selectedPaymentMethod != null) {
         panier.printPanier();
      await createCommande(); 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CommandeApp()),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: const Text(
                'Merci de vérifier votre mode de paiement avant de passer votre commande.'),
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
  }

  void makePaymentWithCreditCard() async {
    if (selectedCreditCard != null) {
      try {
        CreditCard selectedCard = userCreditCards
            .firstWhere((card) => card.fullCardNumber == selectedCreditCard);
        String cardId = selectedCard._id;

        var response = await http.post(
          Uri.parse(
              'http://localhost:3000/recupererCarteParId?email=${authProvider.email}&cardId=$cardId'),
          body: jsonEncode({'montant': panier.getTotalPrix()}),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          print('Payment successful!');
        } else {
          throw Exception('Failed to process payment: ${response.statusCode}');
        }
      } catch (e) {
        print('Error processing payment: $e');
      }
    } else {
      print('Please select a credit card for payment.');
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CommandeApp()),
    );
  }

  Future<void> showCVVDialog(String cvv) async {
    String enteredCVV = '';
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Entrez votre code confidentiel'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            obscureText: true,
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
                Navigator.of(context).pop(enteredCVV);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    ).then((value) {
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
    String? userEmail = authProvider.email;
    if (userEmail != null) {
      try {
        var response = await http.get(Uri.parse(
            'http://localhost:3000/recupererCartesUtilisateur?email=$userEmail'));
        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          if (responseData is Map && responseData.containsKey('cards')) {
            setState(() {
              userCreditCards = (responseData['cards'] as List)
                  .map((data) =>
                      CreditCard(data['cardNumber'], data['cvv'], data['_id']))
                  .toList();
            });
          } else {
            throw Exception('Invalid response format: $responseData');
          }
        } else {
          throw Exception(
              'Failed to load user credit cards: ${response.statusCode}');
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
                } else {
                  selectedCreditCard = null;
                }
              });
            },
          ),
          if (useCreditCard && userCreditCards.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sélectionnez une carte bancaire :',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                ...userCreditCards.map((card) => RadioListTile(
                      title: Text(card.maskedCardNumber),
                      value: card.fullCardNumber,
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
                      selectedPaymentMethod = value;
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
              onPressed: handlePayment,
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
