import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// device_info_plus artık burada doğrudan kullanılmayacak, HomePage'de kullanılacak
// import 'package:device_info_plus/device_info_plus.dart'; // Bu satırı kaldırın
import 'package:shared_preferences/shared_preferences.dart'; // Kullanıcı adı için

import 'home_page.dart';
// SohbetGecmisiSayfasi route tanımı burada artık gerekli değil, HomePage'den navigasyon yapılıyor.
// import 'sohbet_gecmisi_sayfasi.dart'; // Bu satırı da kaldırabilirsiniz eğer sadece HomePage'den erişiliyorsa

// cihazIDAl() fonksiyonu artık main.dart'ta gerekli değil, HomePage'de hallediliyor.
/*
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
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // deviceId'yi burada almamıza gerek yok, HomePage kendi içinde halledecek.
  // final cihazId = await cihazIDAl(); // Bu satırı kaldırın

  final prefs = await SharedPreferences.getInstance();
  // Kullanıcı adını SharedPreferences'tan al. Eğer yoksa varsayılan bir değer atayabiliriz.
  // HomePage'deki _initializeChat metodu deviceId'yi kendi içinde belirleyeceği için,
  // kullaniciAdi için de geçici bir değer atayabiliriz veya null geçebiliriz.
  // HomePage'deki logic, null gelirse kendi deviceId'sine göre bir kullanıcı adı oluşturacaktır.
  final kullaniciAdi = prefs.getString(
    'kullaniciAdi',
  ); // Sadece kaydedilmiş kullanıcı adını al

  runApp(MyApp(kullaniciAdi: kullaniciAdi)); // deviceId parametresini kaldırın
}

class MyApp extends StatelessWidget {
  final String? kullaniciAdi; // Artık nullable olabilir

  // deviceId parametresini kurucudan kaldırın
  const MyApp({this.kullaniciAdi, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot Uygulaması',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      // HomePage'e sadece kullaniciAdi'nı geçin. deviceId'yi HomePage kendi içinde yönetecek.
      // HomePage'in kurucusunda deviceId required olduğu için şimdilik boş bir string geçeceğiz.
      // HomePage'deki _initializeChat metodu bunu ezecektir.
      home: HomePage(kullaniciAdi: kullaniciAdi, deviceId: ''),
      // SohbetGecmisiSayfasi'na yönlendirme artık HomePage'den MaterialPageRoute ile yapılıyor.
      // Bu route tanımı burada gereksiz ve yanlış deviceId geçişine neden olabilir.
      // routes: {
      //   '/sohbetGecmisi': (context) => const SohbetGecmisiSayfasi(deviceId: ''),
      // },
    );
  }
}
