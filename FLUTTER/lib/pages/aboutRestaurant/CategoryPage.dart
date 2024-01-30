import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'acceuil.dart';

class NextPage extends StatefulWidget {
  final String selectedMode;
  final Restaurant restaurant;

  const NextPage(this.selectedMode, this.restaurant);

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  List<Category> _categories = [];
  int _selectedCategoryIndex = 0;

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
      return Center(
        child: Text('Menu for ${category.nomCat} category'),
      );
    } else {
      return Center(
        child: Text('No categories available or invalid index.'),
      );
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
          Container(
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
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    color: _selectedCategoryIndex == index ? Colors.grey[200]: Colors.white ,
                    child: Center(
                      child: Row(
                        children: [
                          Icon(Icons.restaurant_menu, color: _selectedCategoryIndex == index ? Colors.purple : Colors.black),
                          SizedBox(width: 8),
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
                  : Category(nomCat: '')),
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
    return Category(
      nomCat: json['nom_cat'] as String,
    );
  }
}
