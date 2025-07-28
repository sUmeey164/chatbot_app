import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chatbot_app/chat_response.dart'; // ChatResponse sınıfınızın yolu
import 'package:flutter/foundation.dart'; // debugPrint için gerekli

class ApiService {
  // ÖNEMLİ: Bu URL'yi güncel ngrok adresinizle değiştirin.
  // Postman'de doğru çalışan URL'nin baz kısmı olmalı.
  static const String _baseUrl =
      'https://5d7d414e5d47.ngrok-free.app/api'; // Burayı kendi API adresinizle değiştirin!

  static Future<ChatResponse> sendMessage(
    String message, {
    required String modelProvider,
    required String deviceId,
    required String sessionId,
    String? base64Image,
    bool isImageGeneration = false,
  }) async {
    final Map<String, dynamic> requestBody = {
      'message': message,
      'modelProvider': modelProvider,
      'deviceId': deviceId,
      'sessionId': sessionId,
    };

    if (base64Image != null && base64Image.isNotEmpty) {
      requestBody['image'] = base64Image;
    }

    if (isImageGeneration) {
      requestBody['is_image_generation'] = true;
    }

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'x-device-id': deviceId,
    };

    debugPrint('--- API Request Details ---');
    debugPrint('API Request URL: $_baseUrl/chat');
    debugPrint('API Request Headers: $headers');
    debugPrint('API Request Body: ${json.encode(requestBody)}');
    debugPrint('API Request Session ID: $sessionId');
    debugPrint('-------------------------');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: headers,
        body: json.encode(requestBody),
      );

      // Yanıtın durum kodunu ve ham gövdesini her zaman yazdırın
      debugPrint('--- API Response Details ---');
      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Raw Body: ${utf8.decode(response.bodyBytes)}');
      debugPrint('--------------------------');

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        return ChatResponse.fromJson(responseData);
      } else {
        // Hata durumunda da detaylı bilgi
        throw Exception(
          'API isteği başarısız oldu: ${response.statusCode} ${utf8.decode(response.bodyBytes)}',
        );
      }
    } catch (e) {
      // Ağ hatası veya JSON ayrıştırma hatası gibi durumlar
      debugPrint('API isteği gönderilirken genel hata oluştu: $e');
      throw Exception('API isteği gönderilirken hata oluştu: $e');
    }
  }
}
