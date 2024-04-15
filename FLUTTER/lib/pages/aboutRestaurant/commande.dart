// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import './acceuil.dart';
import '../aboutUser/login.dart';
import './../global.dart';
import 'package:demo/pages/aboutUser/auth_provider.dart';
import 'package:demo/pages/aboutUser/profile.dart';

void main() {
  runApp(const CommandeApp());
}

class CommandeApp extends StatefulWidget {
  const CommandeApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CommandeAppState createState() => _CommandeAppState();
}

class _CommandeAppState extends State<CommandeApp> {
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    // Initialize AuthProvider directly in initState
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
    Key? key,
    required this.currentIndex,
    required this.onTabTapped,
    required this.panier,
  }) : super(key: key);

  Future<void> makePhoneCall(String phoneNumber) async {
    if (kDebugMode) {
      print('Attempting to launch call to $phoneNumber');
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(222, 212, 133, 14),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Mes commandes',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
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
  const Divider(),
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      currentIndex == 1
          ? const Icon(Icons.history, size: 30)
          : const Icon(Icons.hourglass_bottom),
    ],
  ),
  const Divider(),


            Expanded(
              child: TabBarView(
                children: [
                  FutureBuilder(
                    future: fetchCommandesEncours(context),
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
                      future: fetchCommandesPass(context),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
          onTap: (index) {
            onTabTapped(index);
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AcceuilScreen()),
              );
            }
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CommandeApp()),
              );
            }
            if (index == 2) {
              if (isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilPage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const loginPage()),
                );
              }
            }
          },
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
)
,

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


  Future<List<Map<String, dynamic>>> fetchCommandesEncours(
     
      BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      debugPrint('User not authenticated. Returning empty list.');
      return [];
    }

    final idUser = authProvider.userId;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getCommandesEncours?id_user=$idUser'),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);

        if (responseBody is List) {
          final List<Map<String, dynamic>> commandes = responseBody
              .where((commande) =>
                  commande != null &&
                  commande['id_items'] != null &&
                  (commande['id_items'] as List).isNotEmpty)
              .map<Map<String, dynamic>>((commande) {
            final items = commande['id_items'] as List;
            final List<Map<String, dynamic>> articles = items.map((item) {
              return {
                'nom': item['nom'],
                'prix': item['prix'] ?? 0,
                'quantite': item['quantite'] ?? 0,
                'elements_choisis':item['elements_choisis'],
                'remarque':item['remarque'],
              };
            }).toList();

            return {
              'commande': commande['numero_commande'],
              'temps': commande['temps'],
              'mode_retrait': commande['mode_retrait'],
              'Total': commande['montant_Total'],
              'etat': commande['etat'],
              'numero_telephone':commande[ 'numero_telephone'],
              'adresse':commande['adresse'],
              'nom_restaurant': commande['nom_restaurant'], 
              'articles': articles,
            };
          }).toList();

          debugPrint('Commandes en cours: $commandes');
          return commandes;
        } else {
          debugPrint('Response body is not a List');
          return [];
        }
      } else {
        throw Exception('Failed to load commandes en cours');
      }
    } catch (error) {
      debugPrint('Error: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCommandesPass(
      BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final idUser = authProvider.userId;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getCommandesPasse?id_user=$idUser'),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);

        if (responseBody is List) {
          final List<Map<String, dynamic>> commandes = responseBody
              .where((commande) =>
                  commande != null &&
                  commande['id_items'] != null &&
                  (commande['id_items'] as List).isNotEmpty)
              .map<Map<String, dynamic>>((commande) {
            final items = commande['id_items'] as List;
            final List<Map<String, dynamic>> articles = items.map((item) {
              return {
                'nom': item['nom'],
                'prix': item['prix'] ?? 0,
                'quantite': item['quantite'] ?? 0,
                'elements_choisis':item['elements_choisis'],
                'remarque':item['remarque'],
              };
            }).toList();

            return {
              'commande': commande['numero_commande'],
              'temps': commande['temps'],
              'mode_retrait': commande['mode_retrait'],
              'Total': commande['montant_Total'],
              'etat': commande['etat'],
               'numero_telephone':commande[ 'numero_telephone'],
               'adresse':commande['adresse'],
                'nom_restaurant': commande['nom_restaurant'], 
              'articles': articles,
            };
          }).toList();

          debugPrint('Commandes: $commandes');
          return commandes;
        } else {
          debugPrint('Response body is not a List');
          return [];
        }
      } else {
        throw Exception('Failed to load commandes');
      }
    } catch (error) {
      debugPrint('Error: $error');
      return [];
    }
  }
}
