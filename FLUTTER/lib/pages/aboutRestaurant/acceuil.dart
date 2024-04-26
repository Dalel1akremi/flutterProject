// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './../aboutRestaurant/commande.dart';
import './../aboutUser/login.dart';
import "./RestaurantDetail.dart";
import '../aboutUser/profile.dart';
import './../aboutUser/auth_provider.dart';
import './../global.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();

  await authProvider.initTokenFromStorage();

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: const MyApp(),
    ),
  );

  final token = authProvider.token;

  if (token != null) {
    if (kDebugMode) {
      print('Token: $token');
    }
  } else {
    if (kDebugMode) {
      print('Il n\'y a pas de token.');
    }
  }
}

class Restaurant {
  final int id;
  final String logo;
  final String nom;
  final String adresse;
  final List<String> modeDeRetrait;
  final List<String> modeDePaiement;
  final String image;
  Restaurant({
    required this.id,
    required this.logo,
    required this.image,
    required this.nom,
    required this.adresse,
    required this.modeDeRetrait,
    required this.modeDePaiement,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id_rest'],
      logo: json['logo'],
      image: json['image'],
      nom: json['nom'],
      adresse: json['adresse'],
      modeDeRetrait: List<String>.from(json['ModeDeRetrait']),
      modeDePaiement: List<String>.from(json['ModeDePaiement']),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AcceuilScreen(),
    );
  }
}

class AcceuilScreen extends StatefulWidget {
  const AcceuilScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RestaurantListState createState() => _RestaurantListState();

  void initState() {
    _printStorageContent();
  }

  Future<void> _printStorageContent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print('Token: ${prefs.getString('token')}');
    }
    if (kDebugMode) {
      print('UserId: ${prefs.getString('userId')}');
    }
    if (kDebugMode) {
      print('Nom: ${prefs.getString('nom')}');
    }
    if (kDebugMode) {
      print('Email: ${prefs.getString('email')}');
    }
    if (kDebugMode) {
      print('Telephone: ${prefs.getString('telephone')}');
    }
  }
}

class _RestaurantListState extends State<AcceuilScreen> {
  late List<Restaurant> restaurants = [];
  late List<Restaurant> filteredRestaurants = [];
  late String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    final response =
        await http.get(Uri.parse('http://192.168.2.61:3000/getRestaurant'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(response.body)['restaurants'];
      setState(() {
        restaurants =
            responseData.map((json) => Restaurant.fromJson(json)).toList();
        filterRestaurants();
      });
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  void filterRestaurants() {
    setState(() {
      filteredRestaurants = restaurants
          .where((restaurant) => restaurant.adresse
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.initTokenFromStorage();

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
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              color: const Color.fromARGB(181, 123, 106, 106),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'Saisissez votre adresse',
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      filterRestaurants();
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: filteredRestaurants.isNotEmpty
             ?ListView.builder(
  itemCount: filteredRestaurants.length * 2 - 1,
  itemBuilder: (context, index) {
    if (index.isEven) {
      final restaurantIndex = index ~/ 2;
      final restaurant = filteredRestaurants[restaurantIndex];
      return Container(
        width: MediaQuery.of(context).size.width * 0.08,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 248, 240, 240),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 248, 240, 240).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            Panier().setSelectedRestaurant(restaurant);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RestaurantDetail(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0), // Ajoutez cet espacement vertical
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              leading: SizedBox(
                width: 70,
                height: 60,
                child: Image.network(
                  restaurant.logo,
                  fit: BoxFit.cover,
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(restaurant.adresse),
                  const SizedBox(height: 32),
                ],
              ),
              subtitle: Row(
                children: [
                  ...restaurant.modeDeRetrait.map((mode) {
                    IconData iconData;
                    Color iconColor;
                    switch (mode) {
                      case 'En Livraison':
                        iconData = Icons.delivery_dining;
                        iconColor = Colors.blue;
                        break;
                      case 'A Emporter':
                        iconData = Icons.takeout_dining;
                        iconColor = Colors.green;
                        break;
                      case 'Sur place':
                        iconData = Icons.restaurant;
                        iconColor = Colors.orange;
                        break;
                      default:
                        iconData = Icons.error;
                        iconColor = Colors.black;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconColor,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          iconData,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }),
                  ...restaurant.modeDePaiement.map((mode) {
                    IconData? iconData;
                    switch (mode) {
                      case 'Espèces':
                        iconData = Icons.monetization_on;
                        break;
                      case 'Carte bancaire':
                        iconData = Icons.credit_card;
                        break;
                      case 'Tickets Restaurant':
                        iconData = Icons.book;
                        break;
                      default:
                        iconData = null;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueGrey,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          iconData ?? Icons.error,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 14.0, 
      );
    }
  },
)
  
                : const Center(
                    child: Text('Aucun restaurant trouvé pour cette adresse.'),
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
            Future<void> onPressed() async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? token = prefs.getString('token');
              if (token != null && token.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilPage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const loginPage()),
                );
              }
            }

            onPressed();
          }
        },
      ),
    );
  }
}
