import 'package:flutter/material.dart';

class ProPremiumSayfasi extends StatelessWidget {
  const ProPremiumSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro / Premium Özellikler'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            /* Text(
              'Pro / Premium Özellikler',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            */
          ],
        ),
      ),
    );
  }
}
