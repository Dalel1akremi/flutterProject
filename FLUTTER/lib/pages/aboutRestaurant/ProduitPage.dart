// ignore_for_file: file_names

import 'package:demo/pages/aboutRestaurant/CategoryPage.dart';
import 'package:demo/pages/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StepMenuPage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int id_item;
  final String img;
  final String nom;
  final int prix;
  final String description;
  // ignore: non_constant_identifier_names
  final List<dynamic> id_Steps;

  const StepMenuPage({
    super.key,
    // ignore: non_constant_identifier_names
    required this.id_item,
    required this.nom,
    required this.img,
    required this.prix,
    required this.description,
    // ignore: non_constant_identifier_names
    required this.id_Steps,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StepMenuPageState createState() => _StepMenuPageState();
}

class _StepMenuPageState extends State<StepMenuPage> {
  int _value = 1;
  Map<String, bool> afficherListeMap = {};
  Map<String, String?> boissonChoisieMap = {};
  final TextEditingController _remarkController = TextEditingController();
  List<String> stepNames = [];
  Map<String, List<String>> itemNamesMap = {};
  late Map<String, dynamic> responseData = {};

  List<String> elementsChoisis = [];

  @override
  void initState() {
    super.initState();
    extractStepData();
  }

  void extractStepData() {
    Map<String, bool> visibilityMap = {};
    Map<String, List<String>> itemNamesMap = {};
    for (var step in widget.id_Steps) {
      if (step['nom_Step'] != null) {
        String stepName = step['nom_Step'] as String;
        bool isObligatoire = step['is_Obligatoire'] ?? false;
        visibilityMap[stepName] = false;
        boissonChoisieMap[stepName] = null;
        itemNamesMap[stepName] = (step['id_items'] as List<dynamic>)
            .map<String>((item) => item['nom_item'] as String)
            .toList();

        if (kDebugMode) {
          print("L'étape $stepName est obligatoire ? $isObligatoire");
        }
      }
    }
    setState(() {
      afficherListeMap = visibilityMap;
      this.itemNamesMap = itemNamesMap;
    });
  }

  bool areAllRequiredElementsSelected() {
    for (var step in widget.id_Steps) {
      if (step['is_Obligatoire'] == true &&
          boissonChoisieMap[step['nom_Step']] == null) {
        return false;
      }
    }
    return true;
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.nom),
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                widget.img,
                width: 300,
                height: 250,
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: afficherListeMap.length,
                itemBuilder: (BuildContext context, index) {
                  String stepName = afficherListeMap.keys.toList()[index];
                  return Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          toggleListeVisibility(stepName);
                        },
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(stepName),
                              const Spacer(),
                              if (widget.id_Steps.any((step) =>
                                  step['nom_Step'] == stepName &&
                                  step['is_Obligatoire'] == true))
                                const Text(
                                  "Obligatoire",
                                  style: TextStyle(color: Colors.red),
                                ),
                              IconButton(
                                icon: afficherListeMap[stepName] ?? false
                                    ? const Icon(Icons.arrow_drop_up)
                                    : const Icon(Icons.arrow_drop_down),
                                onPressed: () {
                                  toggleListeVisibility(stepName);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (afficherListeMap[stepName] ?? false)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: itemNamesMap[stepName]?.length ?? 0,
                          itemBuilder: (BuildContext context, int itemIndex) {
                            return ListTile(
                              title: Text(itemNamesMap[stepName]![itemIndex]),
                              leading: Radio(
                                value: itemNamesMap[stepName]![itemIndex],
                                groupValue: boissonChoisieMap[stepName],
                                onChanged: (String? value) {
                                  setState(() {
                                    boissonChoisieMap[stepName] = value;
                                    elementsChoisis.add(value!);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
              const Divider(),
              const SizedBox(height: 20),
         SingleChildScrollView(
  child: widget.description.isNotEmpty
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                children: [
                  const TextSpan(
                    text: 'Description: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 8, 44, 74),
                    ),
                  ),
                  TextSpan(
                    text: widget.description,
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        )
      : Container(), 
),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: areAllRequiredElementsSelected()
                ? () {
                    Article article = Article(
                      id_item: widget.id_item,
                      nom: widget.nom,
                      img: widget.img,
                      prix: widget.prix,
                      id_Steps: widget.id_Steps,
                      quantite: _value,
                      elementsChoisis: boissonChoisieMap.values
                          .where((element) => element != null)
                          .cast<String>()
                          .toList(),
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
                  }
                : null,
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
                  ' $totalPrice €',
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
      ),
    );
  }

  void toggleListeVisibility(String stepName) {
    setState(() {
      afficherListeMap[stepName] = !(afficherListeMap[stepName] ?? false);
      if (afficherListeMap[stepName]!) {
        itemNamesMap[stepName] = [];
        for (var step in widget.id_Steps) {
          if (step['nom_Step'] == stepName) {
            itemNamesMap[stepName]!.addAll(
              (step['id_items'] as List<dynamic>)
                  .map<String>((item) => ' ${item['nom_item'] as String}'),
            );
          }
        }
      }
    });
  }
}
