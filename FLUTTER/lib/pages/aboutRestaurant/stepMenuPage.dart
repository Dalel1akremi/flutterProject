// ignore: file_names
import 'package:flutter/material.dart';
import 'acceuil.dart';
import 'CategoryPage.dart';

class StepMenuPage extends StatefulWidget {
  final int idMenu;
  final String img;
  final String nomMenu;
  final int prix;
  final Restaurant restaurant;
  final String selectedRetraitMode;
  final TimeOfDay selectedTime;

  const StepMenuPage({
    Key? key,
    required this.idMenu,
    required this.nomMenu,
    required this.img,
    required this.prix,
    required this.restaurant,
    required this.selectedRetraitMode,
    required this.selectedTime,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StepMenuPageState createState() => _StepMenuPageState();
}

class _StepMenuPageState extends State<StepMenuPage> {
  int _value = 1;
  String selectedRetraitMode = '';
  late TimeOfDay selectedTime; // State for the value
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
        title: Text(widget.nomMenu),
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
                  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NextPage(
      selectedRetraitMode: selectedRetraitMode,
      restaurant: widget.restaurant,
      selectedTime: selectedTime,
    ),
    settings: RouteSettings(
      arguments: {'numberOfItems': _value, 'totalPrice': totalPrice},
    ),
  ),
).then((result) {
  if (result != null) {
    setState(() {
      _value = result['numberOfItems'];
      totalPrice = result['totalPrice'];
    });
  }
});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green, // Change background color as needed
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ajouter $_value article au panier${_value != 1 ? 's' : ''}',
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
