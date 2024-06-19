// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'package:demo/pages/aboutUser/auth_provider.dart';
import 'package:demo/pages/global.dart';
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
      // ignore: use_build_context_synchronously
      await checkPassState(context);
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }

  Future<List<Map<String, dynamic>>> fetchCommandesEncours(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
   

    final email = authProvider.email;

    try {
      String myIp = Global.myIp;
      final response = await http.get(
        Uri.parse('http://$myIp:3000/getCommandesEncours?email=$email'),
      );
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
                'elements_choisis': item['elements_choisis'],
                'remarque': item['remarque'],
              };
            }).toList();

            return {
              'commande': commande['numero_commande'],
              'temps': commande['temps'],
              'mode_retrait': commande['mode_retrait'],
              'Total': commande['montant_Total'],
              'etat': commande['etat'],
              'numero_telephone': commande['numero_telephone'],
              'adresse': commande['adresse'],
              'nom_restaurant': commande['nom_restaurant'],
              'articles': articles,
            };
          }).toList();
          return commandes;
        } else {
          return [];
        }
      } else {
        throw Exception('Échec du chargement des commandes en cours');
      }
    } catch (error) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCommandesPass(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = authProvider.email;

    try {
     String myIp = Global.myIp;
      final response = await http.get(
        Uri.parse('http://$myIp:3000/getCommandesPasse?email=$email'),
      );
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
                'elements_choisis': item['elements_choisis'],
                'remarque': item['remarque'],
              };
            }).toList();

            return {
              'commande': commande['numero_commande'],
              'temps': commande['temps'],
              'mode_retrait': commande['mode_retrait'],
              'Total': commande['montant_Total'],
              'etat': commande['etat'],
              'numero_telephone': commande['numero_telephone'],
              'adresse': commande['adresse'],
              'nom_restaurant': commande['nom_restaurant'],
              'articles': articles,
            };
          }).toList();

          return commandes;
        } else {
          return [];
        }
      } else {
        throw Exception('Échec du chargement des commandes');
      }
    } catch (error) {
      return [];
    }
  }
}
