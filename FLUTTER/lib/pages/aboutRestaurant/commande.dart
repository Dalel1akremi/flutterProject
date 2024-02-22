import 'package:demo/pages/aboutUser/auth_provider.dart';
import 'package:demo/pages/aboutUser/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './acceuil.dart';
import '../aboutUser/login.dart';
import './../global.dart';

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
  final Panier panier; // Add a field to store the shopping cart

  const CommandeScreen({
    Key? key,
    required this.currentIndex,
    required this.onTabTapped,
    required this.panier, // Pass the shopping cart through the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;
    final token = authProvider.token;
    final userId = authProvider.userId;
    final nom = authProvider.nom;
    final email = authProvider.email;

    if (isLoggedIn) {
      print('Token récupéré: $token,$email,$nom,$userId');
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
            Container(
              color: const Color.fromARGB(181, 123, 106, 106),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // Handle "En cours" button press
                      if (kDebugMode) {
                        print('En cours button pressed');
                      }
                    },
                    child: const Row(
                      children: [
                        SizedBox(width: 16.0),
                        Text(
                          'En cours',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle "Passés" button press
                      if (kDebugMode) {
                        print('Passés button pressed');
                      }
                    },
                    child: const Row(
                      children: [
                        SizedBox(width: 16.0),
                        Text(
                          'Passés',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
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
            // Handle bottom navigation bar taps
            if (index == 0) {
              // Navigate to the CommandePage when Button 2 is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AcceuilScreen()),
              );
            }
            if (index == 1) {
              // Navigate to the CommandePage when Button 2 is pressed
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
