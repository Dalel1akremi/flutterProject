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
      print('Error fetching categories: $error');
    }
  }

  Widget _buildMenuForCategory(Category category) {
    if (_categories.isNotEmpty && _selectedCategoryIndex >= 0 && _selectedCategoryIndex < _categories.length) {
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
          Expanded(
            child: _buildMenuForCategory(_categories.isNotEmpty ? _categories[_selectedCategoryIndex] : Category(nomCat: '')),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _categories
            .map(
              (category) => BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu),
                label: category.nomCat,
              ),
            )
            .toList(),
        currentIndex: _selectedCategoryIndex,
        onTap: (index) {
          setState(() {
            _selectedCategoryIndex = index;
          });
        },
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
