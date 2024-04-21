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
import 'PasswordRecoveryPage.dart';
import 'registre.dart';
import './../aboutPaiement/paiement.dart';
import './../global.dart';
import './../aboutRestaurant/RestaurantDetail.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo/pages/aboutUser/auth_provider.dart' as CustomAuthProvider;


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
 late final GoogleSignIn googleSignIn = GoogleSignIn(clientId: '800045568375-qveeo76qnq8p14jmtn6jcsh087uild6p.apps.googleusercontent.com');

   CustomAuthProvider.AuthProvider? authProvider;
 bool obscurePassword = true;
 @override
  void initState() {
    super.initState();
    authProvider = Provider.of<CustomAuthProvider.AuthProvider>(context, listen: false);
  }
  void _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
     final authProvider = Provider.of<CustomAuthProvider.AuthProvider>(context, listen: false);

        final loginData = await authProvider.login(email, password);
        final userId = loginData['userId'];
        final nom = loginData['nom'];

     bool isLoggedIn = authProvider.currentUser != null;

          if (panier.origin == 'google') {
          await _signInWithGoogle(context);
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
  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }
  
Future<void> _signInWithGoogle(BuildContext context) async {
  if (authProvider == null) {
    return;
  }
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await authProvider!.firebaseAuth.signInWithCredential(authCredential);  
      if (authProvider!.firebaseAuth.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilPage()),
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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('Connexion'),
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
                  decoration: InputDecoration(
                    labelText: 'Saisissez votre mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: GestureDetector(
                      onTap: togglePasswordVisibility,
                      child: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  obscureText: obscurePassword,
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
ElevatedButton.icon(
  onPressed: () => _signInWithGoogle(context),
  icon: const Icon(Icons.login_rounded),
  label: const Text('Connexion avec Google'),
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    backgroundColor: Colors.red,
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
