// Import necessary packages
import 'package:flutter/material.dart';
import 'offers.dart';
import 'acceuil.dart';

class ReserverTableScreen extends StatefulWidget {
  const ReserverTableScreen({Key? key}) : super(key: key);

  @override
  _ReserverTableScreenState createState() => _ReserverTableScreenState();
}

class _ReserverTableScreenState extends State<ReserverTableScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 1; // Set the initial page index to 1

  // Define your page titles
  final List<String> pageTitles = ['Discover', 'Reserve Table', 'Offers'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your special offers-related widgets or content here
            // For example:
            Container(
              padding: const EdgeInsets.all(16),  // Adjust the padding as needed
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Add an Image
                  Image.asset(
                    'images/Second.jpg', // Replace with the actual image path
                    width: 500, // Adjust the width as needed
                    height: 428, // Adjust the height as needed
                  ),
                  const SizedBox(height: 20),
                  // Add Text
                  const Text(
                    'Reserver une table',
                    style: TextStyle(fontSize: 30),
                  ),
                  const Text(
                    'Reserver ou modifier une reservation n importe quand et n importe où ',
                    style: TextStyle(fontSize: 18),
                  
                  ),
                  const SizedBox(height: 10),
                  // Add a Button
                  ElevatedButton(
                    onPressed: () {
                      
                      // Add your button click logic here
                    },
                    style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                    child: const Text(('Commencer'),style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
