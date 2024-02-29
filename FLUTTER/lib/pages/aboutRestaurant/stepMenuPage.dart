import 'package:flutter/material.dart';

class StepMenuPage extends StatefulWidget {
  final int id_item;
  final String img;
  final String nom;
  final int prix;
  final List<dynamic> id_Steps;

  const StepMenuPage({
    Key? key,
    required this.id_item,
    required this.nom,
    required this.img,
    required this.prix,
    required this.id_Steps,
  }) : super(key: key);

  @override
  _StepMenuPageState createState() => _StepMenuPageState();
}

class _StepMenuPageState extends State<StepMenuPage> {
  int _value = 1;
  Map<String, bool> afficherListeMap = {};
  String? boissonChoisie;
  final TextEditingController _remarkController = TextEditingController();
  List<String> stepNames = [];
  Map<String, List<String>> itemNamesMap = {};
  late Map<String, dynamic> responseData = {};

  @override
  void initState() {
    super.initState();
    extractStepNames();

  }

  void extractStepNames() {
    List<String> extractedNames = [];
    for (var step in widget.id_Steps) {
      if (step['nom_Step'] != null) {
        extractedNames.add(step['nom_Step'] as String);
        afficherListeMap[step['nom_Step'] as String] = false;
      }
    }
    setState(() {
      stepNames = extractedNames;
    });
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
                  return Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          toggleListeVisibility(stepNames[index]);
                        },
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(stepNames[index]),
                              Spacer(),
                              IconButton(
                                icon: afficherListeMap[stepNames[index]] ?? false
                                    ? const Icon(Icons.arrow_drop_up)
                                    : const Icon(Icons.arrow_drop_down),
                                onPressed: () {
                                  toggleListeVisibility(stepNames[index]);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (afficherListeMap[stepNames[index]] ?? false)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: itemNamesMap[stepNames[index]]?.length ?? 0,
                          itemBuilder: (BuildContext context, int itemIndex) {
                            return ListTile(
                              title: Text(itemNamesMap[stepNames[index]]![itemIndex]),
                              leading: Radio(
                                value: itemNamesMap[stepNames[index]]![itemIndex],
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
                    ],
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
                    // Your logic here
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

  void toggleListeVisibility(String stepName) {
    setState(() {
      afficherListeMap[stepName] = !afficherListeMap[stepName]!;
      if (afficherListeMap[stepName]!) {
        // Add logic to populate itemNamesMap based on the selected step
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
