// ignore_for_file: file_names, library_private_types_in_public_api
import 'package:demo/pages/aboutRestaurant/acceuil.dart';
import 'package:demo/pages/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './../aboutRestaurant/commande.dart';
import '../aboutUser/profile.dart';
import './../aboutUser/auth_provider.dart';

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
      home: const RestaurantScreen(index: 0),
    );
  }
}

class RestaurantScreen extends StatefulWidget {
  final int index;
  const RestaurantScreen({super.key, required this.index});
  @override
  _RestaurantListState createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantScreen> {
  int _selectedIndex = 0;
  late String _nom = '';
  String _appBarTitle = 'Liste des restaurants';
  Panier panier = Panier();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      AcceuilScreen(),
      CommandeApp(),
      ProfilPage(),
    ];
    initProfilData();
    if (panier.origin == 'acceuil') {
      _selectedIndex = 0;
      _updateAppBarTitle();
    }
    if (panier.origine == 'profil') {
      _selectedIndex = 2;
      _updateAppBarTitle();
    }
     if (panier.origine == 'commandes') {
      _selectedIndex = 1;
      _updateAppBarTitle();
    }
  }

  Future<void> initProfilData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nom = prefs.getString('nom') ?? '';
       _updateAppBarTitle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: Text(
          _appBarTitle,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        leading: _selectedIndex == 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                    _updateAppBarTitle();
                  });
                },
              ),
      ),
      body: _pages[_selectedIndex],
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
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _updateAppBarTitle(); 
            if (_selectedIndex == 2) {
              _checkTokenAndNavigate(context);
            }
          });
        },
      ),
    );
  }

  void _updateAppBarTitle() {
    setState(() {
      if (_selectedIndex == 0) {
        _appBarTitle = 'Liste des restaurants';
      } else if (_selectedIndex == 1) {
        _appBarTitle = 'Mes commandes';
      } else if (_selectedIndex == 2 || panier.origin == 'RestList') {
        _appBarTitle =
            panier.origine == 'RestList' ? 'Bonjour $_nom' : 'Bonjour $_nom';
      } else {
        _appBarTitle = 'Unknown';
      }
    });
  }

  void _checkTokenAndNavigate(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
 final email = prefs.getString('email');
    if (token != null ||email!=null) {
      setState(() {
        _selectedIndex = 2;
      });
    } else {
      panier.origin = 'RestList';
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/connexion');
    }
  }
}
