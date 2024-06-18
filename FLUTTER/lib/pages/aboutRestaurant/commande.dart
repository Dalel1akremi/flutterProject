// ignore_for_file: deprecated_member_use
import 'package:demo/pages/aboutRestaurant/commandeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import './../global.dart';
import 'package:demo/pages/aboutUser/auth_provider.dart';
void main() {
  runApp(const CommandeApp());
}

class CommandeApp extends StatefulWidget {
  const CommandeApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CommandeAppState createState() => _CommandeAppState();
}

class _CommandeAppState extends State<CommandeApp> {
  int _currentIndex = 1;

 @override
void initState() {
  super.initState();
  Provider.of<CommandesModel>(context, listen: false).startPolling(context);
  Provider.of<AuthProvider>(context, listen: false).initTokenFromStorage();
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CommandeScreen(
        currentIndex: _currentIndex,
        onTabTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        panier: Panier(),
      ),
    );
  }
}

class CommandeScreen extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;
  final Panier panier;

  const CommandeScreen({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    required this.panier,
  });

  Future<void> makePhoneCall(String phoneNumber) async {
    if (kDebugMode) {
      print('Tentative de lancer un appel à $phoneNumber');
    }

    if (await canLaunch('tel:$phoneNumber')) {
      await launch('tel:$phoneNumber');
    } else {
      if (kDebugMode) {
        print('Impossible de lancer l\'appel vers $phoneNumber');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: Colors.white,
        body: Column(
          children: [
                TabBar(
                  tabs: const [
                    Tab(text: 'En cours'),
                    Tab(text: 'Passées'),
                  ],
                  onTap: (index) {
                    onTabTapped(index);
                  },
                ),
             
            Expanded(
              child: TabBarView(
                children: [
                  FutureBuilder(
                    future:  Provider.of<CommandesModel>(context).fetchCommandesEncours(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        final commandes =
                            snapshot.data as List<Map<String, dynamic>>;
                        if (commandes.isEmpty) {
                          return const Center(
                            child: Text(
                              "Aucune commande en cours",
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        } else {
                          return buildCommandesListView(commandes);
                        }
                      }
                    },
                  ),
                  FutureBuilder(
                     future: Provider.of<CommandesModel>(context).fetchCommandesPass(context),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Erreur: ${snapshot.error}'));
                        } else {
                          final commandes =
                              snapshot.data as List<Map<String, dynamic>>;
                          if (commandes.isEmpty) {
                            return const Center(
                              child: Text(
                                "Aucune commande passée",
                                style: TextStyle(fontSize: 18),
                              ),
                            );
                          } else {
                            return buildCommandesListView(commandes);
                          }
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget buildCommandesListView(List<Map<String, dynamic>> commandes) {
  return ListView.builder(
    itemCount: commandes.length * 2 - 1,
    itemBuilder: (context, index) {
      if (index.isOdd) {
        return const Divider();
      } else {
        final commandeIndex = index ~/ 2;
        final commande = commandes[commandeIndex];
        final articles = commande['articles'] as List<Map<String, dynamic>>;
        final etatCommande = commande['etat'];
        final phoneNumber = commande['numero_telephone'];
        Color circle1Color = Colors.grey; 
        Color circle2Color = Colors.grey;
        Color circle3Color = Colors.grey; 
        if (etatCommande == 'Validée') {
          circle1Color = Colors.green;
        } else if (etatCommande == 'En Préparation') {
          circle1Color = Colors.green;
          circle2Color = Colors.orange;
        } else if (etatCommande == 'Prête') {
          circle1Color = Colors.green;
          circle2Color = Colors.orange;
          circle3Color = Colors.blue;
        }
        IconData modeRetraitIcon;
              switch (commande['mode_retrait']) {
                case 'En Livraison':
                  modeRetraitIcon = Icons.delivery_dining;
                  break;
                case 'Sur place':
                  modeRetraitIcon = Icons.restaurant;
                  break;
                case 'A Emporter':
                  modeRetraitIcon = Icons.shopping_bag;
                  break;
                default:
                  modeRetraitIcon = Icons.error; 
              }
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            '${commande['nom_restaurant'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('  à ${commande['temps'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total: ${commande['Total'] ?? 'N/A'}€',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
  
                const SizedBox(height: 8),
               Row(     
                children: [
                  Icon(modeRetraitIcon), 
                  const SizedBox(width: 8),
                  Text(
                    'Commande: ${commande['commande'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                                    onPressed: () {
                                      makePhoneCall(phoneNumber);
                                    },
                                    icon: const Icon(Icons.phone),
                                    label: const Text('Appeler'),
                                  ),
                ],
              ),
                      const Divider(),
                                      Visibility(
                        visible: commande['mode_retrait'] == 'En Livraison', 
                        child: Text('Adresse:${commande['adresse'] ?? 'N/A'}',),
                      ),
                                    
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: articles.map((article) {
                          if (article['elements_choisis'] == null || article['elements_choisis'].isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${article['quantite'] ?? 'N/A'} X ${article['nom'] ?? 'N/A'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Prix: ${article['prix'] ?? 'N/A'}€',
                                  ),
                                  if (article['remarque'] != null && article['remarque'].isNotEmpty)
                                    Text('Remarque : ${article['remarque']}'),
                                ],
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${article['quantite'] ?? 'N/A'} X ${article['nom'] ?? 'N/A'} ${article['elements_choisis'] ?? 'N/A'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Prix: ${article['prix'] ?? 'N/A'}€',
                                  ),
                                  if (article['remarque'] != null && article['remarque'].isNotEmpty)
                                    Text('Remarque : ${article['remarque']}'),
                                ],
                              ),
                            );
                          }
                        }).toList(),
                      ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'État: $etatCommande',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                  ],
                ),
                const SizedBox(height: 10),
               Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Visibility(
      visible: etatCommande != 'Passée' && etatCommande != 'Non validée',
      child: Column(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: circle1Color,
            child: const Text('1', style: TextStyle(color: Colors.white)),
          ),
          const Text('Validée'),
        ],
      ),
    ),
    Expanded(
      child: Container(
        height: 2,
        color: Colors.black,
      ),
    ),
    Visibility(
      visible: etatCommande != 'Passée' && etatCommande != 'Non validée',
      child: Column(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: circle2Color,
            child: const Text('2', style: TextStyle(color: Colors.white)),
          ),
          const Text('En Préparation'),
        ],
      ),
    ),
    Expanded(
      child: Container(
        height: 2,
        color: Colors.black,
      ),
    ),
    Visibility(
      visible: etatCommande != 'Passée' && etatCommande != 'Non validée',
      child: Column(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: circle3Color,
            child: const Text('3', style: TextStyle(color: Colors.white)),
          ),
          const Text('Prête'),
        ],
      ),
    ),
  ],
),
              ],
            ),
          ),
        );
      }
    },
  );
}
}
