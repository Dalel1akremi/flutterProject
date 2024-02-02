import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'acceuil.dart';
import './../aboutPaiement/paiement.dart';
import './RestaurantDetail.dart';

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
 TimeOfDay selectedTime = TimeOfDay.now(); 
  String selectedRetraitMode = '';
  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/getCategories'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        setState(() {
          _categories =
              responseData.map((json) => Category.fromJson(json)).toList();
        });
      } else {
        throw Exception(
            'Failed to fetch categories. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  Widget _buildMenuForCategory(Category category) {
    if (_categories.isNotEmpty &&
        _selectedCategoryIndex >= 0 &&
        _selectedCategoryIndex < _categories.length) {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchMenu(category.nomCat),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error loading menu: ${snapshot.error}');
          } else {
            return Column(
              children: snapshot.data!.map((menuItem) {
                return GestureDetector(
                  onTap: () {
                    // Handle link press, e.g., navigate to a details page
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Item Name: ${menuItem['nom']}'),
                        Text('Description: ${menuItem['description']}'),
                        Text('Image: ${menuItem['image']}'),
                        Text('Price: ${menuItem['prix']}'),
                        // Add more Text widgets for additional information
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      );
    } else {
      return const Center(
        child: Text('No categories available or invalid index.'),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchMenu(String nomCat) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getMenu?nom_cat=$nomCat'),
      );

      if (response.statusCode == 200) {
        final List<dynamic>? responseData = json.decode(response.body)['data'];

        if (responseData != null) {
          return responseData.cast<Map<String, dynamic>>();
        } else {
          print('Error fetching menu: Response data is null');
          return [];
        }
      } else {
        throw Exception(
            'Failed to fetch menu. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching menu: $error');
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
                    width:
                        MediaQuery.of(context).size.width / _categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: _selectedCategoryIndex == index
                        ? Colors.grey[200]
                        : Colors.white,
                    child: Center(
                      child: Row(
                        children: [
                          Icon(Icons.restaurant_menu,
                              color: _selectedCategoryIndex == index
                                  ? Colors.purple
                                  : Colors.black),
                          const SizedBox(width: 8),
                          Text(
                            _categories[index].nomCat,
                            style: TextStyle(
                              color: _selectedCategoryIndex == index
                                  ? Colors.purple
                                  : Colors.black,
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
                  : Category(nomCat: '')),
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
                  'paiement',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ),
        ],
      ),
    );
  }
}

class Category {
  final String nomCat;

  Category({required this.nomCat});

  factory Category.fromJson(Map<String, dynamic> json) {
    final String? categoryNomCat = json['nom_cat'] as String?;
    if (categoryNomCat != null && categoryNomCat.isNotEmpty) {
      return Category(nomCat: categoryNomCat);
    } else {
      print("Warning: 'nom_cat' is null or empty in JSON data");
      return Category(nomCat: 'Default Category');
    }
  }
}
