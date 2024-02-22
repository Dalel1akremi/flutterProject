import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'stepDetailsPage.dart';
import 'acceuil.dart';

class ItemDetailsPage extends StatelessWidget {
  final int id_item;
  final String img;
  
  final String nom;
  final int prix;
  final Restaurant restaurant;
  final String selectedRetraitMode;

  const ItemDetailsPage({
    Key? key,
    required this.id_item,
    required this.nom,
    required this.img,
    required this.prix,
    required this.restaurant,
    required this.selectedRetraitMode,
 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nom),
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchItemDetails(id_item),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final List<Map<String, dynamic>> items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return buildItemDetails(context, items[index]);
              },
            );
          } else {
            return const Center(
              child: Text('Aucune donnée reçue du serveur.'),
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchItemDetails(int id_item) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getItem?id_item=$id_item'),
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body)['data'];
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic>) {
          return [responseData];
        } else {
          throw Exception('Response data is invalid.');
        }
      } else {
        throw Exception(
            'Failed to fetch menu. Status code: ${response.statusCode}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching menu: $error');
      }
      throw Exception('Failed to fetch menu: $error');
    }
  }

  Widget buildItemDetails(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StepDetailsPage(
              restaurant: restaurant,
              id_item: item['id_item'] ?? 0,
              nom: item['nom'] ?? '',
              img: item['image'] ?? '',
              prix: item['prix'] ?? 0,
              selectedRetraitMode: selectedRetraitMode,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              item['image'] ?? '',
              width: 150,
              height: 100,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nom'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prix: ${item['prix'] ?? ''}£',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
