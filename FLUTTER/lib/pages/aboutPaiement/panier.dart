import 'package:flutter/material.dart';
import './../aboutRestaurant/acceuil.dart';

class PanierPage extends StatefulWidget {
  final int numberOfItems;
  final int totalPrice;
  final String selectedRetraitMode;
  final TimeOfDay selectedTime;
  final Restaurant restaurant;

  const PanierPage({
    Key? key,
    required this.numberOfItems,
    required this.totalPrice,
    required this.selectedRetraitMode,
    required this.selectedTime,
    required this.restaurant,
  }) : super(key: key);

  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  TimeOfDay? _newSelectedTime;

  IconData getModeIcon(String value) {
    switch (value) {
      case 'Option 1':
        return Icons.takeout_dining;
      case 'Option 2':
        return Icons.table_chart;
      case 'Option 3':
        return Icons.delivery_dining;
      default:
        return Icons.shopping_bag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text("Panier"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(getModeIcon(widget.selectedRetraitMode)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Heure de retrait : ${_newSelectedTime != null ? _newSelectedTime!.format(context) : widget.selectedTime.format(context)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showTimePickerDialog();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nombre d\'articles: ${widget.numberOfItems}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Prix total: ${widget.totalPrice} £',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Implement any logic you want when the user proceeds from the cart
                // For example, you could navigate to a payment screen here
                Navigator.pop(context); // Close the cart page and go back
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50),
                backgroundColor: Colors.green, // Change as needed
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ' ${widget.numberOfItems} article${widget.numberOfItems != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Finaliser la commande',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    ' ${widget.totalPrice} £',
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
    );
  }

  Future<void> _showTimePickerDialog() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: widget.selectedTime,
    );

    if (selectedTime != null) {
      setState(() {
        _newSelectedTime = selectedTime;
      });
    }
  }
}
