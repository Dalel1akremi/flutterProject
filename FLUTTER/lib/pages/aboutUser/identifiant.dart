import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:demo/pages/aboutUser/auth_provider.dart';
import 'profile.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({Key? key}) : super(key: key);

  @override
  _ProfileDetailsPageState createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  late String nom;
  late String prenom;
  late String numero;
  late String userId;
  late String _email;

  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();

  Future<void> getUserData() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3000/getUser?email=$_email'));

      if (response.statusCode == 200) {
        final Map<String, dynamic>? userData =
            json.decode(response.body) as Map<String, dynamic>;

        if (userData != null &&
            userData.containsKey('nom') &&
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
          

        } else {
          if (kDebugMode) {
            print('Failed to load user data. Response: ${response.body}');
          }
        }
      } else {
        if (kDebugMode) {
          print('Failed to load user data. Response: ${response.body}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error during HTTP request: $error');
      }
    }
  }
Future<void> updateUserData(String userEmail) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  final Map<String, dynamic> updatedData = {
    'nom': nomController.text,
    'prenom': prenomController.text,
    'telephone': numeroController.text,
  };

  try {
    final response = await http.put(
      Uri.parse(
          'http://localhost:3000/updateUser?email=${authProvider.email}'),
      body: jsonEncode(updatedData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      await getUserData();

      authProvider.saveTokenToStorage(
        authProvider.token!,
        userId, 
        authProvider.email!,
        nomController.text, 
        numeroController.text, 
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilPage(),
        ),
      );
    } else {
      if (kDebugMode) {
        print('Failed to update user data. Response: ${response.body}');
      }
      throw Exception('Failed to update user data');
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error during HTTP request: $error');
    }
  }
}


  @override
  void initState() {
    super.initState();

    _email = Provider.of<AuthProvider>(context, listen: false).email!;

    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('Identifiant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                updateUserData(_email);
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
    );
  }
}
