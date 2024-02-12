<<<<<<< HEAD
// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
=======
// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'login.dart';
import './../aboutPaiement/porfeuille.dart';
import 'identifiant.dart';
>>>>>>> 585e03ad591721c2ad1d0b5a55a8239c17d878b2
import 'dart:convert';
import 'package:http/http.dart' as http;
import './../aboutRestaurant/acceuil.dart';
import './../aboutRestaurant/commande.dart';
import 'adresse.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String userEmail;
  late String nom;

  @override
  void initState() {
    super.initState();
    // Appel de la fonction pour récupérer l'email depuis le backend
    fetchUserEmail();
  }

  // Fonction pour récupérer l'email depuis le backend
  Future<void> fetchUserEmail() async {
    final response = await http.get(Uri.parse('http://localhost:3000/getUser'));

<<<<<<< HEAD
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token'];
        final String userId = data['userId'];

        print('Login successful! Token: $token, UserId: $userId');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      } else {
        final data = json.decode(response.body);
        final String message = data['message'];

        print('Login failed! Message: $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error during login: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error during login.'),
          backgroundColor: Colors.red,
        ),
      );
=======
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final email = data[
          'email']; // Assurez-vous d'ajuster la clé selon votre structure de données
      final userNom = data['nom'];

      setState(() {
        userEmail = email;
        nom = userNom;
      });
    } else {
      // Gérer les erreurs lors de la récupération de l'email
      print('Failed to load user email');
>>>>>>> 585e03ad591721c2ad1d0b5a55a8239c17d878b2
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      appBar: AppBar(
         backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('Connexion'),
=======
    // Vérifier si l'email est récupéré avant de construire l'interface utilisateur
    return MaterialApp(
      home: ProfilePage(email: userEmail, nom: nom),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String email;
  final String nom;

  const ProfilePage({Key? key, required this.email, required this.nom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: Text('Bonjour $nom'),
>>>>>>> 585e03ad591721c2ad1d0b5a55a8239c17d878b2
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
                    builder: (context) => const AddressPage(),
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
<<<<<<< HEAD
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _submit(context),
                child: const Text(
                  'Connexion',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 16.0),
              const Align(
                alignment: Alignment.center,
                child: Text('ou'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Naviguer vers la page d'inscription
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RegistrationPage()), // Remplacez RegistrationPage par le nom de votre page d'inscription
                  );
                },
                child: const Text(
                  'Inscription',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'En continuant, vous acceptez nos : ',
                style: TextStyle(fontSize: 14.0),
              ),
              RichText(
                text: TextSpan(
                  text: 'Conditions Générales d' 'utilisation ',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                 
                ),
              ),

              RichText(
                text: TextSpan(
                  text: 'Conditions Générales de Vente',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                
                ),
              ),

              RichText(
                text: TextSpan(
                  text: 'politique de confidentialité',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                 
                ),
              ),
             ElevatedButton(
  onPressed: () => (context),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'images/google_logo.png', // Ajoutez le logo Google à votre projet
        height: 20.0,
      ),
      SizedBox(width: 10.0),
      Text('Connecter avec Google'),
    ],
  ),
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    backgroundColor: Colors.red,
  ),
),

            ],
          ),
        ),
      ),
<<<<<<< HEAD
=======
=======
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const loginPage(),
                  ),
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
>>>>>>> 585e03ad591721c2ad1d0b5a55a8239c17d878b2
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
<<<<<<< HEAD
>>>>>>> f96a111 (feat:add`adress`api backend et flutter not finished)
=======
>>>>>>> 585e03ad591721c2ad1d0b5a55a8239c17d878b2
    );
  }
}
