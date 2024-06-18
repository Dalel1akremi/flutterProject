// ignore_for_file: use_build_context_synchronously

import 'package:demo/pages/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _nom;
  String? _email;
  String? _telephone;
  String? get token => _token;
 final GoogleSignIn googleSignIn = GoogleSignIn();

  set token(String? value) {
    _token = value;
    notifyListeners();
  }

  String? get userId => _userId;
  String? get nom => _nom;
  String? get email => _email;
  String? get telephone => _telephone;

  Future<void> initTokenFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _nom = prefs.getString('nom');
    _email = prefs.getString('email');
    _telephone = prefs.getString('telephone');
    notifyListeners(); 
  }
  bool get isAuthenticated => _token != null;

  Future<void> saveTokenToStorage(String token, String userId, String email,String nom,String telephone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', userId);
    await prefs.setString('email', email);
    await prefs.setString('nom',nom);
     await prefs.setString('telephone', telephone);
  }
Future<Map<String, dynamic>> login(String email, String password) async {
  String myIp = Global.myIp;
  
  try {
    final response = await http.post(
      Uri.parse("http://$myIp:3000/login"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      final userId = data['userId'];
      final nom = data['nom'];
      final telephone = data['telephone'];
      final message = data['message']; 

      _token = token;
      _userId = userId;
      _nom = nom;
      _email = email;
      _telephone = telephone;
      
      if (kDebugMode) {
        print('connexion réussie! UserId: $userId, nom: $nom, telephone: $telephone');
      }
      
      await saveTokenToStorage(token, userId, email, nom, telephone);

      _token = token;
      _userId = data['userId'];
      
      if (kDebugMode) {
        print('User ID de la réponse du serveur : $userId');
        print('User email de la réponse du serveur : $email');
      }
      
      notifyListeners();
      
      return {
        'token': token,
        'userId': userId,
        'nom': nom,
        'message': message, 
      };
    } else {
      final data = json.decode(response.body);
      final errorMessage = data['message'];
      throw Exception(errorMessage);
    }
  }catch (error) {
  if (error is String) {
    if (kDebugMode) {
      print('Erreur lors de la connexion : $error');
    } 
  } 
  
  rethrow;
}

}


  Future<void> logout(BuildContext context) async {
    _token = null;
    _userId = null;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('telephone');
    await prefs.remove('nom');
  
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const loginPage()),
    );
  }
}
