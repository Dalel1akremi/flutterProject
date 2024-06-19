// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "./RestaurantDetail.dart";
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
    String myIp = Global.myIp;
    return Restaurant(
      id: json['id_rest'],
      logo: 'http://$myIp:3000/' + json['logo'],
      image: 'http://$myIp:3000/' + json['image'],
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
  String iconPath = '';

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    String myIp = Global.myIp;
    final response =
        await http.get(Uri.parse('http://$myIp:3000/getRestaurant'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(response.body)['restaurants'];
      setState(() {
        restaurants =
            responseData.map((json) => Restaurant.fromJson(json)).toList();
        filterRestaurants();
      });
    } else {
      throw Exception('Échec du chargement des restaurants');
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
      body: SingleChildScrollView(
        child: Column(
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
            filteredRestaurants.isNotEmpty
                ? SizedBox(
                    height: MediaQuery.of(context).size.height - 150,
                    child: ListView.builder(
                      itemCount: filteredRestaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = filteredRestaurants[index];
                        return GestureDetector(
                          onTap: () {
                            Panier().setSelectedRestaurant(restaurant);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RestaurantDetail(),
                              ),
                            );
                          },
                          child: Card(
                            surfaceTintColor: const Color.fromARGB(255, 241, 157, 30).withOpacity(0.4),
                            margin: const EdgeInsets.all(8.0),
                            color: const Color.fromARGB(255, 253, 246, 238),
                            child: ListTile(
                              leading: SizedBox(
                                width: 70,
                                height: 60,
                                child: Image.network(
                                  restaurant.logo,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              title: Text(
                                restaurant.nom,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(restaurant.adresse),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ...restaurant.modeDeRetrait.map((mode) {
                                          switch (mode) {
                                            case 'En Livraison':
                                              iconPath = 'images/delivery.svg';
                                              break;
                                            case 'A Emporter':
                                              iconPath = 'images/emporter.svg';
                                              break;
                                            case 'Sur place':
                                              iconPath = 'images/surplace.svg';
                                              break;
                                            default:
                                              iconPath = 'images/no-pictures.svg';
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color.fromARGB(222, 212, 133, 14),
                                              ),
                                              padding: const EdgeInsets.all(8.0),
                                              child: iconPath.endsWith('.svg')
                                                  ? SvgPicture.asset(
                                                      iconPath,
                                                      color: Colors.white,
                                                      width: 20,
                                                      height: 20,
                                                    )
                                                  : Image.asset(
                                                      iconPath,
                                                      color: Colors.white,
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                            ),
                                          );
                                        }),
                                        ...restaurant.modeDePaiement.map((mode) {
                                          switch (mode) {
                                            case 'Espèces':
                                              iconPath = 'images/euro.svg';
                                              break;
                                            case 'Carte bancaire':
                                              iconPath = 'images/cb.svg';
                                              break;
                                            case 'Tickets Restaurant':
                                              iconPath = 'images/ticket.png';
                                              break;
                                            default:
                                              iconPath = 'images/no-pictures.svg';
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color.fromARGB(181, 123, 106, 106),
                                              ),
                                              padding: const EdgeInsets.all(8.0),
                                              child: iconPath.endsWith('.svg')
                                                  ? SvgPicture.asset(
                                                      iconPath,
                                                      color: Colors.white,
                                                      width: 20,
                                                      height: 20,
                                                    )
                                                  : Image.asset(
                                                      iconPath,
                                                    
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Text('Aucun restaurant trouvé pour cette adresse.'),
                  ),
          ],
        ),
      ),
    );
  }
}
