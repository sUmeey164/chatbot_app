import 'package:flutter/material.dart';
import 'SohbetOturumu.dart';

class SohbetOturumlariSayfasi extends StatelessWidget {
  const SohbetOturumlariSayfasi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Burada sohbet oturumlarını listeleyip, tıklanınca detay sayfasına geçebilirsin.
    return Scaffold(
      appBar: AppBar(title: Text('Sohbet Oturumları')),
      body: Center(child: Text('Sohbet oturumları listesi burada olacak')),
    );
  }
}
