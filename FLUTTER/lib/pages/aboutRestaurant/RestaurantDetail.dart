// ignore_for_file: library_private_types_in_public_api, file_names, duplicate_ignore, unnecessary_null_comparison, use_build_context_synchronously, unused_element
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
          panier.origin = 'Restaurant';
          if (!authProvider.isAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const loginPage()),
            );
          } else {
            Panier().updateCommandeDetails(
              selectedRetraitMode,
              selectedTime,
            );
            SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('token');

                // Vérifier si un token est présent dans le stockage local
                if (token != null && token.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddressSearchScreen(),
                ),
              );
            }
          }
        }
      }
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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: Text(restaurantName ?? 'Restaurant Detail'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
           child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
  Center(
  child: SizedBox(
    height: MediaQuery.of(context).size.height / 3,
    width: 2000,
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),     
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 1,
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
  ),
),

   Container(
  decoration: BoxDecoration(
    border: Border.all(color: const Color.fromARGB(255, 234, 231, 231)),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    children: [
      SizedBox(
        height: MediaQuery.of(context).size.height / 7,
        width: MediaQuery.of(context).size.height / 7,
        
        child: ClipRRect(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height / 14),
          child: restaurantLogo != null
              ? Image.network(
                  restaurantLogo,
                  fit: BoxFit.cover,
                )
              : Container(),
        ),
      ),
      const SizedBox(width: 10),
    ],
  ),
),



              const SizedBox(height: 10),
              Container(
                width: 1500,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 234, 231, 231)),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Text(restaurantAdress ?? 'Restaurant Detail'),
                     const Text(
                      'Nous acceptons:',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 1500,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 234, 231, 231)),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mode de retrait*:',
                      style: TextStyle(fontSize: 18),
                    ),
                    Column(
                      children: restaurant != null
                          ? restaurant.split(',').map((mode) {
                              return RadioListTile(
                                title: Text(mode.trim()),
                                value: mode.trim(),
                                groupValue: selectedRetraitMode,
                                onChanged: (value) {
                                  setState(() {
                                    selectedRetraitMode = value.toString();
                                    _selectTime(context);
                                  });
                                },
                              );
                            }).toList()
                          : [],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
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
            ],
          ),
        ),
        ),
      ),
    );
  }
}
