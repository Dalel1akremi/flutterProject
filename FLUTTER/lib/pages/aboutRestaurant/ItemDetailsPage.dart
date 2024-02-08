
// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'stepDetailsPage.dart';

class ItemDetailsPage extends StatelessWidget {
  final String nomMenu;

  const ItemDetailsPage({Key? key, required this.nomMenu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Menu'),
      ),
      body: FutureBuilder<dynamic>(
        future: fetchItemDetails(nomMenu),
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

  Future<dynamic> fetchItemDetails(String nomMenu) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getItem?nom=$nomMenu'),
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
            builder: (context) => StepDetailsPage(nomMenu: item['nom'], img: item['image']),
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
              item['image'],
              width: 150,
              height: 100,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['nom_item']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item['description']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prix: ${item['prix']}£',
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
