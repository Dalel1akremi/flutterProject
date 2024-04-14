// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_web_libraries_in_flutter

import 'package:demo/pages/aboutPaiement/panier.dart';
import 'package:demo/pages/aboutRestaurant/conditionDuitilisation.dart';
import 'package:demo/pages/aboutRestaurant/conditonDeVente.dart';
import 'package:demo/pages/aboutRestaurant/confidentialite.dart';
import 'package:demo/pages/aboutUser/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'PasswordRecoveryPage.dart';
import 'registre.dart';
import './../aboutPaiement/paiement.dart';
import './../global.dart';
import './../aboutRestaurant/RestaurantDetail.dart';
import 'dart:html';
import 'dart:async';
import 'dart:js' as js;


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
String clientId = '800045568375-qveeo76qnq8p14jmtn6jcsh087uild6p.apps.googleusercontent.com';
String redirectUri = 'http://localhost:49334';
String scope = 'email'; 

String buildAuthUrl() {
  return 'https://accounts.google.com/o/oauth2/auth?'
         'client_id=$clientId&'
         'response_type=code&'
         'redirect_uri=$redirectUri&'
         'scope=$scope';
}

Future<void> _handleSignIn(BuildContext context) async {
  try {

    String authUrl = buildAuthUrl();

    window.open(authUrl, 'google-auth');

    final completer = Completer();

    void checkAuthInstance(int attempts) {
      if (attempts >= 10) {
        completer.completeError('Timeout: authInstance est null après 10 tentatives.');
        return;
      }

      final authInstance = js.context['gapi']['auth2'].callMethod('getAuthInstance');
      
      if (authInstance != null) {
        completer.complete(authInstance);
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          checkAuthInstance(attempts + 1);
        });
      }
    }

    checkAuthInstance(0);

    final authInstance = await completer.future;
    
    if (authInstance != null) {
      final googleUser = await authInstance.callMethod('signIn');
  
    } else {
      if (kDebugMode) {
        print('Erreur: authInstance est null.');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erreur lors de la connexion avec Google: $e');
    }
  }
}

  void _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final loginData = await authProvider.login(email, password);
        final userId = loginData['userId'];
        final nom = loginData['nom'];

        bool isLoggedIn = authProvider.isAuthenticated;
        if (panier.origin == 'panier') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PaymentScreen()),
          );
        } else if (panier.origin == 'livraison') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PanierPage()),
          );
        } else if (panier.origin == 'Restaurant' && isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RestaurantDetail()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfilPage()),
          );
        }
      } catch (error) {
        if (kDebugMode) {
          print('Error during login: $error');
        }
        String errorMessage = 'Adresse ou Mot de passe invalide';

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
                text: TextSpan(
                  text: 'Conditions Générales d\'utilisation ',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TermsOfUsePage()),
                      );
                    },
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Conditions Générales de Vente',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SalesTermsPage()),
                      );
                    },
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'politique de confidentialité',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyPage()),
                      );
                    },
                ),
              ),
              ElevatedButton(
                onPressed: () => _handleSignIn(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color.fromARGB(255, 237, 21, 21),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'images/google_logo.png',
                      height: 20.0,
                    ),
                    const SizedBox(width: 10.0),
                    const Text(
                      'Connecter avec Google',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                      ),
                    ),
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
