import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SalesTermsPage extends StatefulWidget {
  const SalesTermsPage({Key? key}) : super(key: key);

  @override
  _SalesTermsPageState createState() => _SalesTermsPageState();
}

class _SalesTermsPageState extends State<SalesTermsPage> {
  late Future<List<String>> _restaurantNames;

  @override
  void initState() {
    super.initState();
    _restaurantNames = _fetchRestaurantNames();
  }
Future<List<String>> _fetchRestaurantNames() async {
  final response = await http
      .get(Uri.parse('http://localhost:3000/getAllRestaurantNames'));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    print(response.body);
    
    if (data.containsKey('restaurantNames')) {
      List<String> restaurantNames = (data['restaurantNames'] as List)
          .map((item) => item.toString())
          .toList();
      
      if (restaurantNames.isNotEmpty) {
        return restaurantNames;
      } else {
        print('No restaurant names found in the response');
        throw Exception('No restaurant names found in the response');
      }
    } else {
      print('Key "restaurantNames" not found in the response');
      throw Exception('Key "restaurantNames" not found in the response');
    }
  } else {
    print('Error status code: ${response.statusCode}');
    print('Error response body: ${response.body}');
    throw Exception('Failed to load restaurant names');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('CGV'),
      ),
      body: FutureBuilder<List<String>>(
        future: _restaurantNames,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<String> restaurantNames = snapshot.data ?? [];

            return ListView.builder(
              itemCount: restaurantNames.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: Text(restaurantNames[index]),
                  children: <Widget>[
                    ListTile(
                      title: const Text('Email'),
                      subtitle: Text(
                          'email@example.com'), // Remplacez par l'email du restaurant
                    ),
                    ListTile(
                      title: const Text('Adresse'),
                      subtitle: Text(
                          '123 Rue du Restaurant'), // Remplacez par l'adresse du restaurant
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
