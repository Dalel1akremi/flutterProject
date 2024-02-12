// ignore: file_names
import 'package:flutter/material.dart';

class StepDetailsPage extends StatefulWidget {
  final int idItem;
  final String img;
  final String nomItem;
  final int prix;

  const StepDetailsPage({
    Key? key,
    required this.idItem,
    required this.nomItem,
    required this.img,
    required this.prix,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StepDetailsPageState createState() => _StepDetailsPageState();
}

class _StepDetailsPageState extends State<StepDetailsPage> {
  int _value = 0; // State for the value
  final TextEditingController _remarkController = TextEditingController();

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
        title: Text(widget.nomItem),
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
<<<<<<< HEAD
<<<<<<< HEAD
                      _value = _value > 1 ? _value - 1 : 1;
=======
                      _value = _value > 0 ? _value - 1 : 0;
>>>>>>> 6dddd11 (feat:fix `category`,`item` and `step` dart pages)
=======
                      _value = _value > 1 ? _value - 1 : 1;
>>>>>>> 096f5bc (feat:add `stepMenuPage` and fix the `stepDetailsPage`)
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
      Navigator.pop(context);
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green, // Change background color as needed
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Vous avez ajouté $_value article${_value != 1 ? 's' : ''}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'Prix total: $totalPrice',
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