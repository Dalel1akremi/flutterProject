import 'package:demo/pages/aboutRestaurant/CategoryPage.dart';
import 'package:demo/pages/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StepMenuPage extends StatefulWidget {
  final int id_item;
  final String img;
  final String nom;
  final int prix;

  const StepMenuPage({
    Key? key,
    required this.id_item,
    required this.nom,
    required this.img,
    required this.prix,
  }) : super(key: key);

  @override
  _StepMenuPageState createState() => _StepMenuPageState();
}

class _StepMenuPageState extends State<StepMenuPage> {
  int _value = 1;
  bool afficherListe = false;
  String? boissonChoisie; // Variable pour stocker la boisson
  final TextEditingController _remarkController = TextEditingController();
  List<String> stepNames = [];
  List<String> itemNames = [];
  late Map<String, dynamic> responseData;

  @override
  void initState() {
    super.initState();
    fetchStepData();
  }

  Future<void> fetchStepData() async {
    var url =
        Uri.parse('http://localhost:3000/getStep?id_item=${widget.id_item}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      responseData = jsonDecode(response.body)['data'];
      setState(() {
        stepNames = List<String>.from(responseData['stepNames']);
        itemNames = List<String>.from(responseData['itemNames']);
      });
    } else {
      throw Exception('Failed to load data');
    }
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                widget.img,
                width: 300,
                height: 150,
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: stepNames.length,
                itemBuilder: (BuildContext context, index) {
                  return ElevatedButton(
                    onPressed: () {
                      toggleListeVisibility();
                    },
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Row(
                            children: [
                              Text(stepNames[index]),
                              Spacer(),
                              IconButton(
                                icon: afficherListe
                                    ? const Icon(Icons.arrow_drop_up)
                                    : const Icon(Icons.arrow_drop_down),
                                onPressed: () {
                                  setState(() {
                                    afficherListe = !afficherListe;
                                    if (afficherListe) {
                                      // Filter itemNames based on the selected stepName
                                      itemNames = [];
                                      for (var item
                                          in responseData['itemNames']) {
                                        if (item['stepName'] ==
                                            stepNames[index]) {
                                          itemNames.add(
                                              item['itemName'] as String);
                                        }
                                      }
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              if (afficherListe)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: itemNames.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(itemNames[index]),
                      leading: Radio(
                        value: itemNames[index],
                        groupValue: boissonChoisie,
                        onChanged: (String? value) {
                          setState(() {
                            boissonChoisie = value;
                          });
                        },
                      ),
                    );
                  },
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 300,
                        height: 100,
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
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
                    // Create article object
                    Article article = Article(
                      id_item: widget.id_item,
                      nom: widget.nom,
                      img: widget.img,
                      prix: widget.prix,
                      quantite: _value,
                    );

                    // Add article to cart
                    Panier().ajouterAuPanier1(article);

                    // Navigate to next page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NextPage(
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
      ),
    );
  }

  void toggleListeVisibility() {
    setState(() {
      afficherListe = !afficherListe;
    });
  }
}
