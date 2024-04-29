// ignore_for_file: sort_child_properties_last, use_build_context_synchronously, library_private_types_in_public_api, use_key_in_widget_constructors, unused_import, dead_code

import 'package:demo/pages/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'package:flutter/services.dart';
import 'dart:developer';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String nom = '';
  String prenom = '';
  String telephone = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  void _submit(BuildContext context) async {
    setState(() {

    });

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final currentContext = context;

      try {
        await signUpUser(
          currentContext,
          nom,
          prenom,
          telephone,
          email,
          password,
          confirmPassword,
        );
      } catch (error) {
        // Handle registration errors
      }
    }
  }

  Future<void> signUpUser(
      BuildContext context,
      String nom,
      String prenom,
      String telephone,
      String email,
      String password,
      String confirmPassword) async {
            String myIp = Global.myIp;

    try {
      final response = await http.post(
        Uri.parse("http://$myIp:3000/register"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'telephone': telephone,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      );

      log('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token'];
        final String userId = data['userId'];

        log('Signup successful! Token: $token, UserId: $userId');

      } else {
        final data = json.decode(response.body);
        final String message = data['message'];

        if (message.toLowerCase().contains('password')) {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password error: $message'),
              backgroundColor: Colors.red,
            ),
          );
        } else {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signup done : $message'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const loginPage(),
            ),
          );
        }
      }
    } catch (error) {
      log('Error during signup: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error during signup.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
         child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: autovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Entrez votre nom';
                  }
                  return null;
                },
                onSaved: (value) => nom = value ?? '',
                decoration: const InputDecoration(
                  labelText: 'Votre nom',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Entrez votre prenom';
                  }
                  return null;
                },
                onSaved: (value) => prenom = value ?? '',
                decoration: const InputDecoration(
                  labelText: 'Votre prenom',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Entrez votre numero';
                  }
                  if (value!.length != 13) {
                    return 'Le numéro de téléphone doit comporter 13 chiffres';
                  }
                  if (!RegExp(r'^0033[0-9]+$').hasMatch(value)) {
                    return 'Le numéro de téléphone doit commencer par « 0033 » et contenir uniquement des chiffres.';
                  }
                  return null;
                },
                onSaved: (value) => telephone = value ?? '',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Votre numéro de téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Entrez une adresse mail valide';
                  }
                  if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                      .hasMatch(value!)) {
                    return 'Entrez une adresse mail valide';
                  }
                  return null;
                },
                onSaved: (value) => email = value ?? '',
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Votre Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Tapez votre mot de passe';
                  }

                  if (value!.length < 6) {
                    return 'Le mot de passe doit comporter au moins 6 caractères';
                  }

                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Le mot de passe doit contenir au moins 1 lettre majuscule';
                  }

                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Le mot de passe doit contenir au moins 1 chiffre';
                  }

                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return 'Le mot de passe doit contenir au moins 1 symbole';
                  }

                  return null;
                },
                onSaved: (value) => password = value ?? '',
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  helperText:
                      'Minimum 6 caractères, 1 lettre majuscule, 1 chiffre, 1 symbole',
                ),
                obscureText: true,
              ),
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true || value != password) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
                onSaved: (value) => confirmPassword = value ?? '',
                decoration: const InputDecoration(
                  labelText: 'Confirmez le mot de passe',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _submit(context),
                child: const Text(
                  'Registre',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
