import 'package:flutter/material.dart';
import 'history_manager.dart';
import 'mesaj.dart';

class SohbetGecmisiSayfasi extends StatefulWidget {
  final String deviceId;
  const SohbetGecmisiSayfasi({Key? key, required this.deviceId})
    : super(key: key);

  @override
  _SohbetGecmisiSayfasiState createState() => _SohbetGecmisiSayfasiState();
}

class _SohbetGecmisiSayfasiState extends State<SohbetGecmisiSayfasi> {
  List<Mesaj> gecmisMesajlar = [];

  @override
  void initState() {
    super.initState();
    _gecmisiYukle();
  }

  Future<void> _gecmisiYukle() async {
    final session = await HistoryManager.getOturumByDeviceId(widget.deviceId);
    if (session != null) {
      setState(() {
        gecmisMesajlar = session.mesajlar;
      });
    } else {
      setState(() {
        gecmisMesajlar = [];
      });
    }
  }

  Future<void> _gecmisiTemizle() async {
    // Tek cihaz için oturumu tamamen silmek ve mesaj listesini boşaltmak
    final session = await HistoryManager.getOturumByDeviceId(widget.deviceId);
    if (session != null) {
      await HistoryManager.deleteSession(session.id);
    }
    setState(() {
      gecmisMesajlar = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Sohbet Geçmişi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Geçmişi Temizle'),
                  content: const Text(
                    'Sohbet geçmişini silmek istediğinize emin misiniz?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _gecmisiTemizle();
              }
            },
            tooltip: 'Geçmişi Temizle',
          ),
        ],
      ),
      body: gecmisMesajlar.isEmpty
          ? const Center(
              child: Text(
                'Geçmiş mesaj bulunamadı.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: gecmisMesajlar.length,
              itemBuilder: (context, index) {
                final mesaj = gecmisMesajlar[index];
                return Align(
                  alignment: mesaj.kullanici
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: mesaj.kullanici
                          ? Colors.grey.shade800
                          : Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mesaj.metin,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        if (mesaj.model != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Model: ${mesaj.model}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
