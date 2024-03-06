import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _nom;
  String? _email;

  String? get token => _token;

  set token(String? value) {
    _token = value;
    notifyListeners();
  }

  String? get userId => _userId;
  String? get nom => _nom;
  String? get email => _email;

  // Méthode pour initialiser le token depuis le stockage
  Future<void> initTokenFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _nom = prefs.getString('nom');
    _email = prefs.getString('email');
    print('User ID from storage: $_userId');
    print('email from storage: $_email');
    notifyListeners();
  }

  bool get isAuthenticated => _token != null && _userId != null;

  Future<void> _saveTokenToStorage(String token, String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', userId);
    await prefs.setString('email', email);
  }

  Future<void> clearTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('email');
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

       
       

        if (kDebugMode) {
          print('login successful! Token:$token,UserId:$userId,nom:$nom');
        }
        // Save token to storage before setting it
        await _saveTokenToStorage(token, userId, email);

        _token = token;
        _userId = data['userId'];
        print('User ID from server response: $userId');
        print('User email from server response: $email');
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

  
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const loginPage()),
    );
  }
}
