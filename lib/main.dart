import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Kullanıcı adı için
import 'home_page.dart';
import 'sohbet_gecmisi_sayfasi.dart';

Future<String> cihazIDAl() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (kIsWeb) {
    return 'web_user_${DateTime.now().millisecondsSinceEpoch}';
  }

  try {
    final info = await deviceInfo.deviceInfo;
    final data = info.data;
    return data['id'] ??
        data['identifierForVendor'] ??
        data['deviceId'] ??
        'unknown_device';
  } catch (e) {
    return 'device_id_error';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cihazId = await cihazIDAl();
  final prefs = await SharedPreferences.getInstance();
  final kullaniciAdi =
      prefs.getString('kullaniciAdi') ?? 'kullanici_${cihazId.substring(0, 5)}';

  runApp(MyApp(deviceId: cihazId, kullaniciAdi: kullaniciAdi));
}

class MyApp extends StatelessWidget {
  final String deviceId;
  final String kullaniciAdi;

  const MyApp({required this.deviceId, required this.kullaniciAdi, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot Uygulaması',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: HomePage(deviceId: deviceId, kullaniciAdi: kullaniciAdi),
      routes: {
        '/sohbetGecmisi': (context) => const SohbetGecmisiSayfasi(deviceId: ''),
      },
    );
  }
}
