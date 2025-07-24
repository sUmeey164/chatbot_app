// lib/API/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      'https://07083806871b.ngrok-free.app/api'; // API'nızın temel URL'si

  static Future<String> mesajGonder(
    String message, {
    required String model,
    required String deviceId,
    String? dosya, // Dosya parametresi, eğer gönderilecekse kullanılacak
  }) async {
    final url = Uri.parse('$_baseUrl/chat');
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
          return 'Sunucudan geçersiz yanıt: Yanıt içinde "reply" bulunamadı.';
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'API isteği başarısız oldu: ${response.statusCode} - ${errorBody['message'] ?? response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Mesaj gönderme sırasında bir hata oluştu: $e');
    }
  }

  static Future<void> kullaniciKaydet(String deviceId, String username) async {
    final url = Uri.parse('$_baseUrl/users');
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

  // YENİ: Görsel oluşturma metodu
  static Future<String> generateImage(
    String prompt, {
    required String deviceId,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/generate_image',
    ); // Görsel oluşturma API'nızın endpoint'i
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
        if (data.containsKey('imageUrl')) {
          return data['imageUrl']; // API'nızın döndürdüğü görsel URL'si
        } else {
          throw Exception('API yanıtında imageUrl bulunamadı.');
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
