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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;
   

    Future<void> makePhoneCall() async {
      const phoneNumber = '03325368596';
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
            const TabBar(
              tabs: [
                Tab(text: 'En cours'),
                Tab(text: 'Passées'),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.hourglass_bottom, size: 25),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          makePhoneCall();
                        },
                        child: const Icon(Icons.phone, size: 30),
                      ),
                    ],
                  ),
                ),
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
      itemCount: commandes.length * 2 -
          1, // Ajuster le nombre d'éléments pour inclure les séparateurs
      itemBuilder: (context, index) {
        if (index.isOdd) {
          // L'index impair signifie qu'il s'agit d'un séparateur
          return const Divider();
        } else {
          // L'index pair signifie qu'il s'agit d'un ListTile
          final commandeIndex = index ~/ 2;
          final commande = commandes[commandeIndex];
          final articles = commande['articles'] as List<Map<String, dynamic>>;
          return Column(
            children: [
              ListTile(
                title: Text(
                  'Commande: ${commande['commande'] ?? 'N/A'}, Temps: ${commande['temps'] ?? 'N/A'}, Mode: ${commande['mode_retrait'] ?? 'N/A'}, Total: ${commande['Total'] ?? 'N/A'}€',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: articles.map((article) {
                    return Text(
                      '${article['nom'] ?? 'N/A'}, Prix: ${article['prix'] ?? 'N/A'}€, Quantité: ${article['quantite'] ?? 'N/A'}',
                    );
                  }).toList(),
                ),
              ),
              if (commandeIndex < commandes.length - 1) const Divider(),
            ],
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
              };
            }).toList();

            return {
              'commande': commande['numero_commande'],
              'temps': commande['temps'],
              'mode_retrait': commande['mode_retrait'],
              'Total': commande['montant_Total'],
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
              };
            }).toList();

            return {
              'commande': commande['numero_commande'],
              'temps': commande['temps'],
              'mode_retrait': commande['mode_retrait'],
              'Total': commande['montant_Total'],
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
