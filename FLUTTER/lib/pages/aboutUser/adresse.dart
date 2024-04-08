// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:demo/pages/aboutUser/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import './../global.dart';

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({Key? key}) : super(key: key);

  @override
  _AddressSearchScreenState createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  late TextEditingController countryController;
  late TextEditingController cityController;
  late TextEditingController streetController;
  late TextEditingController streetNumberController;

  late bool hasAddress;
  String country = '';
  String city = '';
  String street = '';
  String streetNumber = '';
  late String _userId;

  @override
  void initState() {
    super.initState();

    countryController = TextEditingController();
    cityController = TextEditingController();
    streetController = TextEditingController();
    streetNumberController = TextEditingController();
    hasAddress = false;

    _userId = Provider.of<AuthProvider>(context, listen: false).userId!;

    fetchAddressDetails();
  }

  Future<void> fetchAddressDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getGeocodedDetails?_id=$_userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          hasAddress = true;
          country = data['geocodedDetails']['country'] ?? '';
          city = data['geocodedDetails']['city'] ?? '';
          street = data['geocodedDetails']['street'] ?? '';
          streetNumber = data['geocodedDetails']['streetNumber'] ?? '';
          Panier().setUserAddress('$country, $city, $street, $streetNumber');
        });
      } else {
        setState(() {
          hasAddress = false;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching address details: $error');
      }
    }
  }

  Future<void> searchAddress() async {
    if (hasAddress) {
      if (kDebugMode) {
        print(
            'User already has an address: $country, $city, $street, $streetNumber');
      }
      return;
    }

 
    Panier().setUserAddress('$country, $city, $street, $streetNumber');
    String apiUrl = 'http://localhost:3000/searchAddress?_id=$_userId';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'country': countryController.text,
          'city': cityController.text,
          'street': streetController.text,
          'streetNumber': streetNumberController.text,
        }),
      );

      if (response.statusCode == 200) {
        await fetchAddressDetails();
        Panier().setUserAddress('$country, $city, $street, $streetNumber');
      } else {
        if (kDebugMode) {
          print('Failed to fetch data. Status code: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    }
  }

  Future<void> _showEditDialog() async {
    countryController.text = country;
    cityController.text = city;
    streetController.text = street;
    streetNumberController.text = streetNumber;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier l\'adresse'),
          content: Column(
            children: [
              TextField(
                controller: countryController,
                decoration: const InputDecoration(labelText: 'Country'),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: streetController,
                decoration: const InputDecoration(labelText: 'Street'),
              ),
              TextField(
                controller: streetNumberController,
                decoration:
                    const InputDecoration(labelText: 'Street Number'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await updateGeocodedDetails();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateGeocodedDetails() async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://localhost:3000/updateGeocodedDetails?_id=$_userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'country': countryController.text,
          'city': cityController.text,
          'street': streetController.text,
          'streetNumber': streetNumberController.text,
        }),
      );

      if (response.statusCode == 200) {
        await fetchAddressDetails();
        Panier().setUserAddress('$country, $city, $street, $streetNumber');
      } else {
        if (kDebugMode) {
          print('Failed to update data. Status code: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error updating address details: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Addresse '),
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hasAddress ? _buildAddressDetails() : _buildAddressInputFields(),
      ),
    );
  }

  Widget _buildAddressDetails() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Adresse: $country, $city, $street, $streetNumber',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditDialog();
              },
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildAddressInputFields() {
    return Column(
      children: [
        TextField(
          controller: countryController,
          decoration: const InputDecoration(labelText: 'Pays'),
        ),
        TextField(
          controller: cityController,
          decoration: const InputDecoration(labelText: 'Ville'),
        ),
        TextField(
          controller: streetController,
          decoration: const InputDecoration(labelText: 'Rue'),
        ),
        TextField(
          controller: streetNumberController,
          decoration: const InputDecoration(labelText: 'Numéro de Rue'),
        ),
        const SizedBox(height: 20),
         ElevatedButton(
             
                 onPressed: searchAddress,
              
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.black,
              ),
              child: const Text(
             'Enregistrer l\'adresse',
                style: TextStyle(color: Colors.white),
              ),
            ),
      ],
    );
  }
}
