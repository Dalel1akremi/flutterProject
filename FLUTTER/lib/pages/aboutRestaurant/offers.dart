import 'package:flutter/material.dart';


class OffersScreen extends StatelessWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'images/Third.jpg', 
                    width: 500, 
                    height: 428, 
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Offres spéciales',
                    style: TextStyle(fontSize: 30),
                  ),
                  const Text(
                    'Chercher et prendre les offres spéciales de votre restaurant préféré ',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      
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
