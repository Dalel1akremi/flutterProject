import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'aboutRestaurant/acceuil.dart';

class Panier extends Iterable<Article> {
  List<Article> articles = [];
  static final Panier _instance = Panier._internal();
  factory Panier() => _instance;
 @override
  Iterator<Article> get iterator => articles.iterator;
  Panier._internal();
  List<String> elementsChoisis = [];

  TimeOfDay? selectedTime;
  String? selectedRetraitMode;
  Restaurant? selectedRestaurant;
  String? userAddress;
  String? origin;
  String? origine;
  void viderPanier() {
    articles.clear();
  }
  Article operator [](int index) {
    return articles[index];
  }

  void getOrigin() {}
  void getOrigine(){}

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

  int? getIdRestaurant() {
    return selectedRestaurant?.id;
  }

  String? getSelectedRestaurantLogo() {
    return selectedRestaurant?.logo;
  }
String? getSelectedRestaurantImage() {
    return selectedRestaurant?.image;
  }
  String? getSelectedRestaurantName() {
    return selectedRestaurant?.nom;
  }

  String? getSelectedRestaurantAdresse() {
    return selectedRestaurant?.adresse;
  }

  String? getSelectedRestaurantMode() {
    return selectedRestaurant?.modeDeRetrait.join(', ') ?? '';
  }


String? getSelectedRestaurantPaiement() {
  return selectedRestaurant?.modeDePaiement.join(', ') ?? '';
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
  List<String> elementsChoisis;
   String remarque;
  // ignore: non_constant_identifier_names
  final List<dynamic> id_Steps;
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
    required this.remarque,
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
class Global {
  // ignore: constant_identifier_names
  static const String myIp = "192.168.2.21";
}