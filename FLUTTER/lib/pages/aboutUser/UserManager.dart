import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  String? _userEmailKey = 'userEmail'; // Supprimez le mot-clé 'static' ici

  String? _userEmail;

  String? get userEmail => _userEmail;

  Future<void> setUserEmail(String email) async {
    // Vous pouvez ajouter ici la logique de stockage de l'e-mail dans votre application
    _userEmail = email;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey!, email); // Enregistrez l'e-mail dans SharedPreferences
  }

  Future<void> clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey!);
    _userEmail = null; // Effacez également la valeur en mémoire
  }
}
