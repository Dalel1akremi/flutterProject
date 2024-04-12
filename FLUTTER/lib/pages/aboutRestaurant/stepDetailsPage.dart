// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore

import 'package:flutter/material.dart';
import 'CategoryPage.dart';
import './../global.dart';

class StepDetailsPage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int id_item;
  final String img;
  final int prix;
  final String nom;
  
  // ignore: non_constant_identifier_names
  final List<dynamic> id_Steps;

  const StepDetailsPage({
    Key? key,
    // ignore: non_constant_identifier_names
    required this.id_item,
    required this.img,
    required this.prix,
    required this.nom,
    // ignore: non_constant_identifier_names
    required this.id_Steps,
   
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StepDetailsPageState createState() => _StepDetailsPageState();
}

class _StepDetailsPageState extends State<StepDetailsPage> {
  int _value = 1; // State for the value
  late TimeOfDay selectedTime;
  String selectedRetraitMode = '';
  final TextEditingController _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = _value * widget.prix;

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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Article article = Article(
                    id_item: widget.id_item,
                    nom: widget.nom,
                    img: widget.img,
                    prix: widget.prix,
                    id_Steps: [
                      widget.id_Steps
                    ],
                    quantite: _value,
                    elementsChoisis: [],
                 remarque: _remarkController.text,
                  );
                 
   
                  Panier().ajouterAuPanier1(article);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NextPage(
                        panier: Panier().articles,
                      ),
                      settings: RouteSettings(
                        arguments: {article},
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
                  minimumSize: const Size(150, 50),
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
