// lib/API/api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chatbot_app/chat_response.dart'; // Yeni oluşturduğumuz sınıfı import et

class ApiService {
  static const String _baseUrl =
      'https://3d3ebbfe839d.ngrok-free.app/api/'; // API'nızın temel URL'si base url sonunda muhakkak / ile bitmeli

  // GÜNCELLENMİŞ: mesajGonder metodu artık ChatResponse döndürüyor
  static Future<ChatResponse> mesajGonder(
    // Dönüş tipi değişti
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
        String? replyText;
        String? base64Image;

        if (data.containsKey('reply')) {
          replyText = data['reply'];
        }

        // ÖNEMLİ: Backend'inizden gelen Base64 verisinin hangi JSON anahtarında olduğunu doğrulayın.
        // Örneğin backend'iniz {"base64_image": "iVBORw0KGgoAAA..."} dönüyorsa 'base64_image' yazın.
        // Örneğin backend'iniz {"image_data": "iVBORw0KGgoAAA..."} dönüyorsa 'image_data' yazın.
        if (data.containsKey('base64_image')) {
          // Varsayımsal anahtar: Lütfen backend'inize göre değiştirin!
          base64Image = data['base64_image'];
        }

        if (replyText == null && base64Image == null) {
          debugPrint(
            'Sunucudan geçersiz yanıt: Yanıt içinde "reply" veya "base64_image" bulunamadı.',
          );
          throw Exception('Sunucudan geçersiz yanıt.');
        }

        return ChatResponse(replyText: replyText, base64Image: base64Image);
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

  // generateImage metodu artık kullanılmadığı için kaldırıldı.
  // Tüm işlemler mesajGonder üzerinden yapılacak.
}
