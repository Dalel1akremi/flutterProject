// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'stepDetailsPage.dart';
import 'acceuil.dart';

class ItemDetailsPage extends StatelessWidget {
  final int idMenu; // Change type to int
  final String nomMenu;
  final Restaurant restaurant;
  const ItemDetailsPage(
      {Key? key,
      required this.restaurant,
      required this.idMenu,
      required this.nomMenu})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' $nomMenu'),
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
      ),
      body: FutureBuilder<dynamic>(
        future: fetchItemDetails(idMenu),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          } else {
            final dynamic item = snapshot.data!;
            if (item is List) {
              return ListView.builder(
                itemCount: item.length,
                itemBuilder: (context, index) {
                  return buildItemDetails(context, item[index]);
                },
              );
            } else if (item is Map<String, dynamic>) {
              return buildItemDetails(context, item);
            } else {
              return const Center(
                child: Text('Données invalides reçues du serveur.'),
              );
            }
          }
        },
      ),
    );
  }

  Future<dynamic> fetchItemDetails(int idMenu) async {
    // Change parameter type to int
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/getItem?id_menu=$idMenu'), // Convert idMenu to string
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body)['data'];
        return responseData;
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
              idItem: item['id_item'] ?? '',
              nomItem: item['nom_item'] ??
                  '', // Provide default value if id_menu is null
              img: item['image'] ?? '',
              prix:
                  item['prix'] ?? '', // Provide default value if image is null
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
              item['image'] ?? '', // Provide default value if image is null
              width: 150,
              height: 100,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['nom_item'] ?? ''}', // Provide default value if nom_item is null
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item['description'] ?? ''}', // Provide default value if description is null
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prix: ${item['prix'] ?? ''}£', // Provide default value if prix is null
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
