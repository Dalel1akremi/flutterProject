
// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'registre.dart';
import 'PasswordRecoveryPage.dart';
import '../../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  void _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter both email and password.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        await loginUser(context, email, password);
      } catch (error) {
        print('Error during login: $error');
        String errorMessage = 'Error during login. Please try again.';

        if (error is http.ClientException) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else if (error is FormatException) {
          errorMessage = 'Invalid response format from the server.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> loginUser(
      BuildContext context, String email, String password) async {
    const String apiUrl = "http://localhost:3000/login";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token'];
        final String userId = data['userId'];

       

        print('Login successful! Token: $token, UserId: $userId');

       
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MyApp()),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
               TextFormField(
               validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Enter a valid email address';
                  }
                  if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                      .hasMatch(value!)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) => email = value ?? '',
                decoration: const InputDecoration(
                  labelText: 'Saisissez votre e-mail',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
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
                onSaved: (value) => password = value ?? '',
                decoration: const InputDecoration(
                  labelText: 'Saisissez votre mot de passe',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8.0), 
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                  
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PasswordRecoveryPage(),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Mot de passe oublié',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
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
    );
  }
}
