import 'package:flutter/material.dart';

class ApiService {
  static Future<String> mesajGonder(String mesaj) async {
    await Future.delayed(const Duration(seconds: 1)); // Simülasyon
    return "Bot cevabı: $mesaj";
  }
}

class Mesaj {
  final String metin;
  final bool kullanici;
  Mesaj({required this.metin, required this.kullanici});
}

class SohbetEkrani extends StatefulWidget {
  @override
  _SohbetEkraniState createState() => _SohbetEkraniState();
}

class _SohbetEkraniState extends State<SohbetEkrani> {
  final TextEditingController _mesajController = TextEditingController();
  final List<Mesaj> _mesajlar = [];

  void _mesajGonder() async {
    final metin = _mesajController.text.trim();
    if (metin.isEmpty) return;

    setState(() {
      _mesajlar.add(Mesaj(metin: metin, kullanici: true));
    });
    _mesajController.clear();

    try {
      final botCevabi = await ApiService.mesajGonder(metin);
      setState(() {
        _mesajlar.add(Mesaj(metin: botCevabi, kullanici: false));
      });
    } catch (e) {
      print('Hata oluştu: $e');
      setState(() {
        _mesajlar.add(
          Mesaj(metin: 'Sunucuya bağlanılamadı.', kullanici: false),
        );
      });
    }
  }

  void _dosyaEkle() {
    print("DOSYA EKLE BUTONUNA BASILDI ✅");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dosya Ekle'),
        content: const Text('Dosya ekleme fonksiyonu yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ChatBot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _mesajlar.length,
              itemBuilder: (context, index) {
                final mesaj = _mesajlar[index];
                return Align(
                  alignment: mesaj.kullanici
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mesaj.kullanici
                          ? Colors.blue[200]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(mesaj.metin),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        controller: _mesajController,
                        decoration: const InputDecoration(
                          hintText: 'Mesaj yaz...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                        ),
                        onSubmitted: (_) => _mesajGonder(),
                      ),
                      Positioned(
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.attach_file),
                          color: Colors.grey,
                          onPressed: _dosyaEkle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _mesajGonder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
