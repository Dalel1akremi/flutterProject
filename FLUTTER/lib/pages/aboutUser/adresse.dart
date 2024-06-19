import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './../global.dart';


class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
 String countryError = '';
  String cityError = '';
  String streetError = '';
  String streetNumberError = '';
  String error = '';
  String errorMessage = '';
String successMessage = ''; 
  @override
  void initState() {
    super.initState();

    countryController = TextEditingController();
    cityController = TextEditingController();
    streetController = TextEditingController();
    streetNumberController = TextEditingController();
    hasAddress = false;

    _retrieveUserId();
   
  }

  Future<void> _retrieveUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? '';
    fetchAddressDetails(); 
  }

  Future<void> fetchAddressDetails() async {
    String myIp = Global.myIp;
    try {
      final response = await http.get(
        Uri.parse('http://$myIp:3000/getGeocodedDetails?_id=$_userId'),
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
        print('Erreur lors de la récupération des détails de l\'adresse : $error');
      }
    }
  }

Future<void> searchAddress() async {
  if (hasAddress) {
    if (kDebugMode) {
      print('L\'utilisateur a déjà une adresse : ${countryController.text}, ${cityController.text}, ${streetController.text}, ${streetNumberController.text}');
    }
    return;
  }

  if (countryController.text.isEmpty ||
      cityController.text.isEmpty ||
      streetController.text.isEmpty ||
      streetNumberController.text.isEmpty) {
    setState(() {
      countryError = countryController.text.isEmpty ? 'Le pays est requis.' : '';
      cityError = cityController.text.isEmpty ? 'La ville est requise.' : '';
      streetError = streetController.text.isEmpty ? 'La rue est requise.' : '';
      streetNumberError = streetNumberController.text.isEmpty ? 'Le numéro de rue est requis.' : '';
    });
    return;
  }

  setState(() {
    countryError = '';
    cityError = '';
    streetError = '';
    streetNumberError = '';
    errorMessage = '';
    successMessage = '';
  });

  Panier().setUserAddress('${countryController.text}, ${cityController.text}, ${streetController.text}, ${streetNumberController.text}');
  String myIp = Global.myIp;
  String apiUrl = 'http://$myIp:3000/searchAddress?_id=$_userId';

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
      Panier().setUserAddress('${countryController.text}, ${cityController.text}, ${streetController.text}, ${streetNumberController.text}');
      setState(() {
        successMessage = '';
        errorMessage = 'Adresse non disponible.';
      });
    } else {
      final responseBody = jsonDecode(response.body);
      String errorMessageFromServer = responseBody['message'] ?? 'Échec de la récupération des données.';

      if (kDebugMode) {
        print('Échec de la récupération des données. Code d\'état : ${response.statusCode}, Message: $errorMessageFromServer');
      }

      setState(() {
        errorMessage = errorMessageFromServer;
        successMessage = '';
      });
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
    setState(() {
      errorMessage = 'Erreur lors de la connexion au serveur.';
      successMessage = '';
    });
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
      String myIp = Global.myIp;
      final response = await http.put(
        Uri.parse(
            'http://$myIp:3000/updateGeocodedDetails?_id=$_userId'),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Addresse '),
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
         child: SingleChildScrollView(
        child: hasAddress ? _buildAddressDetails() : _buildAddressInputFields(),
      ),
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
          decoration: InputDecoration(
            labelText: 'Pays',
            errorText: countryError.isNotEmpty ? countryError : null,
          ),
        ),
        TextField(
          controller: cityController,
          decoration: InputDecoration(
            labelText: 'Ville',
            errorText: cityError.isNotEmpty ? cityError : null,
          ),
        ),
        TextField(
          controller: streetController,
          decoration: InputDecoration(
            labelText: 'Rue',
            errorText: streetError.isNotEmpty ? streetError : null,
          ),
        ),
        TextField(
          controller: streetNumberController,
          decoration: InputDecoration(
            labelText: 'Numéro de Rue',
            errorText: streetNumberError.isNotEmpty ? streetNumberError : null,
          ),
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
         const SizedBox(height: 20),
          if (errorMessage.isNotEmpty)
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          if (successMessage.isNotEmpty)
            Text(
              successMessage,
              style: const TextStyle(color: Colors.green),
            ),
      ],
    );
  }}
