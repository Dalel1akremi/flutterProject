
// ignore: file_names
import 'package:flutter/material.dart';
import 'acceuil.dart';
import 'CategoryPage.dart';
class RestaurantDetail extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetail({Key? key, required this.restaurant})
      : super(key: key);

  @override
  _RestaurantDetailState createState() => _RestaurantDetailState();
}

class _RestaurantDetailState extends State<RestaurantDetail> {
  String selectedRetraitMode = '';
  late TimeOfDay selectedTime; // Déclarer selectedTime ici

  @override
  void initState() {
    super.initState();
    selectedTime = TimeOfDay.now();
  }

  void _showDeliveryTimeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisissez l\'heure de livraison'),
          content: Container(
            height: 300,
            child: Column(
              children: [
                TimePickerWidget(
                  onTimeSelected: (time) {
                    // Mettre à jour la valeur de selectedTime ici
                    setState(() {
                      selectedTime = time;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Gérer l'heure sélectionnée
                Navigator.of(context).pop();
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: Text(widget.restaurant.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 3.5,
                  width: 1000,
                  child: Container(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('images/First.png'),
                        fit: BoxFit.fitHeight,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 1500,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adresse:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.restaurant.address),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 1500,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mode de retrait*:',
                      style: TextStyle(fontSize: 18),
                    ),
                    Column(
                      children: [
                        RadioListTile(
                          title: const Text('A Emporter'),
                          value: 'Option 1',
                          groupValue: selectedRetraitMode,
                          onChanged: (value) {
                            setState(() {
                              selectedRetraitMode = value.toString();
                              _showDeliveryTimeDialog();
                            });
                          },
                        ),
                        RadioListTile(
                          title: const Text('Sur place'),
                          value: 'Option 2',
                          groupValue: selectedRetraitMode,
                          onChanged: (value) {
                            setState(() {
                              selectedRetraitMode = value.toString();
                              _showDeliveryTimeDialog();
                            });
                          },
                        ),
                        RadioListTile(
                          title: const Text('En Livraison'),
                          value: 'Option 3',
                          groupValue: selectedRetraitMode,
                          onChanged: (value) {
                            setState(() {
                              selectedRetraitMode = value.toString();
                              _showDeliveryTimeDialog();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (selectedRetraitMode.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NextPage(
                          selectedRetraitMode: selectedRetraitMode,
                          restaurant: widget.restaurant,
                          selectedTime: selectedTime,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  'Commander dans ce restaurant',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimePickerWidget extends StatefulWidget {
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerWidget({Key? key, required this.onTimeSelected}) : super(key: key);

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = TimeOfDay.now();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });

      // Appeler la fonction de retour pour informer le parent de la sélection de l'heure
      widget.onTimeSelected(selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _selectTime(context),
          child: const Text('Choisir l\'heure'),
        ),
        const SizedBox(width: 16),
        Text('Heure sélectionnée: ${selectedTime.format(context)}'),
      ],
    );
  }
}

