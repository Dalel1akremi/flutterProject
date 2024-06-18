// ignore_for_file: non_constant_identifier_names, file_names

import 'dart:convert';
import 'package:demo/pages/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Restaurant {
  final String nom;
  final String email;
  final String adresse;
  final String numero_telephone;

  Restaurant({
    required this.nom,
    required this.email,
    required this.adresse,
    required this.numero_telephone,
  });
}

class SalesTermsPage extends StatefulWidget {
  const SalesTermsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SalesTermsPageState createState() => _SalesTermsPageState();
}

class _SalesTermsPageState extends State<SalesTermsPage> {
  late Future<List<Restaurant>> _restaurants;
  // ignore: avoid_init_to_null
  late String? _selectedRestaurant = null;
  late ExpansionTileController _expansionTileController;

  @override
  void initState() {
    super.initState();
    _restaurants = _fetchRestaurants();
    _expansionTileController = ExpansionTileController();
  }

  Future<List<Restaurant>> _fetchRestaurants() async {
   String myIp = Global.myIp;
    final response = await http
        .get(Uri.parse('http://$myIp:3000/getAllRestaurantNames'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey('restaurants')) {
        List<Restaurant> restaurants =
            (data['restaurants'] as List).map<Restaurant>((item) {
          return Restaurant(
            nom: item['nom'],
            email: item['email'],
            adresse: item['adresse'],
            numero_telephone: item['numero_telephone'],
          );
        }).toList();

        if (restaurants.isNotEmpty) {
          return restaurants;
        } else {
          if (kDebugMode) {
            print('Aucun détail sur le restaurant trouvé dans la réponse');
          }
          throw Exception('Aucun détail sur le restaurant trouvé dans la réponse');
        }
      } else {
        if (kDebugMode) {
          print('Clé "restaurants" introuvable dans la réponse');
        }
        throw Exception('Clé "restaurants" introuvable dans la réponse');
      }
    } else {
      if (kDebugMode) {
        print('Code d\'état d\'erreur : ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Corps de la réponse d\'erreur : ${response.body}');
      }
      throw Exception('Échec du chargement des détails du restaurant');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('CGV'),
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: _restaurants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          } else {
            List<Restaurant> restaurants = snapshot.data ?? [];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'L\'application TEST DEV regroupe plusieurs boutiques. La liste déroulante permet d\'accéder aux CGV de chaque boutique.',
                      style: TextStyle(
                        fontSize: 16,
                   
                      ),
                    ),
                  ),
                 Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(8.0), 
                    child: ExpansionTile(
                    title: GestureDetector(
                      onTap: () {
                        if (_expansionTileController.isExpanded) {
                          _expansionTileController.collapse();
                        } else {
                          _expansionTileController.expand();
                        }
                      },
                      child: _selectedRestaurant != null
                          ? Text(_selectedRestaurant!)
                          : const Text('Choisissez un restaurant'),
                    ),
                    controller: _expansionTileController,
                    children: restaurants.map((restaurant) {
                      return ListTile(
                        title: Text(restaurant.nom),
                        onTap: () {
                          setState(() {
                            _selectedRestaurant = restaurant.nom;
                          });
                          _expansionTileController.collapse();
                        },
                      );
                    }).toList(),
                  ),),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conditions générales de vente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Les présentes conditions générales de vente s\'appliquent à toutes les ventes conclues sur l\'application TEST DEV, sous réserve des conditions particulières indiquées dans la présentation des produits.',
                        ),
                        SizedBox(height: 10),
                        Text(
                          'ARTICLE 1: Mentions obligatoires',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '• Le service CC disponible depuis le site Internet et l\'application est un service de :',
                        ),
                        
                      ],
                    ),
                  ),
                  if (_selectedRestaurant != null)
                    Column(
                      children: [
                       
                         
                         ListTile(
                          title: const Text('Adresse'),
                          subtitle: Text(restaurants
                              .firstWhere((restaurant) =>
                                  restaurant.nom == _selectedRestaurant)
                              .adresse),
                        ),
                        ListTile(
                          title: const Text('Téléphone'),
                          subtitle: Text(restaurants
                              .firstWhere((restaurant) =>
                                  restaurant.nom == _selectedRestaurant)
                              .numero_telephone),
                        ),
                        ListTile(
                          title: const Text('Email'),
                          subtitle: Text(restaurants
                              .firstWhere((restaurant) =>
                                  restaurant.nom == _selectedRestaurant)
                              .email),
                        ),
                        
                                      ],
                    ),
                      const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                    'ARTICLE 2: Caractéristiques essentielles des produits et services vendus',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Le service CC propose les produits qui figurent sur le site et l\'application de la société BURGER WORLD VAULX-EN-VELIN dans la limite des stocks disponibles.',
                  ),
                  Text(
                    'Les produits présentés à la vente sont susceptibles d\'être modifiés ou supprimés par le Vendeur sans aucun préavis.',
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ARTICLE 3: Prix et livraison',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Les prix de nos produits sont indiqués en euros toutes taxes comprises (TTC) tenant compte de la TVA applicable au jour de la commande.',
                  ),
                  Text(
                    'Les prix indiqués ne comprennent pas les frais de livraison qui peuvent être facturés en supplément du prix des produits achetés suivant la distance de livraison ou montant total de la commande.',
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ARTICLE 4: Commande',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Vous avez la possibilité de commander nos produits directement sur notre site internet ou sur l\'application CC ou par téléphone au 09.73.69.16.09 du Lundi au Dimanche.',
                  ),
                  Text(
                    'Nos horaires de travail sont les suivants :',
                  ),
                  Text(
                    '- Lundi de 07:00 à 00:00',
                  ),
                  Text(
                    '- Mardi de 07:00 à 00:00',
                  ),
                  Text(
                    '- Mercredi de 02:00 à 00:00',
                  ),
                  Text(
                    '- Jeudi de 07:00 à 00:00',
                  ),
                  Text(
                    '- Vendredi de 07:00 à 00:00',
                  ),
                  Text(
                    '- Samedi de 07:00 à 00:00',
                  ),
                  Text(
                    '- Dimanche de 07:00 à 00:00',
                  ),
                  Text(
                    'Pour passer une commande :',
                  ),
                  Text(
                    '- Choisissez le mode de retrait de la commande et les horaires de retrait,',
                  ),
                  Text(
                    '- Choisissez vos articles et ajoutez-les au panier,',
                  ),
                  Text(
                    '- Si vous voulez passer sans authentification, veuillez choisir l\'option "Connexion rapide" (si elle est activée), sauf pour les commandes en livraison.',
                  ),
                  Text(
                    '- Si vous possédez déjà un compte client, veuillez-vous identifier,',
                  ),
                  Text(
                    '- Si vous ne possédez pas de compte client, veuillez en créer un en renseignant le nom, prénom, téléphone, adresse e-mail, mot de passe,',
                  ),
                  Text(
                    '- Validez le contenu de votre panier,',
                  ),
                  Text(
                    '- Choisissez votre mode de paiement,',
                  ),
                  Text(
                    '- Cliquez sur « valider ma commande » pour valider votre commande en ligne.',
                  ),
                  Text(
                    'La validation de la commande indique l\'acceptation de ces conditions générales de vente.',
                  ),
                  Text(
                    'Vous pouvez recevoir une notification indiquant l\'état de votre commande (validée, en préparation, prête).',
                  ),
                  Text(
                    'Le transfert de propriété du produit n\'aura lieu qu\'au paiement complet de votre commande.',
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ARTICLE 5: Modalités de paiement',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Plusieurs moyens de paiement sont acceptés. En tant que client, vous avez la possibilité de payer en ligne par carte bancaire ou directement en magasin ou à la livraison.',
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ARTICLE 6: Droit de rétractation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'En application des dispositions de l\'article L121-20-2 3° du Code de la Consommation, sous la seule réserve des stipulations particulières prévues à l\'Article 4.3 pour les Commandes passées en Click & Collect qui seraient annulées avant le déclenchement de sa préparation en Restaurant, le droit de rétractation applicable en matière de vente à distance ne peut être exercé dans le cas de la fourniture de biens qui du fait de leur nature sont susceptibles de se détériorer ou de se périmer rapidement.',
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ARTICLE 7: Conditions et délais de remboursement',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Le remboursement des produits n\'est possible que si le restaurant annule la commande ou après accord entre les deux parties.',
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ARTICLE 8: Propriété intellectuelle',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Tous les commentaires, images, illustrations de notre service CC nous sont exclusivement réservées. Au titre de la propriété intellectuelle et du droit d\'auteur, toute utilisation est prohibée sauf à usage privé.',
                  ),
                  Text(
                    'Sans autorisation préalable, toute reproduction de notre Service, qu\'elle soit partielle ou totale, est strictement interdite.',
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ARTICLE 9: Juridiction compétente et droit applicable',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'De façon express, quel que soit le lieu de commande ou de livraison, il est donné attribution de juridiction au tribunal, dont le restaurant dépend juridiquement, pour toute contestation pouvant surgir entre les parties, avec application de la loi française.',
                  ),
                ],
              ),
            ),     
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
