// ignore_for_file: use_build_context_synchronously

import 'package:demo/pages/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _nom;
  String? _email;
  String? _telephone;
  String? get token => _token;
 final GoogleSignIn googleSignIn = GoogleSignIn();
 final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
   FirebaseAuth get firebaseAuth => _firebaseAuth;
  User? get currentUser => _firebaseAuth.currentUser;
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
if (kDebugMode) {
      print('User ID from storage: $_userId');
    }
    if (kDebugMode) {
      print('Email from storage: $_email');
    }
    if (kDebugMode) {
      print('Telephone from storage: $_telephone');
    } 
    if (kDebugMode) {
      print('Nom from storage: $_nom');
    } 
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

  Future<void> clearTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('nom');
    await prefs.remove('telephone');

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
        print('login successful! UserId: $userId, nom: $nom, telephone: $telephone');
      }
      
      await saveTokenToStorage(token, userId, email, nom, telephone);

      _token = token;
      _userId = data['userId'];
      
      if (kDebugMode) {
        print('User ID from server response: $userId');
        print('User email from server response: $email');
      }
      
      notifyListeners();
      
      return {
        'token': token,
        'userId': userId,
        'nom': nom,
        'message': message, // Retourner également le message renvoyé par le backend
      };
    } else {
      final data = json.decode(response.body);
      final errorMessage = data['message']; // Message d'erreur renvoyé par le backend
      throw Exception(errorMessage);
    }
  }catch (error) {
  if (error is String) {
    if (kDebugMode) {
      print('Error during login: $error');
    } // Afficher le message d'erreur dans le terminal
  } 
  
  rethrow;
}

}

  Future<void> signInWithCredential(AuthCredential credential) async { // Utilisation de AuthCredential au lieu de OAuthCredential
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userId = user.uid;
        final email = user.email;
        final nom = user.displayName ?? '';
        const telephone = ''; // Vous pouvez obtenir le numéro de téléphone si nécessaire

        _userId = userId;
        _nom = nom;
        _email = email;
        _telephone = telephone;

        if (kDebugMode) {
          print('Sign-in successful! UserId: $userId, Nom: $nom, Email: $email');
        }

    await saveTokenToStorage('firebase_token', userId , email ?? '', nom , telephone );

        notifyListeners();
      } else {
        throw Exception('Sign-in failed');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error signing in: $error');
      }
      rethrow;
    }
  }

  Future<void> signInWithOAuthCredential(OAuthCredential credential) async {
    try {
      await signInWithCredential(credential); // Utilisation de signInWithCredential pour Google sign-in
    } catch (error) {
      if (kDebugMode) {
        print('Error signing in with Google: $error');
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
