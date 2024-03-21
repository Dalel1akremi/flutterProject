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

    
      this.selectedTime = selectedTime;
  
  }

  String? getSelectedRetraitMode() {
    return selectedRetraitMode;
  }

  void setSelectedRestaurant(Restaurant restaurant) {
    selectedRestaurant = restaurant;
  }

  String? getSelectedRestaurantName() {
    return selectedRestaurant?.nom;
  }

  String? getSelectedRestaurantAdresse() {
    return selectedRestaurant?.adresse;
  }
 String? getSelectedRestaurantMode() {
  return selectedRestaurant?.modeDeRetrait?.join(', ') ?? ''; 
}
List<String>? getSelectedRestaurantRMode() {
  return selectedRestaurant?.modeDeRetrait;
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
// ignore: non_constant_identifier_names
List<String> elementsChoisis;  final List<dynamic> id_Steps;
  Article({

    // ignore: non_constant_identifier_names
    required this.id_item,
    // ignore: non_constant_identifier_names
    required this.id_Steps,

    required this.nom,
    required this.img,
    required this.prix,
    required this.quantite,
    required this.elementsChoisis, 
  });
}
class Step {
  // ignore: non_constant_identifier_names
  final String nom_Step;
  // ignore: non_constant_identifier_names
  final List<String> id_items;

  Step({
    // ignore: non_constant_identifier_names
    required this.nom_Step,
    // ignore: non_constant_identifier_names
    required this.id_items,
  });
}