import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import './commande.dart';
import '../aboutUser/profile.dart';

void main() {
  runApp(const AcceuilApp());
}

class AcceuilApp extends StatelessWidget {
  const AcceuilApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AcceuilScreen(),
    );
  }
}

class AcceuilScreen extends StatelessWidget {
  const AcceuilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Liste des restaurants',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(181, 123, 106, 106),
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Saisissez votre adresse',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (kDebugMode) {
                  print('Search query: $value');
                }
              },
            ),
          ),
          const Expanded(
            child: RestaurantList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
         BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
         BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        onTap: (index) {
          // Handle bottom navigation bar taps
          if (index == 0) {
            // Navigate to the CommandePage when Button 2 is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AcceuilScreen()),
            );
          }
          if (index == 1) {
            // Navigate to the CommandePage when Button 2 is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CommandeApp()),
            );
          }
          if (index == 2) {
            // Navigate to the CommandePage when Button 2 is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }
}

class Restaurant {
  String name;
  String address;
  String status;

  Restaurant(this.name, this.address, this.status);
}

class RestaurantList extends StatefulWidget {
  const RestaurantList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RestaurantListState createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  final List<Restaurant> _restaurants = [
    Restaurant(
        "MELTING POT", "43 Avenue du Général de Gaulle 93170 Bagnolet", ""),
    Restaurant("BURGER WORLD", "33 RUE ERNEST RENAN 69120 VAULX-EN-VELIN", ""),
    Restaurant("ICE CREAM", "24 B RUE LEONARD DE VINCI 91090 LISSES", ""),
    Restaurant("elyes cashpad v2 b1", "123 12345 paris 123 123", ""),
    Restaurant("SAFA STORE", "24 B RUE LEONARD DE VINCI 91090 LISSES", ""),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_restaurants[index].name),
          subtitle: Text(_restaurants[index].address),
          trailing: Text(_restaurants[index].status),
        );
      },
    );
  }
}