// ignore_for_file: use_build_context_synchronously

import 'package:demo/pages/aboutUser/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'PasswordRecoveryPage.dart';
import 'registre.dart';
import './../aboutPaiement/paiement.dart';
import './../global.dart';
import './../aboutRestaurant/RestaurantDetail.dart';

// ignore: camel_case_types
class loginPage extends StatefulWidget {
  const loginPage({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<loginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  Panier panier = Panier();

  void _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final loginData = await authProvider.login(email, password);
        final userId = loginData['userId'];
        final nom = loginData['nom'];
 bool isLoggedIn = authProvider
                .isAuthenticated;
        if (panier.origin == 'panier') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PaymentScreen()),
          );
        } else if (panier.origin == 'Restaurant') {
          if (isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RestaurantDetail()),
            );
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                email: email,
                nom: nom,
                userId: userId,
              ),
            ),
          );
        }
      } catch (error) {
        if (kDebugMode) {
          print('Error during login: $error');
        }
        String errorMessage = 'Error during login. Please try again.';

        if (error is FormatException) {
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
                        builder: (context) => const PasswordRecoveryPage(),
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
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  'Connexion',
                  style: TextStyle(color: Colors.white),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  'Inscription',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'En continuant, vous acceptez nos : ',
                style: TextStyle(fontSize: 14.0),
              ),
              RichText(
                text: const TextSpan(
                  text: 'Conditions Générales d' 'utilisation ',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              ),
              RichText(
                text: const TextSpan(
                  text: 'Conditions Générales de Vente',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              ),
              RichText(
                text: const TextSpan(
                  text: 'politique de confidentialité',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => (context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color.fromARGB(255, 107, 101, 101),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'images/google_logo.png',
                      height: 20.0,
                    ),
                    const SizedBox(width: 10.0),
                    const Text('Connecter avec Google'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
