// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:demo/pages/aboutUser/auth_provider.dart';
import 'package:demo/pages/aboutUser/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './acceuil.dart';
import '../aboutUser/login.dart';
import './../global.dart';
import 'package:url_launcher/url_launcher.dart';

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
      if (authProvider.telephone != null) {
        final phoneNumber = authProvider.telephone!;
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
      } else {
        if (kDebugMode) {
          print('Le numéro de téléphone n\'est pas disponible. authProvider.telephone: ${authProvider.telephone}');
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
                Tab(text: 'Passés'),
              ],
            ),
        Row(
  children: [
   

 const Icon(Icons.hourglass_bottom, size: 25),
          const SizedBox(width: 8),
          Text(
            'à ${panier.getCurrentSelectedTime().format(context)}',
            style: const TextStyle(fontSize: 16),
          ),
  
    Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
             GestureDetector(
      onTap: () {
        makePhoneCall();
      },
      child:const  Icon(Icons.phone, size: 30),
    ),
        ],
      ),
    ),

    // Montant à droite
    Text(
      'Montant: ${panier.getTotalPrix()}€',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),


              const Divider(),
            Expanded(
              child: TabBarView(
                children: [
                  Center(
                    child: ListView.builder(
                      itemCount: panier.articles.length,
                      itemBuilder: (conytext, index) {
                        return ListTile(
                          title: Text(panier.articles[index].nom),
                          trailing: Text('${panier.articles[index].quantite}'),
                          subtitle: const Text(
                            ""
                          ),
                        );
                      },
                    ),
                  ),
                  const Center(
                    child: Text('Content for "Passés" tab'),
                  ),
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
                  MaterialPageRoute(
                      builder: (context) =>
                          const ProfilePage(email: '', nom: '', userId: '')),
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
}
