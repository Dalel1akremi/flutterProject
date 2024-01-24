import 'package:flutter/material.dart';
import './pages/aboutRestaurant/acceuil.dart'; // Import the new screen file
import './pages/aboutRestaurant/ReserverTable.dart'; // Import the ReserverTable screen file
import './pages/aboutRestaurant/offers.dart'; // Import the Offers screen file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Define your page titles
  final List<String> pageTitles = ['Discover', 'Reserve Table', 'Offers'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top Half: Image
          Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              width: 1500, // Replace this with your desired width value
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
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });

                // Add logic to navigate based on the selected page index
                switch (index) {
                  case 0:
                    // Navigate to the Discover screen
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                    break;
                  case 1:
                    // Navigate to the ReserverTable screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReserverTableScreen()),
                    );
                    break;
                  case 2:
                    // Navigate to the Offers screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OffersScreen()),
                    );
                    break;
                }
              },
              children: [
                // The existing content of HomeScreen
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Discover',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AcceuilScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Add your ReserverTable screen here
                const ReserverTableScreen(),
                // Add your Offers screen here
                const OffersScreen(),
              ],
            ),
          ),
          // Bottom Half: Three Centered Dots for Navigation
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
