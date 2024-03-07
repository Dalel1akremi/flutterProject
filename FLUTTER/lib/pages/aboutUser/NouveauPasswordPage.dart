// ignore_for_file: file_names

import 'package:demo/pages/aboutUser/login.dart';
import 'package:flutter/foundation.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();

  String? _passwordValidationError;

  String? validatePassword(String value) {
    // Check if the password contains at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une lettre majuscule.';
    }

    // Check if the password contains at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une lettre minuscule.';
    }

    // Check if the password contains at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre.';
    }

    // Check if the password is at least 8 characters long
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }

    // Return null if the password meets all criteria
    return null;
  }

  Future<void> updatePassword() async {
    final String newPassword = newPasswordController.text;
    final String confirmNewPassword = confirmNewPasswordController.text;

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
          if (kDebugMode) {
            print('Password updated successfully');
          }

          // Navigate to the main page
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyApp()),
          ); 
        } else {
          // Handle other API response statuses
          if (kDebugMode) {
            print('Error updating password: ${responseData['message']}');
          }
        }
      } catch (error) {
        // Handle network or other errors
        if (kDebugMode) {
          print('Error: $error');
        }
      }
    } else {
      if (kDebugMode) {
        print('Email is null. Cannot update password.');
      }
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
        child: Form(
          key: _formKey,
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
                  String? validationResult = validatePassword(value!);

                  // Set the error message to be displayed
                  setState(() {
                    _passwordValidationError = validationResult;
                  });

                  // Return the validation result
                  return validationResult;
                },
              ),
              if (_passwordValidationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _passwordValidationError!,
                    style: const TextStyle(color: Colors.red),
                  ),
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
                onPressed: () async {
                  // Reset previous validation error
                  setState(() {
                    _passwordValidationError = null;
                  });

                  if (_formKey.currentState!.validate()) {
                    // If form is valid, proceed with update
                    updatePassword();
                  }
                  Navigator.push( 
                    context,
                     MaterialPageRoute(builder: (context) => const loginPage()),
                                );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  'Continuer',
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
