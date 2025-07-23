import 'package:chatbot_app/sohbet_oturumlari_sayfasi.dart';
import 'package:flutter/material.dart';
import 'SohbetOturumu.dart';
import 'history_manager.dart';
import 'mesaj.dart';

class SohbetEkrani extends StatefulWidget {
  final SohbetOturumu session;

  const SohbetEkrani({
    Key? key,
    required this.session,
    required SohbetOturumu oturum,
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

  void _mesajGonder() async {
    final metin = _mesajController.text.trim();
    if (metin.isEmpty) return;

    setState(() {
      _mesajlar.add(Mesaj(metin: metin, kullanici: true));
    });
    _mesajController.clear();

    // Simüle edilmiş bot cevabı
    final botCevabi = "Bot cevabı: $metin";

    setState(() {
      _mesajlar.add(Mesaj(metin: botCevabi, kullanici: false));
    });

    // Oturumdaki mesajları güncelle ve kaydet
    final updatedSession = SohbetOturumu(
      id: widget.session.id,
      baslik: widget.session.baslik,
      mesajlar: _mesajlar,
      deviceId: '',
    );

    await HistoryManager.updateSession(updatedSession);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.session.baslik)),
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
                  child: TextField(
                    controller: _mesajController,

                    decoration: const InputDecoration(
                      hintText: 'Mesaj yaz...',
                      border: OutlineInputBorder(),
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
