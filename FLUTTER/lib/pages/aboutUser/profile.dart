// ignore_for_file: avoid_print, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'login.dart';
import './../aboutPaiement/porfeuille.dart';
import 'identifiant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './../aboutRestaurant/acceuil.dart';
import './../aboutRestaurant/commande.dart';
import 'adresse.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class MyApp extends StatefulWidget {
  final String email;

  const MyApp({Key? key, required this.email}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String email;
  late String nom;
  late String userId;
  @override
  void initState() {
    super.initState();
    // Appel de la fonction pour récupérer l'email depuis le backend
    fetchUserEmail();
  }

  Future<void> fetchUserEmail() async {
    final response = await http.get(Uri.parse('http://localhost:3000/getUser'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final userNom = data['nom'];
      final userId = data['_id'];

      setState(() {
        email = widget.email;
        nom = userNom;
      });
    } else {
      // Gérer les erreurs lors de la récupération de l'email
      print('Failed to load user email');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap MaterialApp with ChangeNotifierProvider to provide AuthProvider instance
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        home: ProfilePage(email: email, nom: nom, userId: userId),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String email;
  final String nom;
  final String userId;
  const ProfilePage(
      {Key? key, required this.email, required this.nom, required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: Text('Bonjour $nom'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileDetailsPage(email: email),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.person),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Profil',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressSearchScreen(userId: userId),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.location_on),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Adresse',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Portefeuille(),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.credit_card),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Moyens de Paiement',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false)
                    .logout(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AcceuilApp()),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.exit_to_app),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Déconnexion',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const loginPage()),
            );
          }
        },
      ),
    );
  }
}
