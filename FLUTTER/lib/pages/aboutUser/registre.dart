// ignore_for_file: sort_child_properties_last, use_build_context_synchronously, library_private_types_in_public_api, use_key_in_widget_constructors, unused_import, dead_code


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

  // Added this line
 AutovalidateMode autovalidateMode =
      AutovalidateMode.disabled;
  void _submit(BuildContext context) async {
    setState(() {
      // Enable validation on submit
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

      // Capture the context before the asynchronous call
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
    const String apiUrl = "http://localhost:3000/register";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
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
   
        // Navigate to the main page and replace the current route
      } else {
        final data = json.decode(response.body);
        final String message = data['message'];

        if (message.toLowerCase().contains('password')) {
          // If the error message contains 'password', show it as a password error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password error: $message'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Otherwise, show a general error message
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
        title: const Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: autovalidateMode, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Enter your full name';
                  }
                  return null;
                },
                onSaved: (value) => nom = value ?? '',
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Enter your last name';
                  }
                  return null;
                },
                onSaved: (value) => prenom = value ?? '',
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Enter your phone number';
                  }
                  if (value!.length != 13) {
                    return 'Phone number must have 13 digits';
                  }
                  if (!RegExp(r'^0033[0-9]+$').hasMatch(value)) {
                    return 'Phone number must start with "0033" and contain only numeric digits';
                  }
                  return null;
                },
                onSaved: (value) => telephone = value ?? '',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
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
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Enter your password';
                  }

                  // Password must have at least 6 characters
                  if (value!.length < 6) {
                    return 'Password must have at least 6 characters';
                  }

                  // Check for at least 1 capital letter
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Password must contain at least 1 capital letter';
                  }

                  // Check for at least 1 number
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Password must contain at least 1 number';
                  }

                  // Check for at least 1 symbol
                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return 'Password must contain at least 1 symbol';
                  }

                  return null;
                },
                onSaved: (value) => password = value ?? '',
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  helperText:
                      'Minimum 6 characters, 1 capital letter, 1 number, 1 symbol',
                ),
                obscureText: true,
              ),
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? true || value != password) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onSaved: (value) => confirmPassword = value ?? '',
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _submit(context),
                child: const Text(
                  'Register',
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
    );
  }
}
