// ignore: file_names
// ignore_for_file: avoid_print, file_names, duplicate_ignore

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'acceuil.dart';
import './../aboutPaiement/paiement.dart';
import 'ItemDetailsPage.dart';

class NextPage extends StatefulWidget {
  final String selectedRetraitMode;
  final Restaurant restaurant;
  final TimeOfDay selectedTime;

  const NextPage({
    Key? key,
    required this.selectedRetraitMode,
    required this.restaurant,
    required this.selectedTime,
  }) : super(key: key);

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  List<Category> _categories = [];
  int _selectedCategoryIndex = 0;
  String selectedRetraitMode = '';
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/getCategories'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        setState(() {
          _categories = responseData.map((json) => Category.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to fetch categories. Status code: ${response.statusCode}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching categories: $error');
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchMenu(int idCat) async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/getMenu?id_cat=$idCat'));

    if (response.statusCode == 200) {
      final List<dynamic>? responseData = json.decode(response.body)['data'];

      if (responseData != null) {
        return responseData.cast<Map<String, dynamic>>();
      } else {
        if (kDebugMode) {
          print('Error fetching menu: Response data is null');
        }
        return [];
      }
    } else {
      throw Exception('Failed to fetch menu. Status code: ${response.statusCode}');
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error fetching menu: $error');
    }
    return [];
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: Text(widget.restaurant.name),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / _categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: _selectedCategoryIndex == index ? Colors.grey[200] : Colors.white,
                    child: Center(
                      child: Row(
                        children: [
                          Icon(Icons.restaurant_menu,
                              color: _selectedCategoryIndex == index ? Colors.purple : Colors.black),
                          const SizedBox(width: 8),
                          Text(
                            _categories[index].nomCat,
                            style: TextStyle(
                              color: _selectedCategoryIndex == index ? Colors.purple : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Center(
              child: _buildMenuForCategory(_categories.isNotEmpty
                  ? _categories[_selectedCategoryIndex]
                  : Category(idCat: 1, nomCat: '')),
            ),
          ),
          // Ajout du bouton de paiement
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      selectedRetraitMode: selectedRetraitMode,
                      restaurant: widget.restaurant,
                      selectedTime: selectedTime,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueGrey[200],
              ),
              child: const Text(
                'Paiement',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuForCategory(Category category) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchMenu(category.idCat), // Fetch menu for selected category
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading menu: ${snapshot.error}');
        } else {
          return ListView(
            children: snapshot.data!.map<Widget>((menuItem) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailsPage(idMenu: menuItem['id_menu'],nomMenu:menuItem['nom']),
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
                      // Left side: Image
                      Image.network(
                        menuItem['image'],
                        width: 150,
                        height: 100,
                      ),
                      const SizedBox(width: 16),
                      // Right side: Name, Description, and Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${menuItem['nom']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${menuItem['description']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Prix: ${menuItem['prix']}£',
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
            }).toList(),
          );
        }
      },
    );
  }
}

class Category {
  final int idCat;
  final String nomCat;

  Category({
    required this.idCat,
    required this.nomCat,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final int? categoryId = json['id_cat'] as int?;
    final String? categoryNomCat = json['nom_cat'] as String?;
    
    if (categoryId != null && categoryNomCat != null && categoryNomCat.isNotEmpty) {
      return Category(idCat: categoryId, nomCat: categoryNomCat);
    } else {
      print("Warning: 'id_cat' or 'nom_cat' is null or empty in JSON data");
      return Category(idCat: 0, nomCat: 'Default Category');
    }
  }
}
