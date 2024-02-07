
// ignore_for_file: file_names, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import 'dart:convert';

class NouveauPasswordPage extends StatefulWidget {
  final String? email; // Make email nullable

  const NouveauPasswordPage({Key? key, required this.email}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _NouveauPasswordPageState createState() => _NouveauPasswordPageState();
}

class _NouveauPasswordPageState extends State<NouveauPasswordPage> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  String? validatePassword(String value) {
    return null;
  
    // Password validation logic...
    // Return null if the password is valid, otherwise return an error message.
  }

  Future<void> updatePassword() async {
    final String newPassword = newPasswordController.text;
    final String confirmNewPassword = confirmNewPasswordController.text;

    // Validate passwords
    String? validationResult = validatePassword(newPassword);
    if (validationResult != null) {
      // Show validation error
      print('Validation Error: $validationResult');
      return;
    }

    if (newPassword != confirmNewPassword) {
      // Passwords do not match
      print('Passwords do not match');
      return;
    }

    if (widget.email != null) {
      try {
        final response = await http.put(
          Uri.parse(
              'http://localhost:3000/new_password?email=${Uri.encodeQueryComponent(widget.email!)}'),
          body: {
            'newPassword': newPassword,
            'confirmNewPassword': confirmNewPassword,
          },
        );

        final responseData = json.decode(response.body);

        if (response.statusCode == 200 && responseData['success']) {
          // Password updated successfully
          print('Password updated successfully');

          // Navigate to the main page
          Navigator.pushReplacement(
            context,
<<<<<<< HEAD
            MaterialPageRoute(builder: (context) => const MyApp()),
=======
            MaterialPageRoute(builder: (context) => MyApp()),
>>>>>>> 2a56b9e (finished `updatepassword`dart and backend)
          ); // Replace with your actual route
        } else {
          // Handle other API response statuses
          print('Error updating password: ${responseData['message']}');
        }
      } catch (error) {
        // Handle network or other errors
        print('Error: $error');
      }
    } else {
      print('Email is null. Cannot update password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réinitialisation du Mot de Passe'),
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16.0),
            const Text(
              'Nouveau Mot de Passe',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Saisissez votre Nouveau Mot de Passe',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                return validatePassword(value!);
              },
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Confirmez le Nouveau Mot de Passe',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: confirmNewPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmez le Nouveau Mot de Passe',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value != newPasswordController.text) {
                  return 'Les mots de passe ne correspondent pas.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                updatePassword();
              },
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}
