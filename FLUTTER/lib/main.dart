
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './pages/aboutUser/auth_provider.dart'; // Adjust the import path based on your project structure
import './pages/aboutRestaurant/acceuil.dart';
import './pages/aboutRestaurant/ReserverTable.dart';
import './pages/aboutRestaurant/offers.dart';

void main() async {
  // Clear token on app start
  await clearTokenAndStartApp();
}

Future<void> clearTokenAndStartApp() async {
  // Clear token on app start
  AuthProvider authProvider = AuthProvider(); // Create an instance
  await authProvider.clearTokenFromStorage(); // Call the method
  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider, // Provide the instance of AuthProvider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> pageTitles = ['Discover', 'Reserve Table', 'Offers'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 1.5,
                        width: 1500,
                        child: Container(
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('images/First.png'),
                              fit: BoxFit.fitHeight,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Découvrir',
                        style: TextStyle(fontSize: 30),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Rechercher les restaurants les mieux notés à proximité de votre région',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AcceuilApp()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
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
                ),
                // Afficher le token dans le terminal
                const ReserverTableScreen(),
                const OffersScreen(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageTitles.length,
              (index) => buildDot(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int pageIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentPage == pageIndex ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }
}
