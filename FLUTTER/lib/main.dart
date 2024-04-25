import 'package:demo/pages/aboutRestaurant/commandeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './pages/aboutUser/auth_provider.dart';
import './pages/aboutRestaurant/acceuil.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
     apiKey: "AIzaSyBB0RXK1lHpKPfmD_a-L3OtaOzJBpG1SbY",
  authDomain: "speedy-cedar-413809.firebaseapp.com",
  projectId: "speedy-cedar-413809",
  storageBucket: "speedy-cedar-413809.appspot.com",
  messagingSenderId: "800045568375",
  appId: "1:800045568375:web:db95405a19d6d393f55172",

    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
         ChangeNotifierProvider(create: (_) => AuthProvider()), 
         ChangeNotifierProvider(create: (_) => CommandesModel()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AppStart(),
      ),
    );
  }
}

class AppStart extends StatelessWidget {
  const AppStart({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/acceuil.jpeg'),
                fit: BoxFit.cover,
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AcceuilScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.07), 
                ),
                child: const Text(
                  'Commencer',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
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