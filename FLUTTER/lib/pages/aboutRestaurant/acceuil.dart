// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './commande.dart';
import '../aboutUser/login.dart'; 
import 'RestaurantDetail.dart';
import '../aboutUser/profile.dart';
import './../aboutUser/auth_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  final authProvider = AuthProvider();
  

  await authProvider.initTokenFromStorage();
  
  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: const AcceuilApp(),
    ),
  );

  final token = authProvider.token;
  
 
  if (token != null) {
    print('Token: $token');
  } else {
    print('Il n\'y a pas de token.');
  }
}

class AcceuilApp extends StatelessWidget {
  const AcceuilApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AcceuilScreen(),
    );
  }
}

class AcceuilScreen extends StatelessWidget {
  const AcceuilScreen({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;
 
   
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text(
          'Liste des restaurants',
          style: TextStyle(fontSize: 20, color: Colors.white),
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
  
          if (index == 0) {
           
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AcceuilScreen()),
            );
          }
          if (index == 1) {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CommandeApp()),
            );
          }
          if (index == 2) {
            if (isLoggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage(
                  email: '', nom: '', userId: '')),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const loginPage()),
              );
            }
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
  final String nom;

  Restaurant(this.name, this.address, this.status, this.nom);
}

class RestaurantList extends StatelessWidget {
  const RestaurantList({Key? key}) : super(key: key); 

  @override
  Widget build(BuildContext context) {
    final List<Restaurant> restaurants = [
      Restaurant("MELTING POT", "43 Avenue du Général de Gaulle 93170 Bagnolet",
          "", ""),
    ];

    return ListView.builder(
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            TextButton(
              onPressed: () {
          
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantDetail(
                      restaurant: restaurants[index],
                      nom: restaurants[index].nom,
                    ),
                  ),
                );
              },
              child: ListTile(
                leading: Image.asset(
                  'images/First.png',
                  width: 100,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  restaurants[index].name,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
                subtitle: Text(restaurants[index].address),
                trailing: Text(restaurants[index].status),
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: 1, 
            ),
          ],
        );
      },
    );
  }
}
