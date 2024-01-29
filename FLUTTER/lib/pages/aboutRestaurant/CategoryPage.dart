import 'package:flutter/material.dart';
class NextPage extends StatelessWidget {
  final String selectedMode;

  const NextPage(this.selectedMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Confirmation'),
      ),
      body: Center(
        child: Text('Selected Mode: $selectedMode'),
      ),
    );
  }
}
