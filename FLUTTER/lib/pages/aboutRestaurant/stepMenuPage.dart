import 'package:flutter/material.dart';
import 'acceuil.dart';
import 'CategoryPage.dart';
import './../global.dart';

class StepMenuPage extends StatefulWidget {
  final int id_item;
  final String img;
  final String nom;
  final int prix;
  final Restaurant restaurant;
  final String selectedRetraitMode;


  const StepMenuPage({
    Key? key,
    required this.id_item,
    required this.nom,
    required this.img,
    required this.prix,
    required this.restaurant,
    required this.selectedRetraitMode,

  }) : super(key: key);

  @override
  _StepMenuPageState createState() => _StepMenuPageState();
}

class _StepMenuPageState extends State<StepMenuPage> {
  int _value = 1;
  late TimeOfDay selectedTime;
  final TextEditingController _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = _value * widget.prix;
    int id_item = widget.id_item;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nom),
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              widget.img,
              width: 300,
              height: 250,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Remarque: ",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 300,
                      height: 100,
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: _remarkController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Entrez une remarque',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _value = _value > 1 ? _value - 1 : 1;
                    });
                  },
                  icon: const Icon(Icons.remove),
                  iconSize: 30,
                ),
                Text(
                  '$_value',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _value++;
                    });
                  },
                  icon: const Icon(Icons.add),
                  iconSize: 30,
                ),
              ],
            ),
            SizedBox(
              width: 1000,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Création de l'objet article
                  Article article = Article(
                    id_item: widget.id_item,
                    nom: widget.nom,
                    img: widget.img,
                    prix: widget.prix,
                    restaurant: widget.restaurant,
                    quantite: _value,
                  );

                  // Ajout de l'article au panier
                  Panier().ajouterAuPanier1(article);

                  // Navigation vers la page suivante
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NextPage(
                        selectedRetraitMode: widget.selectedRetraitMode,
                        restaurant: widget.restaurant,
                      
                        nom: widget.nom,
                        panier: Panier().articles,
                      ),
                      settings: RouteSettings(
                        arguments: {'article': article},
                      ),
                    ),
                  ).then((result) {
                    if (result != null) {
                      setState(() {
                        article.quantite = result['numberOfItems'];
                        article.prix = result['totalPrice'];
                      });
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ajouter $_value article${_value != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ' $totalPrice £',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
