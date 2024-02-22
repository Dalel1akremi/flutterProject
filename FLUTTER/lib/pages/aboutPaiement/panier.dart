import 'package:demo/pages/aboutUser/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../aboutRestaurant/acceuil.dart';
import './../global.dart';
import 'paiement.dart';
import '../aboutUser/auth_provider.dart';

class PanierPage extends StatefulWidget {
  final int numberOfItems;
  final int totalPrice;
  final String selectedRetraitMode;
  final Restaurant restaurant;
  final String nom;
  final List<Article> panier;

  const PanierPage({
    Key? key,
    required this.numberOfItems,
    required this.totalPrice,
    required this.selectedRetraitMode,
    required this.restaurant,
    required this.nom,
    required this.panier,
  }) : super(key: key);

  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  TimeOfDay? _newSelectedTime;

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

  @override
  Widget build(BuildContext context) {
    Panier panier = Panier(); // Instance de la classe Panier

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
                Icon(getModeIcon(widget.selectedRetraitMode)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Heure de retrait : ${_newSelectedTime != null ? _newSelectedTime!.format(context) : panier.getCurrentSelectedTime().format(context)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showTimePickerDialog();
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
             panier.updateCommandeDetails(widget.selectedRetraitMode, _newSelectedTime ?? panier.getCurrentSelectedTime());
                // Vérifiez si l'utilisateur est connecté
                bool isLoggedIn =
                    Provider.of<AuthProvider>(context, listen: false)
                        .isAuthenticated;
                if (isLoggedIn) {
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        selectedRetraitMode: widget.selectedRetraitMode,
                        restaurant: widget.restaurant,
                        totalPrice: widget.totalPrice,
                        panier: panier.articles,
                      ),
                    ),
                  );
                } else {
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
                    ' ${widget.totalPrice} £',
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

  Future<void> _showTimePickerDialog() async {
      Panier panier = Panier();
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: panier.getCurrentSelectedTime(),
    );

    if (selectedTime != null) {
      setState(() {
        _newSelectedTime = selectedTime;
      });
    }
  }
}