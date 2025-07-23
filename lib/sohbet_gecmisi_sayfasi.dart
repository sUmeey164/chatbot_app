// lib/sohbet_gecmisi_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:chatbot_app/history_manager.dart';
import 'package:chatbot_app/mesaj.dart';
import 'package:chatbot_app/SohbetOturumu.dart';
import 'dart:io'; // File sınıfı için

class SohbetGecmisiSayfasi extends StatefulWidget {
  final String deviceId;
  final String? sessionId;

  const SohbetGecmisiSayfasi({Key? key, required this.deviceId, this.sessionId})
    : super(key: key);

  @override
  _SohbetGecmisiSayfasiState createState() => _SohbetGecmisiSayfasiState();
}

class _SohbetGecmisiSayfasiState extends State<SohbetGecmisiSayfasi> {
  SohbetOturumu? _currentSession;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.sessionId != null) {
      _currentSession = await HistoryManager.getOturumById(widget.sessionId!);
    } else {
      _currentSession = await HistoryManager.getOturumByDeviceId(
        widget.deviceId,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Color getMesajRengi(Mesaj mesaj) {
    if (mesaj.kullanici) {
      return Colors.grey.shade800;
    }
    final model = mesaj.model ?? 'Chatbot';
    switch (model) {
      case 'Gemini':
        return Colors.blue;
      case 'ChatGPT':
        return Colors.pink;
      case 'DeepSeek':
        return Colors.amber;
      case 'Chatbot':
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          _currentSession?.baslik.isNotEmpty == true
              ? _currentSession!.baslik
              : 'Sohbet Geçmişi',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : _currentSession == null || _currentSession!.mesajlar.isEmpty
          ? const Center(
              child: Text(
                'Bu oturumda mesaj bulunmamaktadır.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _currentSession!.mesajlar.length,
              itemBuilder: (context, index) {
                final mesaj = _currentSession!.mesajlar[index];
                return Align(
                  alignment: mesaj.kullanici
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: getMesajRengi(mesaj),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                      style: TextStyle(color: Colors.white),
                                    ), // Sadece bir tane color kullanın
                              ),
                            ),
                          ),
                        if (mesaj.filePath != null && mesaj.fileType == 'file')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.white70,
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
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (mesaj.metin.isNotEmpty)
                          Text(
                            mesaj.metin,
                            style: const TextStyle(color: Colors.white),
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
