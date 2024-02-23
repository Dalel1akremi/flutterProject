import 'package:demo/pages/aboutUser/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../global.dart';
import 'paiement.dart';
import '../aboutUser/auth_provider.dart';

class PanierPage extends StatefulWidget {
  final int numberOfItems;
  final String nom;
  final List<Article> panier;

  const PanierPage({
    Key? key,
    required this.numberOfItems,
    required this.nom,
    required this.panier,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  TimeOfDay? newSelectedTime;
  String? newSelectedMode;
  Panier panier = Panier();
  IconData getModeIcon(String value) {
    switch (value) {
      case 'Option 1':
        return Icons.takeout_dining;
      case 'Option 2':
        return Icons.table_chart;
      case 'Option 3':
        return Icons.delivery_dining;
      default:
        return Icons.shopping_bag;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
               Icon(getModeIcon(newSelectedMode ?? panier.getSelectedRetraitMode() ?? '')),
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
          Expanded(
            child: ListView.builder(
              itemCount: widget.panier.length,
              itemBuilder: (context, index) {
                final article = widget.panier[index];
                return ListTile(
                  title: Text(article.nom),
                  subtitle: Text('Prix: ${article.prix} £'),
                  trailing: Text('Quantité: ${article.quantite}'),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Appel de la fonction pour mettre à jour les détails de la commande dans le panier global
                panier.updateCommandeDetails(
                    panier.getSelectedRetraitMode() ?? '',
                    newSelectedTime ?? panier.getCurrentSelectedTime());
                // Vérifiez si l'utilisateur est connecté
                bool isLoggedIn =
                    Provider.of<AuthProvider>(context, listen: false)
                        .isAuthenticated;
                if (isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentScreen(
                  
                      ),
                    ),
                  );
                } else {
                  panier.origin = 'panier';
                  // Utilisateur non connecté, rediriger vers la page de connexion
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const loginPage()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50),
                backgroundColor: Colors.green, // Change as needed
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ' ${widget.numberOfItems} article${widget.numberOfItems != 1 ? 's' : ''}',
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
                    ' ${panier.getTotalPrix()} £',
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
}
