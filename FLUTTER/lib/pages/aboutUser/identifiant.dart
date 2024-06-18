// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:convert';
import 'package:demo/pages/aboutRestaurant/RestaurantList.dart';
import 'package:demo/pages/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  _ProfileDetailsPageState createState() => _ProfileDetailsPageState();
}
class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  late String nom;
  late String prenom;
  late String numero;
  late String userId;
  late String _email = '';
  Panier panier = Panier();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getEmailFromLocalStorage();
  }

  Future<void> getEmailFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email') ?? '';
    });

    await getUserData();
  }

  Future<void> getUserData() async {
    try {
      String myIp = Global.myIp;
      final response = await http
          .get(Uri.parse('http://$myIp:3000/getUser?email=$_email'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData =
            json.decode(response.body) as Map<String, dynamic>;
       
        if (userData.containsKey('nom') &&
            userData.containsKey('prenom') &&
            userData.containsKey('telephone')) {
          setState(() {
            nom = userData['nom'];
            prenom = userData['prenom'];
            numero = userData['telephone'];
            userId = userData['_id'] ?? '';
          });

          nomController.text = nom;
          prenomController.text = prenom;
          numeroController.text = numero;
        } 
      } else {
        if (kDebugMode) {
          print('Échec du chargement des données utilisateur. Réponse: ${response.body}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Erreur lors de la requête HTTP : $error');
      }
    }
  }

  Future<bool> saveTokenToStorage(
      String token, String userId, String userEmail, String nom, String numero) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', userId);
      await prefs.setString('userEmail', userEmail);
      return true; 
      } catch (e) {
      if (kDebugMode) {
        print('Échec de l\'enregistrement des données sur le stockage local : $e');
      }
      return false;
       }
  }
Future<bool> saveNameToStorage(String name) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nom', name);
    return true;
    } catch (e) {
    if (kDebugMode) {
      print('Échec de l\'enregistrement du nom sur le stockage local : $e');
    }
    return false;
     }
}

  Future<void> updateUserData(BuildContext context, String userEmail) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String token = prefs.getString('token') ?? '';
  final String userId = prefs.getString('userId') ?? '';
  // Récupérer les données mises à jour depuis les contrôleurs
  final String nom = nomController.text;
  final String prenom = prenomController.text;
  final String telephone = numeroController.text;

  if (telephone.length != 13) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Le numéro de téléphone doit contenir exactement 13 chiffres.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final Map<String, dynamic> updatedData = {
    'nom': nom,
    'prenom': prenom,
    'telephone': telephone,
  };

  try {    
    String myIp = Global.myIp;

    final response = await http.put(
      Uri.parse('http://$myIp:3000/updateUser?email=$_email'),
      body: jsonEncode(updatedData),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      await getUserData();
      
      final bool savedSuccessfully = await saveTokenToStorage(
        token,
        userId,
        _email,
        nom,
        telephone,
      );

      if (savedSuccessfully) {
        final bool nameSaved = await saveNameToStorage(nom);
        if (!nameSaved) {
          if (kDebugMode) {
            print('Échec de l\'enregistrement du nom sur le stockage local.');
          }
        }
      } else {
        if (kDebugMode) {
          print('Données non enregistrées.');
        }
      }

      panier.origine = 'profil';
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RestaurantScreen(index: 2,)),
      );
    } else {
      if (kDebugMode) {
        print('Échec de la mise à jour des données utilisateur. Réponse: ${response.body}');
      }
      throw Exception('Échec de la mise à jour des données utilisateur');
    }
  } catch (error) {
    if (kDebugMode) {
      print('Context: $context');
      print('Token: $token');
      print('UserId: $userId');
      print(' during HTTP request: $error');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('Identifiant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
         child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                const Text(
                  'Nom:    ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: nomController,
                    decoration: const InputDecoration(),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                const Text(
                  'Prénom:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: prenomController,
                    decoration: const InputDecoration(),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.phone),
                const SizedBox(width: 8),
                const Text(
                  'Numéro:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
      child: TextField(
        controller: numeroController,
        decoration: const InputDecoration(),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(13) 
        ],
      ),
    ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.email),
                const SizedBox(width: 8),
                const Text(
                  'Email:    ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _email,
                    style: const TextStyle(
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.black,
                      decorationThickness: 2.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateUserData(context, _email);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.black,
              ),
              child: const Text(
                'Enregistrer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
