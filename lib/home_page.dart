import 'package:chatbot_app/API/api_service.dart';
import 'package:flutter/material.dart';
import 'pro_premium.dart';
import 'ayarlar_sayfasi.dart';
import 'api_service.dart' hide ApiService;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker(); // Kamera/galeri için tanımlama

class Mesaj {
  final String metin;
  final bool kullanici;
  Mesaj({required this.metin, required this.kullanici});
}

class HomePage extends StatefulWidget {
  final String? kullaniciAdi;

  const HomePage({super.key, this.kullaniciAdi});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Mesaj> mesajlar = [];
  final TextEditingController _mesajController = TextEditingController();

  bool sohbetBasladi = false;

  //   Dosya ekle butonunun alt menüsünün açık/kapalı olması
  bool dosyaMenuAcik = false;

  void mesajGonderVeGetir(String mesaj) async {
    if (mesaj.trim().isEmpty) return;

    if (!sohbetBasladi) {
      setState(() {
        sohbetBasladi = true;
      });
    }

    setState(() {
      mesajlar.add(Mesaj(metin: mesaj, kullanici: true));
    });
    _mesajController.clear();

    try {
      final cevap = await ApiService.mesajGonder(mesaj);
      setState(() {
        mesajlar.add(Mesaj(metin: cevap, kullanici: false));
      });
    } catch (e) {
      setState(() {
        mesajlar.add(Mesaj(metin: 'Sunucuya bağlanılamadı.', kullanici: false));
      });
    }
  }

  // Dosya seçimi
  void dosyaSec() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String dosyaYolu = result.files.single.path!;
      print(" Dosya seçildi: $dosyaYolu");
      // TODO: dosyayı ekle veya göster
    } else {
      print("Dosya seçilmedi.");
    }
  }

  //  Kamera
  void kameraIleCek() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      print("Kameradan çekilen: ${foto.path}");
      //  Görseli ekle veya gönder.
    }
  }

  //  Galeri
  void galeridenSec() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.gallery);
    if (foto != null) {
      print("Galeriden seçilen: ${foto.path}");
      //  Görseli ekle veya gönder
    }
  }

  //   Dosya ekle butonuna basıldığında alt menüyü açıp kapama
  void _dosyaEkle() {
    setState(() {
      dosyaMenuAcik = !dosyaMenuAcik;
    });
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProPremiumSayfasi(),
                ),
              );
            },
            child: Container(
              constraints: const BoxConstraints(minWidth: 15),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: const Text('Chatbot', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AyarlarSayfasi(),
                  ),
                );
              },
              child: Container(
                width: 60,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.menu, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!sohbetBasladi) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Colors.blue, Colors.purple, Colors.pink],
                  ).createShader(bounds);
                },
                child: Text(
                  'Merhaba${widget.kullaniciAdi != null && widget.kullaniciAdi!.isNotEmpty ? ' ${widget.kullaniciAdi!.toLowerCase()}' : ''},',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],

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
                      color: mesaj.kullanici
                          ? Colors.deepPurple
                          : Colors.grey[800],
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 48,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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

          //  Burada mesaj yazma satırı ve altına dosya eklemenin yatay alt menüsü eklenir.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mesajController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Mesaj yaz...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.attach_file,
                              color: Colors.deepPurple,
                            ),
                            onPressed: _dosyaEkle,
                          ),
                        ),
                        onSubmitted: mesajGonderVeGetir,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepPurple),
                        onPressed: () =>
                            mesajGonderVeGetir(_mesajController.text),
                      ),
                    ),
                  ],
                ),

                //  Alt menü: dosya menüsü açık ise yan yana butonları gösterir.
                if (dosyaMenuAcik)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.insert_drive_file,
                            color: Colors.white,
                          ),
                          tooltip: 'Dosya Seç',
                          onPressed: dosyaSec,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                          ),
                          tooltip: 'Kamera',
                          onPressed: kameraIleCek,
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo, color: Colors.white),
                          tooltip: 'Galeri',
                          onPressed: galeridenSec,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
