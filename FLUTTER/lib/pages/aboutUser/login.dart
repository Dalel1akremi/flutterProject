// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_web_libraries_in_flutter, library_prefixes

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:demo/pages/aboutPaiement/panier.dart';
import 'package:demo/pages/aboutRestaurant/conditionDuitilisation.dart';
import 'package:demo/pages/aboutRestaurant/conditonDeVente.dart';
import 'package:demo/pages/aboutRestaurant/confidentialite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'PasswordRecoveryPage.dart';
import 'registre.dart';
import './../aboutPaiement/paiement.dart';
import './../global.dart';
import './../aboutRestaurant/RestaurantDetail.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:demo/pages/aboutUser/auth_provider.dart' as CustomAuthProvider;


// ignore: camel_case_types
class loginPage extends StatefulWidget {
  const loginPage({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<loginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  Panier panier = Panier();
  late final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId:
          '800045568375-qveeo76qnq8p14jmtn6jcsh087uild6p.apps.googleusercontent.com');

  CustomAuthProvider.AuthProvider? authProvider;
  bool obscurePassword = true;
   bool isFormValid = false;
 

  @override
  void initState() {
    super.initState();
    authProvider =
        Provider.of<CustomAuthProvider.AuthProvider>(context, listen: false);
  }

  void _validateForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isFormValid = true;
      });
    } else {
      setState(() {
        isFormValid = false;
      });
    }
  }

  void _submit(BuildContext context) async {
    _validateForm();

    if (isFormValid) {
      _formKey.currentState!.save();

      try {
        final authProvider = Provider.of<CustomAuthProvider.AuthProvider>(
            context,
            listen: false);

        final loginData = await authProvider.login(email, password);
        final userId = loginData['userId'];
        final nom = loginData['nom'];

        if (panier.origin == 'google') {
          await _signInWithGoogle(context);
          final googleUser = await googleSignIn.signIn();
          final googleEmail = googleUser?.email;
          if (kDebugMode) {
            print('Email associé au compte Google : $googleEmail');
          }
          return;
        }
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
        } else if (panier.origin == 'Restaurant') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RestaurantDetail()),
          );
        } else if (panier.origin == 'RestList') {
          panier.origine = "profil";
          Navigator.pushReplacementNamed(context, '/RestaurantScreen');
        }
      } catch (error) {
        String errorMessage = error.toString();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir des informations valides.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

 Future<void> _signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String name = googleUser.displayName ?? '';
      final String email = googleUser.email;     
          String nom = '';
          String prenom = '';
          List<String> nameParts = name.split(' ');
          nom = nameParts[0];
          if (nameParts.length > 1) {
            prenom = nameParts.sublist(1).join(' '); 
          }
                String myIp = Global.myIp;

              final response = await http.post(
            Uri.parse("http://$myIp:3000/registerGoogle"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'nom': nom,
              'prenom': prenom,
              'email': email,
            }),
          );
      if (response.statusCode == 200) {
       panier.origine = "profil";
          Navigator.pushReplacementNamed(context, '/RestaurantScreen');
      } else {

        if (kDebugMode) {
          print('Erreur lors de l\'appel à l\'API: ${response.statusCode}');
        }
 
        if (kDebugMode) {
          print('Détails de l\'erreur: ${response.body}');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la connexion avec Google'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error during Google sign in: $error');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erreur lors de la connexion avec Google'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('Connexion'),
        leading: authProvider != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  panier.origine = "profil";
                  Navigator.pushReplacementNamed(context, '/RestaurantScreen');
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  panier.origine = "acceuil";
                  Navigator.pushReplacementNamed(context, '/RestaurantScreen');
                },
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'E-mail',
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
                const SizedBox(height: 10),
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
                  decoration: InputDecoration(
                    labelText: 'Saisissez votre mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: GestureDetector(
                      onTap: togglePasswordVisibility,
                      child: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  obscureText: obscurePassword,
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: isFormValid ? Colors.green : Colors.black,
                  ),
                  child: const Text(
                    'Connexion',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.center,
                  child: Text('ou'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistrationPage()),
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
                const SizedBox(height: 10),
                const Text(
                  'En continuant, vous acceptez nos : ',
                  style: TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    text: '- Conditions Générales d\'utilisation ',
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
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    text: '- Conditions Générales de Vente',
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
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    text: '- Politique de confidentialité',
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
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: () => _signInWithGoogle(context),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset('images/google_logo.png'),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: const TextSpan(
                            text: 'Connecter avec Google',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
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
