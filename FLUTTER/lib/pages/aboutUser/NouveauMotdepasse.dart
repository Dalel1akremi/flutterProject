// ignore_for_file: file_names, use_super_parameters, use_build_context_synchronously

import 'package:demo/pages/aboutUser/login.dart';
import 'package:demo/pages/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NouveauPasswordPage extends StatefulWidget {
  final String? email; 

  const NouveauPasswordPage({Key? key, required this.email}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _NouveauPasswordPageState createState() => _NouveauPasswordPageState();
}

class _NouveauPasswordPageState extends State<NouveauPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();
bool obscureNewPassword = true;
bool obscureConfirmPassword = true;
  String? _passwordValidationError;

  String? validatePassword(String value) {
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une lettre majuscule.';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une lettre minuscule.';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre.';
    }

    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }

    return null;
  }

  Future<void> updatePassword() async {
    final String newPassword = newPasswordController.text;
    final String confirmNewPassword = confirmNewPasswordController.text;

    if (widget.email != null) {
          String myIp = Global.myIp;

      try {
        final response = await http.put(
          
          Uri.parse(
              'http://$myIp:3000/new_password?email=${Uri.encodeQueryComponent(widget.email!)}'),
          body: {
            'newPassword': newPassword,
            'confirmNewPassword': confirmNewPassword,
          },
        );

        final responseData = json.decode(response.body);

        if (response.statusCode == 200 && responseData['success']) {
          if (kDebugMode) {
            print('Mot de passe mis à jour avec succès');
          }

        
        } else {
          if (kDebugMode) {
            print('Erreur lors de la mise à jour du mot de passe : ${responseData['message']}');
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print('Erreur: $error');
        }
      }
    } else {
      if (kDebugMode) {
        print('L\'e-mail est nul. Impossible de mettre à jour le mot de passe.');
      }
    }
  }
 void toggleNewPasswordVisibility() {
    setState(() {
      obscureNewPassword = !obscureNewPassword;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      obscureConfirmPassword = !obscureConfirmPassword;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Réinitialisation du Mot de Passe'),
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
         child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 16.0),
              const Text(
                'Nouveau mot de passe',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
             TextFormField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword, 
                  decoration: InputDecoration(
                    labelText: 'Saisissez votre nouveau mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: GestureDetector(
                      onTap: toggleNewPasswordVisibility, 
                      child: Icon(
                        obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                validator: (value) {
                  String? validationResult = validatePassword(value!);
                  setState(() {
                    _passwordValidationError = validationResult;
                  });
                  return validationResult;
                },
              ),

              TextFormField(
                  controller: confirmNewPasswordController,
                  obscureText: obscureConfirmPassword, 
                  decoration: InputDecoration(
                    labelText: 'Confirmez le Nouveau Mot de Passe',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: GestureDetector(
                      onTap: toggleConfirmPasswordVisibility, 
                      child: Icon(
                        obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Les mots de passe ne correspondent pas.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16.0),
               ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _passwordValidationError = null;
                    });

                    if (_formKey.currentState!.validate()) {
                      final String newPassword = newPasswordController.text;
                      final String confirmNewPassword = confirmNewPasswordController.text;

                      if (newPassword == confirmNewPassword) {

                        await updatePassword();

                        if (_passwordValidationError == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const loginPage()),
                          );
                        }
                      } else {
                        setState(() {
                          _passwordValidationError = 'Les mots de passe ne correspondent pas.';
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(color: Colors.white),
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
