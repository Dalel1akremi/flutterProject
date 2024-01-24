import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import './acceuil.dart';
import '../aboutUser/profile.dart';

void main() {
  runApp(const CommandeApp());
}

class CommandeApp extends StatelessWidget {
  const CommandeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CommandeScreen(),
    );
  }
}

class CommandeScreen extends StatelessWidget {
  const CommandeScreen({super.key});

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
            color: const Color.fromARGB(181, 123, 106, 106),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle "En cours" button press
                    if (kDebugMode) {
                      print('En cours button pressed');
                    }
                  },
                  child: const Row(
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
                    if (kDebugMode) {
                      print('Passés button pressed');
                    }
                  },
                  child: const Row(
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
