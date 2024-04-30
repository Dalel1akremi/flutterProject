// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';
import 'package:demo/pages/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'stepDetailsPage.dart';
class ItemDetailsPage extends StatelessWidget {
  final int id_item;
  final String img;
  final String nom;
  final int prix;
  final int id_rest;
  final List<dynamic> id_Steps;

  const ItemDetailsPage({
    super.key, 
    required this.id_item,
    required this.nom,
    required this.img,
    required this.prix,
    required this.id_Steps,
    required this.id_rest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: Text(nom),
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchItemDetails(id_item, id_rest),
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

  Future<List<Map<String, dynamic>>> fetchItemDetails(int id_item, int id_rest) async {
    try {
      final int? idRest = Panier().getIdRestaurant();
      if (idRest == null) {
        throw Exception('Restaurant ID is null');
      }
      String myIp = Global.myIp;
      final response = await http.get(
        Uri.parse('http://$myIp:3000/getRedirect?id_item=$id_item&id_rest=$idRest'),
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
        throw Exception('Failed to fetch menu. Status code: ${response.statusCode}');
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
              id_Steps: item['id_Steps'] ?? [],
              id_item: item['id_item'] ?? 0,
              nom: item['nom'] ?? '',
              img: item['image'] ?? '',
              prix: (item['prix'] ?? 0).toInt(),
            ),
          ),
        );
      },
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(181, 237, 231, 231),
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
                      'Prix: ${item['prix'] ?? ''}€',
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
      ),
    );
  }
}
