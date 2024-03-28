import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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

  Restaurant({
    required this.id,
    required this.logo,
    required this.nom,
    required this.adresse,
    required this.modeDeRetrait,
    required this.modeDePaiement,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id_rest'],
      logo: json['logo'],
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
    final response = await http.get(Uri.parse('http://localhost:3000/getRestaurant'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body)['restaurants'];
      setState(() {
        restaurants = responseData.map((json) => Restaurant.fromJson(json)).toList();
        filterRestaurants(); // Call filter method after fetching restaurants
      });
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  void filterRestaurants() {
    setState(() {
      filteredRestaurants = restaurants.where((restaurant) =>
          restaurant.adresse.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    });
  }

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
       Expanded(
  child: filteredRestaurants.isNotEmpty
    ? ListView.builder(
      itemCount: filteredRestaurants.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Panier().setSelectedRestaurant(filteredRestaurants[index]);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RestaurantDetail(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              leading: SizedBox(
                width: 70,
                height: 60,
                child: Image.network(
                  filteredRestaurants[index].logo,
                  fit: BoxFit.cover,
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filteredRestaurants[index].nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(filteredRestaurants[index].adresse),
                ],
              ),
              subtitle: Row(
                children: [
                  ...filteredRestaurants[index].modeDeRetrait.map((mode) {
                    IconData iconData;
                    switch (mode) {
                      case 'En Livraison':
                        iconData = Icons.delivery_dining;
                        break;
                      case 'A Emporter':
                        iconData = Icons.takeout_dining;
                        break;
                      case 'Sur place':
                        iconData = Icons.restaurant;
                        break;
                      default:
                        iconData = Icons.error;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(iconData),
                    );
                  }).toList(),
                  ...filteredRestaurants[index].modeDePaiement.map((mode) {
                    IconData? iconData;
                    switch (mode) {
                      case 'espece':
                        iconData = Icons.monetization_on;
                        break;
                      case 'carte bancaire':
                        iconData = Icons.credit_card;
                        break;
                      case 'carnet des cheques':
                        iconData = Icons.book;
                        break;
                      default:
                        iconData = null;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(iconData),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
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
            if (isLoggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfilPage()),
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
