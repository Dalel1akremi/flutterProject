import 'package:flutter/material.dart';
class SalesTermsPage extends StatelessWidget {
  const SalesTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: const Color.fromARGB(222, 212, 133, 14),
        title: const Text('CGV'),
      ),
      body: const Center(
        child: Text('Contenu des conditions de vente'),
      ),
    );
  }
}