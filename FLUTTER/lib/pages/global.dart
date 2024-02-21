import 'aboutRestaurant/acceuil.dart';

class Panier {
  static final Panier _instance = Panier._internal();
  factory Panier() => _instance;

  Panier._internal();
  

  List<Article> articles = [];
 

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
  void printPanier() {
    print('Contenu du panier:');
    for (var article in articles) {
      print('Nom: ${article.nom}, Prix: ${article.prix}, Quantité: ${article.quantite}');
    }
  }
}

class Article {
  int id_item;
  String nom;
  String img;
  int prix;
  Restaurant restaurant;

  int quantite;

  Article({
    required this.id_item,
    required this.nom,
    required this.img,
    required this.prix,
    required this.restaurant,
    required this.quantite,
  });
}

