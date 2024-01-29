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
  String selectedRetraitMode = ''; // Variable to store the selected mode

  void _showDeliveryTimeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisissez l\'heure de livraison'),
          content: Column(
            children: [
              // Add your time picker widget here
              // For example:
              TimePickerWidget(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Handle the selected time
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Valider'),
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
                height: MediaQuery.of(context).size.height / 2,
                width: 1500, // Replace this with your desired width value
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
              SizedBox(height: 16),

              // Restaurant Address Container
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adresse:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.restaurant.address),
                  ],
                ),
              ),
              
    SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode de retrait*:',
                      style: TextStyle(fontSize: 18),
                    ),
                    Column(
                      children: [
                        RadioListTile(
                          title: Text('A Emporter'),
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
                          title: Text('Sur  place'),
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
                          title: Text('En Livraison'),
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

              SizedBox(height: 16),

              // Add an ElevatedButton to navigate to the next page
              ElevatedButton(
                onPressed: () {
                  if (selectedRetraitMode.isNotEmpty) {
                    // Navigate to the next page with the selected mode
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NextPage(selectedRetraitMode,widget.restaurant),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Commander dans ce restaurant',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Example TimePickerWidget (customize as needed)
class TimePickerWidget extends StatefulWidget {
  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _selectTime(context),
          child: Text('Choisir l\'heure'),
        ),
        SizedBox(width: 16),
        Text('Heure sélectionnée: ${selectedTime.format(context)}'),
      ],
    );
  }
}
