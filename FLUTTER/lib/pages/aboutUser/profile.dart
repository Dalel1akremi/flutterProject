import 'dart:async';
import 'dart:convert';
import 'package:demo/pages/aboutUser/identifiant.dart';
import 'package:demo/pages/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import './../aboutRestaurant/acceuil.dart';
import './../aboutRestaurant/commande.dart';
import './../aboutPaiement/porfeuille.dart';
import 'adresse.dart';


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
  int currentIndex = 2;

  @override
  void initState() {
    super.initState();
    // Call the function to fetch the email from the backend
    fetchUserEmail();
  }

  Future<void> fetchUserEmail() async {
    final response = await http.get(Uri.parse('http://localhost:3000/getUser'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final userNom = data['nom'];
      final fetchedUserId = data['_id'];

      setState(() {
        email = widget.email;
        nom = userNom;
        userId = fetchedUserId;
      });
    } else {
      // Handle errors when fetching the email
      print('Failed to load user email');
    }
  }

    void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        home: ProfilePage(email: email, nom: nom, userId: userId),
       
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String email;
  final String nom;
  final String userId;

  const ProfilePage({
    Key? key,
    required this.email,
    required this.nom,
    required this.userId,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int currentIndex = 2;

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: Text('Bonjour ${widget.nom}'),
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
                    builder: (context) => ProfileDetailsPage(email: widget.email),
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
                    builder: (context) => AddressSearchScreen(userId: widget.userId),
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
                    builder: (context) => Portefeuille(email: widget.email),
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmation'),
                      content: const Text('Voulez-vous vraiment déconnecter ?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Non'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Empty the cart and log out
                            Provider.of<AuthProvider>(context, listen: false).logout(context);
                            Panier().viderPanier();
                          },
                          child: const Text('Oui'),
                        ),
                      ],
                    );
                  },
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage(email: '', nom: '', userId: '')),
            );
          }
        },
      ),
    );
  }
}
