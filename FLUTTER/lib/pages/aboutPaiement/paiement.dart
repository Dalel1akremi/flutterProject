// ignore_for_file: avoid_print, library_private_types_in_public_api, use_build_context_synchronously
import 'dart:convert';
import 'package:demo/pages/aboutRestaurant/RestaurantList.dart';
import 'package:demo/pages/aboutUser/adresse.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './../global.dart';
import './../aboutUser/auth_provider.dart';
import 'package:bcrypt/bcrypt.dart';

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
    super.key,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  TimeOfDay? newSelectedTime;
  String? newSelectedMode;
  Panier panier = Panier();
  bool isCVVValidated = false;
  AuthProvider authProvider = AuthProvider();
  String? selectedRestaurantPaymentModes;
  bool enableInStoreCheckbox = false;
  List<CreditCard> userCreditCards = [];
  String? selectedCreditCard;
  String? id;
  bool isCreditCardChecked = false;
  String? selectedPaymentMethod;
  @override
  void initState() {
    super.initState();
    initAuthProvider();
    fetchUserCreditCards();
    panier.printPanier();
    selectedRestaurantPaymentModes = Panier().getSelectedRestaurantPaiement();
  }

  Future<void> createCommande() async {
    try {
      String? userEmail = authProvider.email;

      if (userEmail == null) {
        print('email not available.');
        return;
      }
      final int? idRest = Panier().getIdRestaurant();
      if (idRest == null) {
        throw Exception('Restaurant ID is null');
      }
      List<Map<String, dynamic>> idItems = panier.articles.map((article) {
        print(
            'Elements choisis pour l\'article ${article.id_item}: ${article.elementsChoisis}');

        return {
          'id_item': article.id_item,
          'nom':article.nom,
          'prix'  : article.prix ,
          'quantite': article.quantite,
          'temps': panier.getCurrentSelectedTime().format(context),
          'mode_retrait': mapRetraitMode(panier.getSelectedRetraitMode() ?? ''),
          'montant_Total': (panier.getSelectedRetraitMode() == 'En Livraison')
              ? panier.getTotalPrix() + 7
              : panier.getTotalPrix(),
          'elements_choisis': article.elementsChoisis,
          'adresse': panier.getUserAddress(),
          'remarque': article.remarque,
        };
      }).toList();
String myIp = Global.myIp;   
   var response = await http.post(
        
        Uri.parse(
            'http://$myIp:3000/createCommande?email=$userEmail&id_rest=$idRest'),
        body: jsonEncode({
          'id_items': idItems,
        }),
         headers: {
        'Content-Type': 'application/json',
      },
      );

      if (response.statusCode == 201) {
        print('Commande crée avec succès.');
      } else {
        print('Echec de creation de Commande: ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur de creation de Commande: $error');
    }
  }

Future<bool> handlePayment() async {
  if (isCreditCardChecked && selectedCreditCard != null && isCVVValidated) {
    await createCommande(); 
    return true; 
  } else if (enableInStoreCheckbox && selectedPaymentMethod != null) {
    panier.printPanier();
    await createCommande(); 
    return true;
  } else {
    showPaymentMethodErrorDialog();
    return false; 
  }
}



void showPaymentMethodErrorDialog() {
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

Future<void> makePaymentWithCreditCard() async {
  if (selectedCreditCard != null) {
    try {
      CreditCard selectedCard = userCreditCards
          .firstWhere((card) => card.fullCardNumber == selectedCreditCard);
      String cardId = selectedCard._id;
String myIp = Global.myIp;
      var response = await http.post(
        
        Uri.parse(
            'http://$myIp:3000/recupererCarteParId?email=${authProvider.email}&cardId=$cardId'),
        body: jsonEncode({'montant': panier.getTotalPrix()}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('Payement est effectué avec succès!');
        await createCommande(); 
      } else {
        throw Exception('Echec de paiement: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de paiement: $e');
    }
  } else {
    print('Veuillez selectionner une carte de credit  pour le  paiement.');
  }

  
}

 Future<void> fetchUserCreditCards() async {
  String? userEmail = authProvider.email;
  if (userEmail != null) {
    try {
      String myIp = Global.myIp;
      final response = await http.get(Uri.parse('http://$myIp:3000/recupererCartesUtilisateur?email=$userEmail'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map && responseData.containsKey('cards')) {
          setState(() {
            userCreditCards = (responseData['cards'] as List)
                .map((data) =>
                    CreditCard(data['cardNumber'], data['cvv'], data['_id']))
                .toList();
          });
        } else {
          throw Exception('Format de reponse invalide : $responseData');
        }
      } else {
        throw Exception('Échec du chargement des cartes de crédit des utilisateurs: ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des cartes de crédit des utilisateurs: $error');
    }
  }
}
  Future<void> initAuthProvider() async {
    await authProvider.initTokenFromStorage();
    setState(() {});
  }

  String mapRetraitMode(String value) {
    switch (value) {
      case 'a emporter':
        return 'A Emporter';
      case 'sur place':
        return 'Sur place';
      case 'en livraison':
        return 'En Livraison';
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
                    if (selectedRetraitMode == 'En Livraison') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddressSearchScreen()),
                      );
                    }
                  });
                },
                items: <String>['A Emporter', 'Sur place', 'En Livraison']
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
        panier.updateCommandeDetails(
            newSelectedMode ?? panier.getSelectedRetraitMode() ?? '',
            newSelectedTime ?? panier.getCurrentSelectedTime());
      });
    }
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
              setState(() {
                selectedCreditCard = null;
              });
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
    if (value != null) {
      compareCVV(cvv, value);
    }
  });
}
Future<void> compareCVV(String hashedCVV, String enteredCVV) async {
  try {
    var isMatch = BCrypt.checkpw(enteredCVV, hashedCVV);

    if (isMatch) {
      isCVVValidated = true; 
      await makePaymentWithCreditCard();
      await createCommande();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Code incorrect'),
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
  } catch (error) {
    print('Erreur lors de la comparaison des CVV: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    String? modepaiement = selectedRestaurantPaymentModes;
    List<String> selectedPaymentMethods = [];

    if (modepaiement != null && modepaiement.isNotEmpty) {
      selectedPaymentMethods
          .addAll(modepaiement.split(',').map((mode) => mode.trim()));
    }
  bool showCreditCardCheckbox = selectedPaymentMethods.contains('Carte bancaire');
  return Scaffold(
    backgroundColor: Colors.white,
  appBar: AppBar(
    backgroundColor: const Color.fromARGB(222, 212, 133, 14),
    title: const Text("Récapitulatif de la commande "),
  ),
  body: SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
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
                      (newSelectedMode ?? panier.getSelectedRetraitMode() ?? '') == 'En Livraison'
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Montant',
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (panier.getSelectedRetraitMode() == 'En Livraison')
                  const Text(
                    '+ Frais de livraison : \$7',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                Text(
                  '\$${(panier.getSelectedRetraitMode() == 'En Livraison') ? (panier.getTotalPrix() + 7) : panier.getTotalPrix()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
        Column(
          children: [
            if (showCreditCardCheckbox)
              CheckboxListTile(
                title: const Text('Carte bancaire'),
                value: isCreditCardChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isCreditCardChecked = value ?? false;
                    if (isCreditCardChecked) {
                      enableInStoreCheckbox = false;
                      selectedPaymentMethod = null;
                      fetchUserCreditCards();
                    }
                  });
                },
              ),
            if (isCreditCardChecked && userCreditCards.isNotEmpty)
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
              value: enableInStoreCheckbox,
              onChanged: (bool? value) {
                setState(() {
                  enableInStoreCheckbox = value ?? false;
                  if (enableInStoreCheckbox) {
                    isCreditCardChecked = false;
                    selectedCreditCard = null;
                  }
                });
              },
            ),
            if (enableInStoreCheckbox)
              Column(
                children: [
                  for (var method in selectedPaymentMethods)
                    RadioListTile<String>(
                      title: Text(method),
                      value: method,
                      groupValue: selectedPaymentMethod,
                      onChanged: (String? value) {
                        setState(() {
                          selectedPaymentMethod = value;
                        });
                      },
                    ),
                ],
              ),
          ],
        ),
      ],
    ),
  ),
  bottomNavigationBar: Container(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          bool paymentHandled = await handlePayment();

          if (paymentHandled) {
            Panier().viderPanier();
            panier.origine = 'commandes';
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RestaurantScreen(index: 2,)),
          );
          }
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
  ),
);
}
}
