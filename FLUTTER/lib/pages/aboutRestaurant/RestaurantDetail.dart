// ignore_for_file: library_private_types_in_public_api, file_names, duplicate_ignore, unnecessary_null_comparison, use_build_context_synchronously, unused_element
// import 'dart:ffi';

import 'package:demo/pages/aboutRestaurant/DesignRestaurantDetaild.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CategoryPage.dart';
import './../global.dart';
import './../aboutUser/auth_provider.dart';
import './../aboutUser/adresse.dart';
import './../aboutUser/login.dart';

class RestaurantDetail extends StatefulWidget {
  const RestaurantDetail({
    super.key,
  });

  @override
  _RestaurantDetailState createState() => _RestaurantDetailState();
}

class _RestaurantDetailState extends State<RestaurantDetail> {
  String selectedRetraitMode = '';
  late TimeOfDay selectedTime;
  late TimeOfDay initialTime = TimeOfDay.now();
  AuthProvider authProvider = AuthProvider();
  Panier panier = Panier();
  @override
  void initState() {
    super.initState();
    initAuthProvider();
    selectedTime = TimeOfDay.now();
  }

  Future<void> initAuthProvider() async {
    await authProvider.initTokenFromStorage();

    setState(() {});
  }

  Future<void> _selectTime(BuildContext context) async {
    int initialMinutesToAdd = selectedRetraitMode == 'En Livraison' ? 30 : 15;
    TimeOfDay initialTime = TimeOfDay.fromDateTime(
        DateTime.now().add(Duration(minutes: initialMinutesToAdd)));

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      DateTime currentTime = DateTime.now();
      DateTime selectedDateTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      DateTime initialDateTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        initialTime.hour,
        initialTime.minute,
      );

      if (selectedDateTime.isBefore(initialDateTime)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Heure invalide'),
              content: const Text(
                'Veuillez choisir une heure après l\'heure actuelle.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          selectedTime = pickedTime;
        });

        Panier().updateCommandeDetails(selectedRetraitMode, selectedTime);

        if (selectedRetraitMode == 'En Livraison') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? token = prefs.getString('token');

          if (token != null && token.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddressSearchScreen(),
              ),
            );
          } else {
            panier.origin = 'Restaurant';
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const loginPage()),
            );
          }
        }
      }
    } else {
      setState(() {
        selectedRetraitMode = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? restaurantName = Panier().getSelectedRestaurantName();
    String? restaurantAdress = Panier().getSelectedRestaurantAdresse();
    String? restaurant = Panier().getSelectedRestaurantMode();
    String? restaurantLogo = Panier().getSelectedRestaurantLogo();
    String? restaurantImage = Panier().getSelectedRestaurantImage();
    return Scaffold(
      backgroundColor: Colors.white,
    
      body: Expanded(
        child: Column(
          children: [
 Expanded(
  child: Stack(
    alignment: Alignment.bottomCenter,
    clipBehavior: Clip.none,
    children: [
      // Image du restaurant
      Container(
        padding: const EdgeInsets.all(1.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
          image: restaurantImage != null
              ? DecorationImage(
                  image: NetworkImage(restaurantImage),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),
      // Conteneur pour l'icône du bouton de retour
      Positioned(
        top: 20.0,
        left: 10.0,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromARGB(255, 243, 226, 201).withOpacity(0.4),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              panier.origine = 'RestList';
              Navigator.pushReplacementNamed(context, '/RestaurantScreen');
            },
          ),
        ),
      ),
      // Row pour le logo du restaurant et le conteneur du nom du restaurant
      Positioned(
        bottom: -35,
        child: Container(
          width: 400,
          margin: const EdgeInsetsDirectional.only(start: 40, end: 40),
          height: 70, 
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(50),
              bottomLeft: Radius.circular(50),
              topLeft: Radius.circular(50)
            ),
            color: Colors.white,
            boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (restaurantLogo != null)
          Container(
            clipBehavior: Clip.hardEdge,
            height: 100,
            width: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Image.network(
              restaurantLogo,
              fit: BoxFit.fill,
            ),
          ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurantName ?? 'Restaurant Detail',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Ajoutez ici d'autres éléments s'il y en a
              ],
            ),
          ),
        ),
      ],
    ),
  ),
)
],
  
  ),
),
       
            const SizedBox(height: 50),
    SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(5), 
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Ajuste la largeur des enfants pour remplir la largeur disponible
        children: [
        Card(
          surfaceTintColor: Colors.orange.withOpacity(0.4),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color:  Color.fromARGB(255, 234, 231, 231)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        const Icon(
          Icons.location_on,
          color: Colors.green, // Couleur de l'icône de localisation
        ),
        const SizedBox(width: 5), // Espacement entre l'icône et le texte de l'adresse
        Text(
          restaurantAdress ?? 'Restaurant Detail',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
    const SizedBox(height: 20), 
  ],
),

          ),
        ),
        const SizedBox(height: 5),
        Card(
          surfaceTintColor: Colors.orange.withOpacity(0.4),
          color: Colors.white,
          elevation: 5, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color:  Color.fromARGB(255, 234, 231, 231)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mode de retrait*:',
                  style: TextStyle(fontSize: 20), 
                ),
                const SizedBox(height: 17), 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: restaurant != null
                      ? restaurant.split(',').map((mode) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: GlowRadioButton(
                              label: mode.trim(),
                              value: mode.trim(),
                              groupValue: selectedRetraitMode,
                              onChanged: (value) {
                                setState(() {
                                  selectedRetraitMode = value;
                                });
                                _selectTime(context);
                              },
                            ),
                          );
                        }).toList()
                      : [],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
)
       ],
        ),
      ),
     
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              if (selectedRetraitMode.isNotEmpty) {
                DateTime selectedDateTime = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                DateTime initialDateTime = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  initialTime.hour,
                  initialTime.minute,
                );

                if (selectedDateTime.isAfter(initialDateTime)) {
                  Panier().updateCommandeDetails(
                    selectedRetraitMode,
                    selectedTime,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NextPage(
                        panier: Panier().articles,
                      ),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Heure invalide'),
                        content: const Text(
                          'Veuillez choisir une heure après l\'heure actuelle.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.black,
            ),
            child: const Text(
              'Commander dans ce restaurant',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
