import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'registre.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // TODO: Appeler la fonction d'API pour la connexion avec _email et _password
      await loginUser(_email, _password);
    }
  }

  Future<void> loginUser(String email, String password) async {
    final Uri apiUrl = Uri.parse(
        'http://localhost:3000/login'); // Remplacez par l'URL de votre API

    try {
      final response = await http.post(
        apiUrl,
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Récupérer le token et autres informations nécessaires
        final String token = data['token'];
        final String userId = data['userId'];

        // TODO: Stocker le token localement (par exemple, dans les préférences partagées)
        // TODO: Naviguer vers la page suivante ou effectuer d'autres actions nécessaires

        print('Login successful! Token: $token, UserId: $userId');
      } else {
        final data = json.decode(response.body);
        final String message = data['message'];

        // TODO: Afficher un message d'erreur à l'utilisateur
        print('Login failed! Message: $message');
      }
    } catch (error) {
      // TODO: Gérer les erreurs, afficher un message d'erreur, etc.
      print('Error during login: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true || !value!.contains('@')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) => _email = value ?? '',
                decoration: InputDecoration(
                  labelText: 'Saisissez votre e-mail',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Mot de passe',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Enter your password';
                  }
                  return null;
                },
                onSaved: (value) => _password = value ?? '',
                decoration: InputDecoration(
                  labelText: 'Saisissez votre mot de passe',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Add action for password recovery
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Mot de passe oublié',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        // You can customize the color
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submit,
                child: Text(
                  'Connexion',
                  style: TextStyle(color: Colors.white), // Set text color
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                  // Set the button height
                ),
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: Text('ou'),
              ),
              SizedBox(height: 16.0),
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
                child: Text(
                  'Inscription',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
