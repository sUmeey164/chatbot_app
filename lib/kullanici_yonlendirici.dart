import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart'; // Bunu kendi dosya yoluna göre ayarla

class KullaniciYonlendirici extends StatefulWidget {
  const KullaniciYonlendirici({Key? key}) : super(key: key);

  @override
  State<KullaniciYonlendirici> createState() => _KullaniciYonlendiriciState();
}

class _KullaniciYonlendiriciState extends State<KullaniciYonlendirici> {
  String? _deviceId;
  bool _yukleniyor = true;
  final TextEditingController _kullaniciAdiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hazirliklariYap();
  }

  Future<void> _hazirliklariYap() async {
    // Cihaz ID'sini al
    final deviceId = await _cihazIdAl();

    // SharedPreferences'ten kayıtlı kullanıcı adını al
    final prefs = await SharedPreferences.getInstance();
    final kayitliKullaniciAdi = prefs.getString('kullaniciAdi');

    // State'i güncelle
    setState(() {
      _deviceId = deviceId;
      _yukleniyor = false;
    });

    // Eğer kayıtlı kullanıcı varsa direkt anasayfaya yönlendir
    if (kayitliKullaniciAdi != null && kayitliKullaniciAdi.isNotEmpty) {
      _anaSayfayaGec(kayitliKullaniciAdi, deviceId);
    }
  }

  // Cihaz ID alma fonksiyonu
  Future<String> _cihazIdAl() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id ?? 'bilinmeyen_android';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'bilinmeyen_ios';
      } else {
        return 'bilinmeyen_platform';
      }
    } catch (e) {
      print('Cihaz ID alınamadı: $e');
      return 'bilinmeyen_cihaz';
    }
  }

  // Anasayfaya geçiş fonksiyonu
  void _anaSayfayaGec(String kullaniciAdi, String deviceId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HomePage(deviceId: deviceId, kullaniciAdi: kullaniciAdi),
      ),
    );
  }

  // Giriş yap butonuna basıldığında çalışacak fonksiyon
  Future<void> _girisYap() async {
    final kullaniciAdi = _kullaniciAdiController.text.trim();
    if (kullaniciAdi.isEmpty || _deviceId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kullaniciAdi', kullaniciAdi);

    _anaSayfayaGec(kullaniciAdi, _deviceId!);
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Kullanıcı Adınızı Girin',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _kullaniciAdiController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Örn: sumeyye01',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Giriş Yap'),
              onPressed: _girisYap,
            ),
          ],
        ),
      ),
    );
  }
}
