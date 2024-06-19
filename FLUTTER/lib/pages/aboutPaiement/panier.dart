// ignore_for_file: use_build_context_synchronously

import 'package:demo/pages/aboutUser/adresse.dart';
import 'package:demo/pages/aboutUser/login.dart';
import 'package:flutter/material.dart';
import './../global.dart';
import 'paiement.dart';
import '../aboutUser/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PanierPage extends StatefulWidget {
  const PanierPage({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  TimeOfDay? newSelectedTime;
  String? newSelectedMode;
  AuthProvider authProvider = AuthProvider();

  late Panier panier;

  int getTotalQuantity() {
    int totalQuantity = 0;
    for (Article article in panier) {
      totalQuantity += article.quantite;
    }
    return totalQuantity;
  }

  IconData getModeIcon(String value) {
    IconData iconData;
    switch (value.trim().toLowerCase()) {
      case 'en livraison':
        iconData = Icons.delivery_dining;
        break;
      case 'a emporter':
        iconData = Icons.takeout_dining;
        break;
      case 'sur place':
        iconData = Icons.restaurant;
        break;
      default:
        iconData = Icons.error;
    }
    return iconData;
  }

  @override
  void initState() {
    super.initState();
    initAuthProvider();

    panier = Panier();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text("Panier"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    getModeIcon(newSelectedMode ?? panier.getSelectedRetraitMode() ?? ''),
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Heure de retrait : ${newSelectedTime != null ? newSelectedTime!.format(context) : panier.getCurrentSelectedTime().format(context)}',
                    style: const TextStyle(fontSize: 16),
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
          Text(
            (newSelectedMode ?? panier.getSelectedRetraitMode() ?? '') ==
                    'En Livraison'
                ? 'Adresse: ${panier.getUserAddress()}'
                : '',
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(
            color: Colors.black,
            thickness: 2,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: panier.length,
              itemBuilder: (context, index) {
                final article = panier[index];
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${article.quantite} x ${article.nom}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: article.elementsChoisis
                            .map((element) => Text('     $element'))
                            .toList(),
                      ),
                      if (article.remarque.isNotEmpty)
                        Text(
                          'Remarque: ${article.remarque}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  trailing: Text('Prix: ${article.prix} €'),
                  onTap: () {
                    showUpdateQuantityDialog(article);
                  },
                );
              },
            ),
          ),
          const Divider(
            color: Colors.black,
            thickness: 2,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? token = prefs.getString('token');
          String? email = prefs.getString('email');
          if (token != null && token.isNotEmpty || email!=null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentScreen(),
                    ),
                  );
                } else {
                  panier.origin = 'panier';
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const loginPage()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50),
                backgroundColor: Colors.green,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ' ${getTotalQuantity()} articles',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Finaliser la commande',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    ' ${panier.getTotalPrix()} €',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showEditDialog() async {
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
                  setState(() async {
                    selectedRetraitMode = newValue!;
                    if (selectedRetraitMode == 'En Livraison') {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? token = prefs.getString('token');
          String? email = prefs.getString('email');
          if (token != null && token.isNotEmpty || email!=null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AddressSearchScreen()),
                        );
                      } else {
                        panier.origin = 'livraison';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const loginPage()),
                        );
                      }
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
        panier.updateCommandeDetails(newSelectedMode ??panier.getSelectedRetraitMode() ?? '',
            newSelectedTime ?? panier.getCurrentSelectedTime());
      });
    }
  }

  Future<void> showUpdateQuantityDialog(Article article) async {
    int newQuantity = article.quantite;
    int newPrice = article.quantite * article.prix;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(' ${article.nom}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Personnaliser votre plat',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                height: 2.0,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        newQuantity++;
                        newPrice;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          border: Border.all(color: Colors.black, width: 1)),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.add),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$newQuantity',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (newQuantity > 1) {
                          newQuantity--;
                          newPrice;
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          border: Border.all(color: Colors.black, width: 1)),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.remove),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Text(
                'Nouveau Total:$newPrice £',
                style: const TextStyle(fontSize: 20),
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
                setState(() {
                  article.quantite = newQuantity;
                });
                Navigator.pop(context);
              },
              child: const Text('Mettre à jour'),
            ),
          ],
        );
      },
    );
  }
}
