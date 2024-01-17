import 'package:flutter/material.dart';
import 'main.dart';
import 'profile.dart';

void main() {
  runApp(CommandeApp());
}

class CommandeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CommandeScreen(),
    );
  }
}

class CommandeScreen extends StatelessWidget {
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
                'Mes commandes',
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle "En cours" button press
                    print('En cours button pressed');
                  },
                  child: Row(
                    children: [
                      SizedBox(width: 16.0),
                      Text(
                        'En cours',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle "Passés" button press
                    print('Passés button pressed');
                  },
                  child: Row(
                    children: [
                      SizedBox(width: 16.0),
                      Text(
                        'Passés',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
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
