// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore, prefer_interpolation_to_compose_strings

import 'package:demo/pages/aboutRestaurant/RestaurantDetail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './../aboutPaiement/panier.dart';
import 'RedirectPage.dart';
import 'ProduitPage.dart';
import './../global.dart';

class NextPage extends StatefulWidget {
  final List<Article> panier;

  const NextPage({
    super.key,
    required this.panier,
  });

  @override
  // ignore: library_private_types_in_public_api
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  List<Category> _categories = [];
  int _selectedCategoryIndex = 0;
    String myIp = Global.myIp;
  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final int? idRest = Panier().getIdRestaurant();
      if (idRest == null) {
        throw Exception('L\'identifiant du restaurant est nul');
      }
  
      final response = await http
          .get(Uri.parse('http://$myIp:3000/getCategories?id_rest=$idRest'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        setState(() {
          _categories =
              responseData.map((json) => Category.fromJson(json)).toList();
        });
      } else {
        throw Exception(
            'Échec de la récupération des catégories. Code d\'état: ${response.statusCode}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des catégories: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = 0;
    int numberOfItems = 0;
    for (var article in widget.panier) {
      totalPrice += article.prix * article.quantite;
      numberOfItems += article.quantite;
    }
    String? restaurantName = Panier().getSelectedRestaurantName();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: Text(restaurantName ?? 'Restaurant Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirmation'),
                  content: const Text(
                      'Vous avez des articles dans votre panier. Voulez-vous le vider ?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Non'),
                    ),
                    TextButton(
                      onPressed: () {
                        Panier().viderPanier();
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const RestaurantDetail(),
                          ),
                        );
                      },
                      child: const Text('Oui'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  height: 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        _categories.length,
                        (index) {
                          return Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                },
                                child: Card(
                                  surfaceTintColor: Colors.white,
                                  color: _selectedCategoryIndex == index
                                      ? const Color.fromARGB(255, 253, 242, 226)
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                      color: Color.fromARGB(222, 212, 133,
                                          14),
                                      width: 2,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          _categories[index].imageUrl,
                                          width: 50,
                                          height: 50,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _categories[index].nomCat,
                                          style: TextStyle(
                                            color:
                                                _selectedCategoryIndex == index
                                                    ? Colors.purple
                                                    : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (index != _categories.length - 1)
                                const VerticalDivider(
                                  color: Colors.white,
                                  thickness: 1,
                                  width: 0,
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: _buildMenuForCategory(_categories.isNotEmpty
                  ? _categories[_selectedCategoryIndex]
                  : Category(idCat: 1, nomCat: '', imageUrl: '')),
            ),
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: ElevatedButton(
              onPressed: () {
                if (totalPrice > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PanierPage(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50),
                backgroundColor: Colors.green,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ' $numberOfItems article${numberOfItems != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Paiement',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    ' $totalPrice €',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuForCategory(Category category) {
    return FutureBuilder<List<Map<String?, dynamic>>>(
      future: fetchMenu(category.idCat),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Erreur de chargement du menu : ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Aucun élément de menu disponible.');
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var menuItem = snapshot.data![index];
                return GestureDetector(
                    onTap: () {
                      if (menuItem['is_Redirect'] == true) {
                        final int? idRest = Panier().getIdRestaurant();
                        if (idRest == null) {
                          throw Exception('L\'identifiant du restaurant est nul');
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsPage(
                              id_item: menuItem['id_item'],
                              nom: menuItem['nom'] ?? 'Default Name',
                              img:'http://$myIp:3000/'+menuItem['image'],
                              prix: menuItem['prix'],
                              id_Steps: menuItem['id_Steps'] ?? [],
                              id_rest: menuItem['idRest'] ?? 0,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StepMenuPage(
                              id_item: menuItem['id_item'],
                              nom: menuItem['nom'],
                              img: 'http://$myIp:3000/'+menuItem['image'],
                              prix: menuItem['prix'],
                              description: menuItem['description'],
                              id_Steps: menuItem['id_Steps'] ?? [],
                            ),
                          ),
                        );
                      }
                    },
                    child: Card(
                      surfaceTintColor: Colors.orange.withOpacity(0.4),
                      elevation: 4,
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width:MediaQuery.of(context).size.width,
                              child: Image.network(
                               'http://$myIp:3000/'+menuItem['image'],
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        const SizedBox(height:5),
                          Text(
                            '${menuItem['nom']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            menuItem['description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                           Text(
                              menuItem['is_Redirect']==true?'':
                              'Prix: ${menuItem['prix']}€',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height:5)
                        ],
                      ),
                    ));
              },
            ),
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchMenu(int idCat) async {
    try {
      final int? idRest = Panier().getIdRestaurant();
      if (idRest == null) {
        throw Exception('Restaurant ID is null');
      }
      String myIp = Global.myIp;
      final response = await http.get(
          Uri.parse('http://$myIp:3000/getItem?id_cat=$idCat&id_rest=$idRest'));

      if (response.statusCode == 200) {
        final List<dynamic>? responseData =
            json.decode(response.body)['formattedItems'];

        if (responseData != null && responseData.isNotEmpty) {
          return responseData
              .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
              .toList();
        } else {
          if (kDebugMode) {
            print('Erreur de menu de récupération : les données de réponse sont nulles ou vides');
          }
          return [];
        }
      } else {
        if (kDebugMode) {
          print('Erreur lors de la récupération du menu. Code d\'état : ${response.statusCode}');
        }
        throw Exception(
            'Échec de la récupération du menu. Code d\'état : ${response.statusCode}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Erreur lors de la récupération du menu : $error');
      }
      return [];
    }
  }
}

class Category {
  final int idCat;
  final String nomCat;
  final String imageUrl;

  Category({
    required this.idCat,
    required this.nomCat,
    required this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final int? categoryId = json['id_cat'] as int?;
    final String? categoryNomCat = json['nom_cat'] as String?;
    final String? categoryImageUrl = json['image'] as String?;
      String myIp = Global.myIp;
    if (categoryId != null &&
        categoryNomCat != null &&
        categoryImageUrl != null) {
      return Category(
        idCat: categoryId,
        nomCat: categoryNomCat,
        imageUrl: 'http://$myIp:3000/'+ categoryImageUrl,
      );
    } else {
      if (kDebugMode) {
        print(
            "Avertissement: 'id_cat', 'nom_cat' ou 'image_url' est null dans JSON data. Utilisation des valeurs par défaut.");
      }
      return Category(idCat: 0, nomCat: 'Catégorie par defaut', imageUrl: '');
    }
  }
}
