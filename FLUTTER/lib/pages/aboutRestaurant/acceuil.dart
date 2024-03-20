import 'dart:convert';
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
    print('Token: $token');
  } else {
    print('Il n\'y a pas de token.');
  }
}

class Restaurant {
  final String id;
  final String logo;
  final String nom;
  final String adresse;
  final List<String> modeDeRetrait;

  Restaurant({
    required this.id,
    required this.logo,
    required this.nom,
    required this.adresse,
    required this.modeDeRetrait,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'],
      logo: json['logo'],
      nom: json['nom'],
      adresse: json['adresse'],
      modeDeRetrait: List<String>.from(json['ModeDeRetrait']),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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
  const AcceuilScreen({Key? key});

  @override
  _RestaurantListState createState() => _RestaurantListState();
}

class _RestaurantListState extends State<AcceuilScreen> {
  late List<Restaurant> restaurants = []; // Initialisation de la liste

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/getRestaurant'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(response.body)['restaurants'];
      setState(() {
        restaurants =
            responseData.map((json) => Restaurant.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load restaurants');
    }
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
            child: TextField(
              decoration: const InputDecoration(
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
  child: restaurants.isNotEmpty
      ? ListView.builder(
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Panier().setSelectedRestaurant(restaurants[index]);
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      leading: SizedBox(
                        width: 250,
                        height: 250,
                        child: Image.network(
                          restaurants[index].logo,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            restaurants[index].nom,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                            ),
                          ),
                          Text(restaurants[index].adresse),
                        ],
                      ),
                      subtitle: Row(
                        children: restaurants[index].modeDeRetrait
                            .map((mode) {
                          IconData iconData;
                          switch (mode) {
                            case ' Livraison':
                              iconData = Icons.delivery_dining;
                              break;
                            case 'emporte':
                              iconData = Icons.takeout_dining;
                              break;
                            case ' sur place':
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
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
              ],
            );
          },
        )
      : const Center(
          child: CircularProgressIndicator(),
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
