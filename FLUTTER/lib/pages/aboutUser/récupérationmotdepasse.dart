// ignore_for_file: dead_code, use_build_context_synchronously, avoid_print, library_private_types_in_public_api, file_names

import 'package:demo/pages/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'NouveauMotdepasse.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController validationCodeController =
      TextEditingController();

  bool isEmailValid = true; 

  String emailMessage = ''; 

  Future<void> sendResetPasswordRequest() async {
    final String email = emailController.text;
    String myIp = Global.myIp;

    try {
      final response = await http.post(
        Uri.parse(
            'http://$myIp:3000/reset_password'), 
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        
        print('E-mail de réinitialisation du mot de passe envoyé avec succès');
  
        setState(() {
          isEmailValid = true;
          emailMessage = 'Le mail existe. Vous pouvez procéder à la réinitialisation.';
        });
      } else if (response.statusCode == 404) {

        setState(() {
          isEmailValid = false;
          emailMessage = 'Email non trouvé. Veuillez entrer un email valide.';
        });
      } else {

        setState(() {
          isEmailValid = false;
          emailMessage = 'Erreur lors de l\'envoi de l\'e-mail de réinitialisation du mot de passe : ${response.statusCode}';
        });
      }
    } catch (error) {

      print('Error: $error');

      setState(() {
        isEmailValid = false;
        emailMessage = 'Error: $error';
      });
    }
  }

  Future<void> validateCode() async {
    final String email = emailController.text;
    final String validationCode = validationCodeController.text;

    try {
         String myIp = Global.myIp;

      final response = await http.post(
        Uri.parse(
            'http://$myIp:3000/validate_code'), 
        body: {'email': email, 'validationCode': validationCode},
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NouveauPasswordPage(email:email)),
        );
      } else {
        
        print('Erreur lors de la validation du code : ${response.statusCode}');
      }
    } catch (error) {
      
      print('Erreur: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('Mot de passe oubliée'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
         child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16.0),
            const Text(
              'Pas d\'inquiétude, nous allons vous envoyer le code de validation à l\'adresse suivante :',
              style: TextStyle(fontSize: 16.0),
            ),
             const Row(
                children: [
                  Icon(
                    Icons.looks_one, 
                    color: Colors.black, 
                  ),
                  SizedBox(width: 10), 
                  Text(
                    'Réinitialiser mon mot de passe',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16.0),
            const Text(
              'E-mail',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Saisissez votre E-mail',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true || !value!.contains('@')) {
           
                  return 'Enterer une adresse email valide';
                }
    
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isEmailValid
                  ? () {
                      sendResetPasswordRequest();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.black,
              ),
              child: const Text(
                'je réinitialise mon mot de passe',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              emailMessage,
              style: TextStyle(
                color: isEmailValid ? Colors.green : Colors.red,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Merci de vérifier vos courriers indésirables après avoir cliqué sur *Je réinitialise mon mot de passe"',
              style: TextStyle(fontSize: 16.0),
            ),
             const Row(
                children: [
                  Icon(
                    Icons.looks_two, 
                    color: Colors.black, 
                  ),
                  SizedBox(width: 10), 
                  Text(
                    'Confirmer le code',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16.0),
            const Text(
              'Code',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: validationCodeController,
              decoration: const InputDecoration(
                labelText: 'Saisissez le code de 6 chiffres ',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  
                  return 'Enterer le code de validation';
                }
      
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                validateCode();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.black,
              ),
              child: const Text(
                'Valider le code ',
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

void main() {
  runApp(const MaterialApp(
    home: PasswordRecoveryPage(),
  ));
}