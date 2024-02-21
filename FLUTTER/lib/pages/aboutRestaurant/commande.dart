import 'package:flutter/material.dart';
import './acceuil.dart';
import '../aboutUser/login.dart';
void main() {
  runApp(const CommandeApp());
}

class CommandeApp extends StatelessWidget {
  const CommandeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CommandeScreen(),
    );
  }
}

class CommandeScreen extends StatelessWidget {
  const CommandeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(222, 212, 133, 14),
          title: const Text(
            'Mes commandes',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        body: Column(
          
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'En cours'),
                Tab(text: 'Passés'),
              ],
              
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Center(
                    child: Text('Content for "En cours" tab'),
                  ),
                  Center(
                    child: Text('Content for "Passés" tab'),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
              ),
            ],
          ),
          child: BottomNavigationBar(
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
                DefaultTabController.of(context)?.animateTo(0);
              }
              if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const loginPage()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
