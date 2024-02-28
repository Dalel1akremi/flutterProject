import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'aboutRestaurant/acceuil.dart';
class Panier {
  static final Panier _instance = Panier._internal();
  factory Panier() => _instance;

  Panier._internal();
List<String> elementsChoisis = [];
  List<Article> articles = [];
  TimeOfDay? selectedTime;
  String? selectedRetraitMode;
  Restaurant? selectedRestaurant;
   String? userAddress;
  String? origin;
  void viderPanier() {
    articles.clear();
  }
 void getOrigin(){
  
 }
  void ajouterElementChoisi(String element) {
    elementsChoisis.add(element);
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
 void setSelectedRestaurant(Restaurant restaurant) {
    selectedRestaurant = restaurant;
  }

  String? getSelectedRestaurantName() {
    return selectedRestaurant?.name;
  }
    String? getSelectedRestaurantAdresse() {
    return selectedRestaurant?.address;
  }
    void setUserAddress(String address) {
    userAddress = address;
  }

  String? getUserAddress() {
    return userAddress;
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

}

class Article {
  // ignore: non_constant_identifier_names
  int id_item;
  String nom;
  String img;
  int prix;
  int quantite;
List<String> elementsChoisis;
  Article({
    // ignore: non_constant_identifier_names
    required this.id_item,
    required this.nom,
    required this.img,
    required this.prix,
    required this.quantite,
    required this.elementsChoisis, 
  });
}
