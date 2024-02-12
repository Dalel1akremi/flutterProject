import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddressService {
  Future<List<Map<String, dynamic>>> searchAddress({
    required String id,
    required String country,
    required String city,
    required String street,
    required String streetNumber,
  }) async {
    final searchQuery = '$streetNumber $street, $city, $country';

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/searchAddress?q=$searchQuery&format=json&_id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load address');
      }
    } catch (error) {
      throw Exception('Failed to load address');
    }
  }
}

class AddressPage extends StatefulWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final AddressService addressService = AddressService();
  List<Map<String, dynamic>> addresses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adresse'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Recherche de localisation',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) async {
                try {
                  const id = '65c1f9956fa9e01382eb8572';  // Remplacez cette valeur par votre ID utilisateur
                  const country = 'France';  // Remplacez par la saisie utilisateur ou une valeur par défaut
                  const city = 'Paris';  // Remplacez par la saisie utilisateur ou une valeur par défaut
                  const street = 'Champs-Élysées';  // Remplacez par la saisie utilisateur ou une valeur par défaut
                  final streetNumber = value;  // Utilisez la valeur entrée par l'utilisateur

                  final results = await addressService.searchAddress(
                    id: id,
                    country: country,
                    city: city,
                    street: street,
                    streetNumber: streetNumber,
                  );

                  setState(() {
                    addresses = results;
                  });
                } catch (error) {
                  print('Error: $error');
                }
              },
            ),

            // Afficher les résultats de la recherche ici
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(addresses[index]['display_name'] ?? ''),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: AddressPage(),
    ),
  );
}
