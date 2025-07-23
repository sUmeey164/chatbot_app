import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatbot_app/API/api_service.dart';
import 'package:chatbot_app/GirisKayitSayfasi.dart';
import 'package:chatbot_app/sohbet_gecmisi_sayfasi.dart';
import 'package:chatbot_app/history_manager.dart';
import 'mesaj.dart';
import 'mesaj_giris_alani.dart';
import 'SohbetOturumu.dart';
//import 'sohbet_oturumlari_sayfasi.dart';

final ImagePicker _picker = ImagePicker();

//class Mesaj {final String metin;final bool kullanici;final String? model;

// Mesaj({required this.metin, required this.kullanici, this.model});}

class HomePage extends StatefulWidget {
  final String? kullaniciAdi;
  final String deviceId;

  const HomePage({Key? key, required this.kullaniciAdi, required this.deviceId})
    : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String aktifSessionId = '';

  Color getMesajRengi(Mesaj mesaj) {
    print('Debug: Mesaj model=${mesaj.model}, kullanici=${mesaj.kullanici}');

    if (mesaj.kullanici) {
      return Colors.grey.shade800; // Kullanıcının mesajı sabit renk
    }

    final model = mesaj.model ?? 'Chatbot'; // 👈 model null ise varsayılan ver
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

  IconData getModelIcon(String model) {
    switch (model) {
      case 'Chatbot':
        return Icons.smart_toy;
      case 'ChatGPT':
        return Icons.chat_bubble_outline;
      case 'Gemini':
        return Icons.auto_awesome;
      case 'DeepSeek':
        return Icons.search;
      default:
        return Icons.smart_toy;
    }
  }

  final List<Mesaj> mesajlar = [];
  final TextEditingController _mesajController = TextEditingController();
  String secilenModel = 'Chatbot';
  String? secilenDosyaAdi;
  bool sohbetBasladi = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 50), _gecmisiYukle);
  }

  Future<void> _gecmisiYukle() async {
    final session = await HistoryManager.getOturumByDeviceId(widget.deviceId);
    if (!mounted) return;
    setState(() {
      if (session != null) {
        mesajlar.addAll(session.mesajlar);
        aktifSessionId = session.id;
      } else {
        aktifSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      }
    });
  }

  void modelDegistir(String yeniModel) async {
    // Sadece aktif oturumu temizle
    if (aktifSessionId.isNotEmpty) {
      await HistoryManager.deleteSession(aktifSessionId);
    }
    setState(() {
      secilenModel = yeniModel;
      mesajlar.clear();
      sohbetBasladi = false;
    });
  }

  Color mesajRengi() {
    switch (secilenModel) {
      case 'ChatGPT':
        return Colors.pink;
      case 'Gemini':
        return Colors.blue;
      case 'DeepSeek':
        return Colors.amber;
      case 'Chatbot':
      default:
        return Colors.deepPurple;
    }
  }

  Widget _modelSecimCard(String modelAdi, IconData ikon, Color renk) {
    return GestureDetector(
      onTap: () {
        modelDegistir(modelAdi);
        Navigator.pop(context);
      },
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(ikon, color: renk, size: 28),
              const SizedBox(width: 16),
              Text(
                modelAdi,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void mesajGonderVeGetir(String mesaj) async {
    if (mesaj.trim().isEmpty && secilenDosyaAdi == null) return;

    if (!sohbetBasladi) {
      setState(() {
        sohbetBasladi = true;
      });
    }

    String gonderilecekMesaj = mesaj.trim();
    if (secilenDosyaAdi != null) {
      gonderilecekMesaj =
          '[Dosya: $secilenDosyaAdi]' +
          (gonderilecekMesaj.isNotEmpty ? ' $gonderilecekMesaj' : '');
    }
    setState(() {
      mesajlar.add(
        Mesaj(metin: gonderilecekMesaj, kullanici: true, model: secilenModel),
      );
      secilenDosyaAdi = null;
    });

    _mesajController.clear();
    await mesajEkleVeKaydet(gonderilecekMesaj, widget.deviceId, true);

    try {
      final cevap = await ApiService.mesajGonder(
        gonderilecekMesaj,
        model: secilenModel,
        deviceId: widget.deviceId,
      );

      setState(() {
        mesajlar.add(
          Mesaj(metin: cevap, kullanici: false, model: secilenModel),
        );
      });

      await HistoryManager.addMessage(
        Mesaj(metin: cevap, kullanici: false, model: secilenModel),
        aktifSessionId,
      );
    } catch (e) {
      setState(() {
        mesajlar.add(
          Mesaj(
            metin: 'Sunucuya bağlanılamadı.',
            kullanici: false,
            model: secilenModel,
          ),
        );
      });
    }
  }

  Future<void> mesajEkleVeKaydet(
    String mesajMetni,
    String deviceId,
    bool kullaniciMesaji,
  ) async {
    SohbetOturumu? mevcutOturum = await HistoryManager.getOturumByDeviceId(
      deviceId,
    );

    if (mevcutOturum == null) {
      mevcutOturum = SohbetOturumu(
        id: aktifSessionId,
        baslik: 'Yeni Oturum',
        mesajlar: [],
        deviceId: deviceId,
      );
    } else {
      aktifSessionId = mevcutOturum.id;
    }

    mevcutOturum.mesajlar.add(
      Mesaj(metin: mesajMetni, kullanici: kullaniciMesaji),
    );

    await HistoryManager.saveSession(mevcutOturum);
  }

  void dosyaSec() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String dosyaAdi = result.files.single.name!;
      setState(() {
        secilenDosyaAdi = dosyaAdi;
      });
    }
  }

  void kameraIleCek() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      String fotoAdi = foto.name;
      setState(() {
        secilenDosyaAdi = fotoAdi;
      });
    }
  }

  void galeridenSec() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.gallery);
    if (foto != null) {
      String fotoAdi = foto.name;
      setState(() {
        secilenDosyaAdi = fotoAdi;
      });
    }
  }

  void _dosyaSecimDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionColumn(Icons.image, 'Galeri', () {
                    Navigator.pop(context);
                    galeridenSec();
                  }),
                  _buildActionColumn(Icons.camera_alt, 'Kamera', () {
                    Navigator.pop(context);
                    kameraIleCek();
                  }),
                  _buildActionColumn(Icons.insert_drive_file, 'Dosya', () {
                    Navigator.pop(context);
                    dosyaSec();
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionColumn(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, size: 28, color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String yazi) {
    return ActionChip(
      label: Text(yazi),
      backgroundColor: Colors.grey[850],
      labelStyle: const TextStyle(color: Colors.white),
      onPressed: () => mesajGonderVeGetir(yazi),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.grey,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _modelSecimCard(
                          "Chatbot",
                          Icons.smart_toy,
                          Colors.deepPurple,
                        ),
                        const SizedBox(height: 10),
                        _modelSecimCard(
                          "ChatGPT",
                          Icons.chat_bubble_outline,
                          Colors.pink,
                        ),
                        const SizedBox(height: 10),
                        _modelSecimCard(
                          "Gemini",
                          Icons.auto_awesome,
                          Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        _modelSecimCard("DeepSeek", Icons.search, Colors.amber),
                      ],
                    ),
                  );
                },
              );
            },
            child: SizedBox(
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: mesajRengi(),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    getModelIcon(secilenModel),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          secilenModel,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SohbetGecmisiSayfasi(deviceId: widget.deviceId),
                ),
              );
            },
            tooltip: 'Sohbet Geçmişi',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: mesajlar.length,
                itemBuilder: (context, index) {
                  final mesaj = mesajlar[index];

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
                      child: Text(
                        mesaj.metin,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (!sohbetBasladi)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                height: 48,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chip("Bana çalışma ipuçları ver"),
                      const SizedBox(width: 8),
                      _chip("Bana tavsiye ver"),
                      const SizedBox(width: 8),
                      _chip("Bir şey öner"),
                    ],
                  ),
                ),
              ),
            if (secilenDosyaAdi != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        secilenDosyaAdi!,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          secilenDosyaAdi = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mesajController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Mesaj yaz...",
                        hintStyle: TextStyle(
                          color: mesajRengi().withOpacity(0.7),
                        ),
                        filled: true,
                        fillColor: mesajRengi().withOpacity(0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.attach_file, color: mesajRengi()),
                          onPressed: _dosyaSecimDialog,
                        ),
                      ),
                      onSubmitted: mesajGonderVeGetir,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: mesajRengi()),
                    onPressed: () => mesajGonderVeGetir(_mesajController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
