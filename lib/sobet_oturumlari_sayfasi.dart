// lib/sobet_oturumlari_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:chatbot_app/history_manager.dart';
import 'package:chatbot_app/SohbetOturumu.dart';
import 'package:chatbot_app/sohbet_gecmisi_sayfasi.dart';

class SohbetOturumlariSayfasi extends StatefulWidget {
  const SohbetOturumlariSayfasi({Key? key}) : super(key: key);

  @override
  _SohbetOturumlariSayfasiState createState() =>
      _SohbetOturumlariSayfasiState();
}

class _SohbetOturumlariSayfasiState extends State<SohbetOturumlariSayfasi> {
  List<SohbetOturumu> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });
    final sessions = await HistoryManager.getAllSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  // HomePage'deki mesajRengi fonksiyonunun benzeri, burada oturum rengini belirlemek için kullanılacak
  Color getSessionColor(String? model) {
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
        title: const Text(
          'Sohbet Oturumları',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : _sessions.isEmpty
          ? const Center(
              child: Text(
                'Henüz sohbet oturumu bulunmamaktadır.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final sessionCardColor = getSessionColor(session.model);
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 4.0,
                  ),
                  color: sessionCardColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: sessionCardColor, width: 1.5),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.chat_bubble_outline,
                      color: sessionCardColor,
                    ),
                    title: Text(
                      session.baslik.isNotEmpty
                          ? session.baslik
                          : 'Adsız Sohbet Oturumu',
                      style: TextStyle(
                        color:
                            sessionCardColor, // Burada doğrudan rengi kullanın
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${session.mesajlar.length} mesaj - ${session.model ?? 'Bilinmeyen Model'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade300),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'Oturumu Sil',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Bu sohbet oturumunu silmek istediğinizden emin misiniz?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            backgroundColor: Colors.grey[850],
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text(
                                  'İptal',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Sil',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await HistoryManager.deleteSession(session.id);
                          _loadSessions();
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SohbetGecmisiSayfasi(
                            deviceId: session.deviceId,
                            sessionId: session
                                .id, // Belirli bir oturumu yüklemek için session ID'sini gönder
                          ),
                        ),
                      ).then((_) {
                        _loadSessions();
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
