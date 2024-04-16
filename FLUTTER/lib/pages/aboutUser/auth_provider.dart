import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _nom;
  String? _email;
  String? _telephone;
  String? get token => _token;

  set token(String? value) {
    _token = value;
    notifyListeners();
  }

  String? get userId => _userId;
  String? get nom => _nom;
  String? get email => _email;
  String? get telephone => _telephone;

  // Méthode pour initialiser le token depuis le stockage
  Future<void> initTokenFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _nom = prefs.getString('nom');
    _email = prefs.getString('email');
    _telephone = prefs.getString('telephone');
    notifyListeners(); // notifier les écouteurs une fois que les valeurs ont été récupérées
  
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
  // Méthode pour vérifier si un utilisateur est authentifié
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
    const String apiUrl = "http://localhost:3000/login";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
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
        final telephone=data['telephone'];
        // Mettez à jour l'état de l'authentification
      _token = token;
      _userId = userId;
      _nom = nom;
      _email = email;
      _telephone = telephone;
        if (kDebugMode) {
          print('login successful!UserId:$userId,nom:$nom,telephone:$telephone');
        }
        // Save token to storage before setting it
        await saveTokenToStorage(token, userId, email,nom,telephone);

        _token = token;
        _userId = data['userId'];
        if (kDebugMode) {
          print('User ID from server response: $userId');
        }
        if (kDebugMode) {
          print('User email from server response: $email');
        }
        notifyListeners();
        return {
          'token': token,
          'userId': userId,
          'nom': nom,
        }; // Return the necessary data
      } else {
        throw Exception('Login failed');
      }
    } catch (error) {
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
  
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const loginPage()),
    );
  }
}
