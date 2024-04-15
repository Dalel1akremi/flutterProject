import 'dart:async';
import 'dart:convert';
import 'package:demo/pages/aboutUser/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class CommandesModel with ChangeNotifier {
  List<Map<String, dynamic>> commandesEncours = [];
  List<Map<String, dynamic>> commandesPass = [];
  
  String? lastEncoursState;
  String? lastPassState;
  
  Timer? _timer;

  Future<void> updateCommandesEncours(BuildContext context) async {
    final newCommandes = await fetchCommandesEncours(context);
    commandesEncours = newCommandes;
    notifyListeners();
  }

  Future<void> updateCommandesPass(BuildContext context) async {
    final newCommandes = await fetchCommandesPass(context);
    commandesPass = newCommandes;
    notifyListeners();
  }

  Future<void> checkEncoursState(BuildContext context) async {
    final newCommandes = await fetchCommandesEncours(context);
    final currentState = jsonEncode(newCommandes);

    if (currentState != lastEncoursState) {
      commandesEncours = newCommandes;
      notifyListeners();
      lastEncoursState = currentState;
    }
  }

  Future<void> checkPassState(BuildContext context) async {
    final newCommandes = await fetchCommandesPass(context);
    final currentState = jsonEncode(newCommandes);

    if (currentState != lastPassState) {
      commandesPass = newCommandes;
      notifyListeners();
      lastPassState = currentState;
    }
  }

  void startPolling(BuildContext context) {
    stopPolling();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await checkEncoursState(context);
      await checkPassState(context);
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }

  Future<List<Map<String, dynamic>>> fetchCommandesEncours(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      debugPrint('User not authenticated. Returning empty list.');
      return [];
    }

    final idUser = authProvider.userId;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getCommandesEncours?id_user=$idUser'),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);

        if (responseBody is List) {
          final List<Map<String, dynamic>> commandes = responseBody
              .where((commande) =>
                  commande != null &&
                  commande['id_items'] != null &&
                  (commande['id_items'] as List).isNotEmpty)
              .map<Map<String, dynamic>>((commande) {
            final items = commande['id_items'] as List;
            final List<Map<String, dynamic>> articles = items.map((item) {
              return {
                'nom': item['nom'],
                'prix': item['prix'] ?? 0,
                'quantite': item['quantite'] ?? 0,
                'elements_choisis':item['elements_choisis'],
                'remarque':item['remarque'],
              };
            }).toList();

            return {
              'commande': commande['numero_commande'],
              'temps': commande['temps'],
              'mode_retrait': commande['mode_retrait'],
              'Total': commande['montant_Total'],
              'etat': commande['etat'],
              'numero_telephone':commande[ 'numero_telephone'],
              'adresse':commande['adresse'],
              'nom_restaurant': commande['nom_restaurant'], 
              'articles': articles,
            };
          }).toList();

          debugPrint('Commandes en cours: $commandes');
          return commandes;
        } else {
          debugPrint('Response body is not a List');
          return [];
        }
      } else {
        throw Exception('Failed to load commandes en cours');
      }
    } catch (error) {
      debugPrint('Error: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCommandesPass(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final idUser = authProvider.userId;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getCommandesPasse?id_user=$idUser'),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);

        if (responseBody is List) {
          final List<Map<String, dynamic>> commandes = responseBody
              .where((commande) =>
                  commande != null &&
                  commande['id_items'] != null &&
                  (commande['id_items'] as List).isNotEmpty)
              .map<Map<String, dynamic>>((commande) {
            final items = commande['id_items'] as List;
            final List<Map<String, dynamic>> articles = items.map((item) {
              return {
                'nom': item['nom'],
                'prix': item['prix'] ?? 0,
                'quantite': item['quantite'] ?? 0,
                'elements_choisis':item['elements_choisis'],
                'remarque':item['remarque'],
              };
            }).toList();

            return {
              'commande': commande['numero_commande'],
              'temps': commande['temps'],
              'mode_retrait': commande['mode_retrait'],
              'Total': commande['montant_Total'],
              'etat': commande['etat'],
               'numero_telephone':commande[ 'numero_telephone'],
               'adresse':commande['adresse'],
                'nom_restaurant': commande['nom_restaurant'], 
              'articles': articles,
            };
          }).toList();

          debugPrint('Commandes: $commandes');
          return commandes;
        } else {
          debugPrint('Response body is not a List');
          return [];
        }
      } else {
        throw Exception('Failed to load commandes');
      }
    } catch (error) {
      debugPrint('Error: $error');
      return [];
    }
  }
}
