import 'package:flutter/material.dart';
import 'commande.dart';
import 'profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(222, 212, 133, 14),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
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
            color: Color.fromARGB(181, 123, 106, 106),
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Saisissez votre adresse',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                print('Search query: $value');
              },
            ),
          ),
          Expanded(
            child: RestaurantList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Button 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Button 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Button 3',
          ),
        ],
        onTap: (index) {
          // Handle bottom navigation bar taps
          if (index == 0) {
            // Navigate to the CommandePage when Button 2 is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
          if (index == 1) {
            // Navigate to the CommandePage when Button 2 is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CommandeApp()),
            );
          }
          if (index == 2) {
            // Navigate to the CommandePage when Button 2 is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
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
  @override
  _RestaurantListState createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  List<Restaurant> _restaurants = [
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