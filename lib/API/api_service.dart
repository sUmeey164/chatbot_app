import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

Future<String> cihazIDAl() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return androidInfo.id;
}

class ApiService {
  static Future<String> mesajGonder(
    String mesaj, {
    required String model,
    required String deviceId,
    File? dosya,
  }) async {
    print('🔄 Endpointine istek gönderiliyor: $mesaj');

    String urlString = 'https://07083806871b.ngrok-free.app/api/chat';
    final url = Uri.parse(urlString);

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "x-device-id": deviceId, // BURAYA EKLENDİ
    };

    final body = jsonEncode({
      "sessionId": "flutter_session_01",
      "message": mesaj,
      "model": model,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'Yanıt alınamadı';
      } else {
        print('Sunucu cevabı: ${response.body}');
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      print("Hata oluştu: $e");
      throw Exception('Sunucuya bağlanılamadı.$e');
    }
  }

  static Future<void> kullaniciKaydet(String deviceId, String username) async {
    final url = Uri.parse('https://07083806871b.ngrok-free.app/api/chat');

    final headers = {
      'Content-Type': 'application/json',
      'x-device-id': deviceId, // burası kritik
    };

    final body = jsonEncode({"deviceId": deviceId, "username": username});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print(" Kullanıcı başarıyla kaydedildi.");
      } else {
        print(" Kullanıcı kaydı başarısız: ${response.statusCode}");
      }
    } catch (e) {
      print(" Kullanıcı kaydı hatası: $e");
    }
  }
}
