// ignore_for_file: file_names

import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  final String _userEmailKey = 'userEmail'; 

  String? _userEmail;

  String? get userEmail => _userEmail;

  Future<void> setUserEmail(String email) async {

    _userEmail = email;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email); // Enregistrez l'e-mail dans SharedPreferences
  }

  Future<void> clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    _userEmail = null; // Effacez également la valeur en mémoire
  }
}
