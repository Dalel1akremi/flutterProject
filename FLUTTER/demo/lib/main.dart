import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des restaurants'),
      ),
      body: Center(
        child: _buildPage(_currentIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Button 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Button 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Button 3',
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Center(
          child: Text('Button 1 Content'),
        );
      case 1:
        return Center(
          child: Text('Button 2 Content'),
        );
      case 2:
        return _buildLoginPage();
      
      default:
        return Container();
    }
  }

  Widget _buildLoginPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          SizedBox(height: 20),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Perform login/authentication logic here
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
