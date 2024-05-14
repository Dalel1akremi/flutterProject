import 'package:demo/pages/aboutRestaurant/RestaurantDetail.dart';
import 'package:demo/pages/aboutRestaurant/RestaurantList.dart';
import 'package:demo/pages/aboutRestaurant/commandeNotifier.dart';
import 'package:demo/pages/aboutUser/login.dart';
import 'package:demo/pages/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './pages/aboutUser/auth_provider.dart';
import './pages/aboutRestaurant/acceuil.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 static const String restaurantDetailRoute = '/RestaurantDetail';
  static const String acceuilScreenRoute = '/AcceuilScreen';
  static const String restaurantListRoute = '/RestaurantScreen';
    static const String connexionRoute = '/connexion';
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CommandesModel()),
      ],
     child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AppStart(),
        initialRoute: '/',
        routes: {
          restaurantListRoute:(context)=> const RestaurantScreen(index: 0,),
          restaurantDetailRoute: (context) => const RestaurantDetail(),
          acceuilScreenRoute: (context) => const AcceuilScreen(),
          connexionRoute:(context) => const loginPage(),
        },
        
      ),
    );
  }
}

class AppStart extends StatelessWidget {
  const AppStart({super.key});

  @override
  Widget build(BuildContext context) {
    return  HomeScreen();
  }
}

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});
  final Panier panier = Panier();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GestureDetector(
           onTap: () {
            panier.origine = "acceuil";
            Navigator.pushReplacementNamed(context, '/RestaurantScreen');
          },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/acceuil.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Découvrir',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Rechercher les restaurants les mieux notés à proximité de votre région',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 30),
             Center(
  child: GestureDetector(
    onTap: () {
    
         panier.origine = "acceuil";
            Navigator.pushReplacementNamed(context, '/RestaurantScreen');      
    },
    child: const Text(
      'Commencer',
      style: TextStyle(
        fontSize: 28,
        color: Colors.white,
      ),
    ),
  ),
),

            ],
          ),
        ],
      ),
    );
  }
}
