import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'aboutRestaurant/acceuil.dart';
class Panier {
  static final Panier _instance = Panier._internal();
  factory Panier() => _instance;

  Panier._internal();

  List<Article> articles = [];
  TimeOfDay? selectedTime;
  String? selectedRetraitMode;
  String? origin;
  void viderPanier() {
    articles.clear();
  }
 void getOrigin(){
  
 }
  void ajouterAuPanier1(Article article) {
    articles.add(article);
  }

  double getTotalPrix() {
    double total = 0;
    for (var articles in articles) {
      total += articles.prix * articles.quantite;
    }
    return total;
  }

  void updateCommandeDetails(
      String selectedRetraitMode, TimeOfDay selectedTime) {
    this.selectedRetraitMode = selectedRetraitMode;
    
    if (selectedTime != null) {
      this.selectedTime = selectedTime;
    }
  }

  String? getSelectedRetraitMode() {
    return selectedRetraitMode;
  }

  void printPanier() {
    if (kDebugMode) {
      print('Contenu du panier:');
    }
    for (var article in articles) {
      if (kDebugMode) {
        print(
          'Nom: ${article.nom}, Prix: ${article.prix}, Quantité: ${article.quantite}');
      }
    }
  }

  // Nouvelle méthode pour récupérer le temps actuel
  TimeOfDay getCurrentSelectedTime() {
    return selectedTime ?? TimeOfDay.now();
  }

  // Méthode pour mettre à jour selectedRetraitMode
 
}

class Article {
  // ignore: non_constant_identifier_names
  int id_item;
  String nom;
  String img;
  int prix;
  Restaurant restaurant;
  int quantite;

  Article({
    // ignore: non_constant_identifier_names
    required this.id_item,
    required this.nom,
    required this.img,
    required this.prix,
    required this.restaurant,
    required this.quantite,
  });
}
