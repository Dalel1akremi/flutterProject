// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'NouveauPasswordPage.dart';

class PasswordRecoveryPage extends StatefulWidget {
  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController validationCodeController =
      TextEditingController();

  bool isEmailValid = true; // Add this variable to track email validity

  String emailMessage = ''; // Add this variable to store the email validation message

  Future<void> sendResetPasswordRequest() async {
    final String email = emailController.text;

    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:3000/reset_password'), // Replace with your actual API URL
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        // Password reset email sent successfully
        // You can display a success message or navigate to the next screen
        print('Password reset email sent successfully');
        // Enable the button since email is valid
        setState(() {
          isEmailValid = true;
          emailMessage = 'Email exists. You can proceed to reset.';
        });
      } else if (response.statusCode == 404) {
        // Email not found
        setState(() {
          isEmailValid = false;
          emailMessage = 'Email not found. Please enter a valid email.';
        });
      } else {
        // Handle other errors
        setState(() {
          isEmailValid = false;
          emailMessage = 'Error sending password reset email: ${response.statusCode}';
        });
      }
    } catch (error) {
      // Handle network or other errors
      print('Error: $error');
      // Disable the button since email is invalid
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
      final response = await http.post(
        Uri.parse(
            'http://localhost:3000/validate_code'), // Replace with your actual API URL
        body: {'email': email, 'validationCode': validationCode},
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NouveauPasswordPage()),
        );
      } else {
        // Handle error - display an error message to the user
        print('Error validating code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(222, 212, 133, 14),
        title: Text('Mot de passe oubliée'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 16.0),
            Text(
              'Pas d\'inquiétude, nous allons vous envoyer le code de validation à l\'adresse suivante :',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Reinitialise mon mot de passe',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'E-mail',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Saisissez votre Email',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true || !value!.contains('@')) {
                  // Email is invalid
                  return 'Enter a valid email address';
                }
                // Email is valid
                return null;
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isEmailValid
                  ? () {
                      sendResetPasswordRequest();
                    }
                  : null,
              child: const Text(
                'je réinitialise mon mot de passe',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              emailMessage,
              style: TextStyle(
                color: isEmailValid ? Colors.green : Colors.red,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Merci de vérifier vos courriers indésirables après avoir cliqué sur *Je réinitialise mon mot de passe"',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Reinitialise mon mot de passe',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Text(
              'Code',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: validationCodeController,
              decoration: InputDecoration(
                labelText: 'saissisez le Code de 6 chiffre ',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  // Validation code is empty
                  return 'Enter the validation code';
                }
                // Validation code is not empty
                return null;
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                validateCode();
              },
              child: const Text(
                'Valider le code ',
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
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PasswordRecoveryPage(),
  ));
}
