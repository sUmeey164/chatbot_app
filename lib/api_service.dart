// lib/API/api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart'; // debugPrint için
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      'https://3d3ebbfe839d.ngrok-free.app/api/'; // API'nızın temel URL'si base url sonunda muhakkak / ile bitmeli

  static Future<String> mesajGonder(
    String message, {
    required String model,
    required String deviceId,
    String? dosya, // Dosya parametresi, eğer gönderilecekse kullanılacak
  }) async {
    final url = Uri.parse('${_baseUrl}chat');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'x-device-id': deviceId},
        body: jsonEncode({
          'sessionId': deviceId, // Session ID olarak deviceId kullanılıyor
          'message': message,
          'model': model,
          // 'dosya': dosya, // Eğer dosya gönderme backend'de implemente edilirse burayı açın
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('reply')) {
          return data['reply'];
        } else {
          debugPrint(
            'Sunucudan geçersiz yanıt: Yanıt içinde "reply" bulunamadı.',
          );
          return 'Sunucudan geçersiz yanıt: Yanıt içinde "reply" bulunamadı.';
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'API isteği başarısız oldu: ${response.statusCode} - ${errorBody['message'] ?? response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('Mesaj gönderme sırasında hata: $e');
      throw Exception('Mesaj gönderme sırasında bir hata oluştu: $e');
    }
  }

  static Future<void> kullaniciKaydet(String deviceId, String username) async {
    final url = Uri.parse('${_baseUrl}users');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deviceId': deviceId, 'username': username}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Kullanıcı başarıyla kaydedildi/güncellendi.');
      } else {
        final errorBody = jsonDecode(response.body);
        print(
          'Kullanıcı kaydetme başarısız oldu: ${response.statusCode} - ${errorBody['message'] ?? response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Kullanıcı kaydetme sırasında hata: $e');
    }
  }

  // GÜNCEL: Görsel oluşturma metodu - Base64 verisi bekleniyor
  static Future<String> generateImage(
    String prompt, {
    required String deviceId,
  }) async {
    // BURADAKİ URL'NİN BACKEND'İNİZDEKİ GÖRSEL OLUŞTURMA ENDPOINT'İ İLE AYNI OLDUĞUNDAN EMİN OLUN
    final url = Uri.parse(
      '${_baseUrl}generate_image', // Bu kısım backend'inizdeki rota ile eşleşmeli (örn: /api/generate_image)
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'x-device-id': deviceId},
        body: jsonEncode({
          'prompt': prompt,
          'model': 'ImageGen', // Varsa görsel oluşturma için özel bir model adı
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // ÖNEMLİ: Backend'inizden gelen Base64 verisinin hangi JSON anahtarında olduğunu doğrulayın.
        // Örneğin backend'iniz {"base64_image": "iVBORw0KGgoAAA..."} dönüyorsa 'base64_image' yazın.
        // Örneğin backend'iniz {"image_data": "iVBORw0KGgoAAA..."} dönüyorsa 'image_data' yazın.
        // Eğer backend doğrudan ham Base64 string'i dönüyorsa (JSON içinde değil),
        // o zaman 'return response.body;' kullanmanız gerekirdi.
        if (data.containsKey('base64_image')) {
          // Varsayımsal anahtar: Lütfen backend'inize göre değiştirin!
          final String base64Image = data['base64_image'];
          if (base64Image.isEmpty) {
            throw Exception('API yanıtında boş Base64 görsel verisi alındı.');
          }
          return base64Image; // Base64 string'ini döndürüyoruz
        } else {
          throw Exception(
            'API yanıtında Base64 görsel verisi bulunamadı. Beklenen anahtar: "base64_image". Lütfen ApiService.dart dosyasını kontrol edin.',
          );
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Görsel oluşturma başarısız oldu: ${response.statusCode} - ${errorBody['message'] ?? response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Görsel oluşturma sırasında bir hata oluştu: $e');
    }
  }
}
