import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:chatbot_app/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Otomatik kullanıcı adı oluşturan fonksiyon
String otomatikUsernameOlustur() {
  const harfler = 'abcdefghijklmnopqrstuvwxyz';
  Random rnd = Random();
  String rastgeleHarfler = List.generate(
    5,
    (_) => harfler[rnd.nextInt(harfler.length)],
  ).join();
  int sayi = rnd.nextInt(9999);
  return 'user_$rastgeleHarfler$sayi';
}

class KullaniciYonlendirici extends StatefulWidget {
  const KullaniciYonlendirici({super.key});

  @override
  State<KullaniciYonlendirici> createState() => _KullaniciYonlendiriciState();
}

class _KullaniciYonlendiriciState extends State<KullaniciYonlendirici> {
  @override
  void initState() {
    super.initState();
    kullaniciBilgileriniHazirla();
  }

  Future<void> kullaniciBilgileriniHazirla() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceInfo = DeviceInfoPlugin();

      String deviceId = 'bilinmeyen_cihaz';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id?.toString() ?? 'android_default_id';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'ios_default_id';
      } else {
        deviceId = Platform.localHostname;
      }

      String? username = prefs.getString('username');

      if (username == null) {
        username = otomatikUsernameOlustur();
        await prefs.setString('username', username);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            deviceId: deviceId,
            kullaniciAdi: username, // 👈 BU SATIRI DÜZENLEDİK
          ),
        ),
      );
    } catch (e) {
      print("Kullanıcı bilgileri hazırlanırken hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
    );
  }
}
