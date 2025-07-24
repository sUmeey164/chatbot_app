// lib/sohbet_ekrani.dart
import 'package:flutter/material.dart';
import 'package:chatbot_app/SohbetOturumu.dart'; // Düzeltilen import
import 'package:chatbot_app/history_manager.dart'; // Düzeltilen import
import 'package:chatbot_app/mesaj.dart'; // Düzeltilen import
import 'dart:io'; // File sınıfı için gerekli

class SohbetEkrani extends StatefulWidget {
  final SohbetOturumu session;

  const SohbetEkrani({
    Key? key,
    required this.session, // Sadece bu parametre yeterli
  }) : super(key: key);

  @override
  _SohbetEkraniState createState() => _SohbetEkraniState();
}

class _SohbetEkraniState extends State<SohbetEkrani> {
  late List<Mesaj> _mesajlar;
  final TextEditingController _mesajController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mesajlar = List.from(widget.session.mesajlar);
  }

  // Mesaj renklerini belirlemek için basit bir fonksiyon
  Color _getMesajRengi(Mesaj mesaj) {
    if (mesaj.kullanici) {
      return Colors.blue[200]!;
    }
    switch (mesaj.model) {
      case 'Gemini':
        return Colors.blue.shade100;
      case 'ChatGPT':
        return Colors.pink.shade100;
      case 'DeepSeek':
        return Colors.amber.shade100;
      case 'Chatbot':
      default:
        return Colors.grey[300]!;
    }
  }

  void _mesajGonder() async {
    final metin = _mesajController.text.trim();
    if (metin.isEmpty) return;

    final userModel =
        widget.session.model ?? 'Chatbot'; // Null kontrolü yapıldı

    setState(() {
      _mesajlar.add(Mesaj(metin: metin, kullanici: true, model: userModel));
    });
    _mesajController.clear();

    final botCevabi = "Bot cevabı: $metin"; // Simüle edilmiş bot cevabı

    setState(() {
      _mesajlar.add(
        Mesaj(metin: botCevabi, kullanici: false, model: userModel),
      );
    });

    final updatedSession = SohbetOturumu(
      id: widget.session.id,
      baslik: widget.session.baslik,
      mesajlar: _mesajlar,
      deviceId: widget.session.deviceId, // Doğru deviceId kullanımı
      model: widget.session.model, // Doğru model kullanımı
    );

    await HistoryManager.updateSession(updatedSession);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.session.baslik,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: _getMesajRengi(mesaj),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // YENİ: Eğer oluşturulan görselin URL'si varsa göster
                        if (mesaj.imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                mesaj.imageUrl!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Text(
                                      'Görsel yüklenemedi.',
                                      style: TextStyle(color: Colors.black),
                                    ),
                              ),
                            ),
                          ),
                        // Eğer kullanıcının gönderdiği bir görsel yolu varsa
                        if (mesaj.filePath != null && mesaj.fileType == 'image')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(mesaj.filePath!),
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Text(
                                      'Görsel yüklenemedi.',
                                      style: TextStyle(color: Colors.black),
                                    ),
                              ),
                            ),
                          ),
                        // Eğer dosya varsa, dosya adını ve ikonu göster
                        if (mesaj.filePath != null && mesaj.fileType == 'file')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.black54,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    mesaj.metin.contains('[Dosya:') &&
                                            mesaj.metin.contains(']')
                                        ? mesaj.metin.substring(
                                            mesaj.metin.indexOf('[Dosya:') + 8,
                                            mesaj.metin.indexOf(']'),
                                          )
                                        : mesaj.metin,
                                    style: const TextStyle(color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (mesaj.metin.isNotEmpty)
                          Text(
                            mesaj.metin,
                            style: const TextStyle(color: Colors.black),
                          ),
                      ],
                    ),
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
                  child: TextField(
                    controller: _mesajController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Mesaj yaz...',
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (value) => _mesajGonder(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
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
