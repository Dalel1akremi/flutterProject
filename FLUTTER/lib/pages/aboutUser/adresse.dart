import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddressSearchScreen extends StatefulWidget {
  final String userId;

  const AddressSearchScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddressSearchScreenState createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  late TextEditingController countryController;
  late TextEditingController cityController;
  late TextEditingController streetController;
  late TextEditingController streetNumberController;

  late bool hasAddress;
  late String country;
  late String city;
  late String street;
  late String streetNumber;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    countryController = TextEditingController();
    cityController = TextEditingController();
    streetController = TextEditingController();
    streetNumberController = TextEditingController();
      hasAddress = false;
   
    fetchAddressDetails();
  }

  Future<void> fetchAddressDetails() async {

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getGeocodedDetails?_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        
        final data = jsonDecode(response.body);
        setState(() {
          hasAddress = true;
          country = data['geocodedDetails']['country'];
          city = data['geocodedDetails']['city'];
          street = data['geocodedDetails']['street'];
          streetNumber = data['geocodedDetails']['streetNumber'];
        });
      } else {
       
        setState(() {
          hasAddress = false;
        });
      }
    } catch (error) {
      print('Error fetching address details: $error');
      // Handle error
    }
  }

  Future<void> searchAddress() async {
   
    if (hasAddress) {
      print('User already has an address: $country, $city, $street, $streetNumber');
      return;
    }

    String apiUrl = 'http://localhost:3000/searchAddress?_id=${widget.userId}';

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
        // After successfully searching the address, fetch the updated details
        await fetchAddressDetails();
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

Future<void> _showEditDialog() async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Modifier l\'adresse'),
        content: Column(
          children: [
            TextField(
              controller: countryController,
              decoration: InputDecoration(labelText: 'Country'),
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: streetController,
              decoration: InputDecoration(labelText: 'Street'),
            ),
            TextField(
              controller: streetNumberController,
              decoration: InputDecoration(labelText: 'Street Number'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              // Mettez à jour les détails géocodés avec les nouvelles informations
              await updateGeocodedDetails();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<void> updateGeocodedDetails() async {
  // Mettez à jour les détails géocodés en utilisant l'API appropriée
  // Utilisez les valeurs des controllers ou d'autres variables pour les nouvelles informations
  // Vous pouvez utiliser la même approche que dans la méthode searchAddress
  try {
    final response = await http.put(
      Uri.parse('http://localhost:3000/updateGeocodedDetails?_id=${widget.userId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'country': countryController.text,
        'city': cityController.text,
        'street': streetController.text,
        'streetNumber': streetNumberController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Mettez à jour l'interface utilisateur avec les nouvelles informations
      await fetchAddressDetails();
    } else {
      print('Failed to update data. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error updating address details: $error');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Address '),
         backgroundColor: const Color.fromARGB(222, 212, 133, 14),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hasAddress
            ? _buildAddressDetails()
            : _buildAddressInputFields(),
      ),
    );
  }

  Widget _buildAddressDetails() {
  return Column(
    children: [
      Row(
  children: [
    Icon(Icons.location_on, size: 24), // Utilisez Icons.location_on pour une icône de lieu
    SizedBox(width: 8),
    Expanded(
      child: Text(
        'Adresse: $country, $city, $street, $streetNumber',
        style: TextStyle(fontSize: 18),
      ),
    ),
    IconButton(
      icon: Icon(Icons.edit), 
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
          decoration: InputDecoration(labelText: 'Country'),
        ),
        TextField(
          controller: cityController,
          decoration: InputDecoration(labelText: 'City'),
        ),
        TextField(
          controller: streetController,
          decoration: InputDecoration(labelText: 'Street'),
        ),
        TextField(
          controller: streetNumberController,
          decoration: InputDecoration(labelText: 'Street Number'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: searchAddress,
          child: Text('Enregistrer l\'adresse'),
        ),
      ],
    );
  }
}