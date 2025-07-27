import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chatbot_app/chat_response.dart'; // ChatResponse sınıfınızın yolu

class ApiService {
  static const String _baseUrl =
      'YOUR_API_BASE_URL'; // Burayı kendi API adresinizle değiştirin

  static Future<ChatResponse> sendMessage(
    String message, {
    required String model,
    required String deviceId,
    String? base64Image,
    bool isImageGeneration = false, // Bu satırı ekleyin veya güncelleyin
  }) async {
    final Map<String, dynamic> requestBody = {
      'message': message,
      'model': model,
      'deviceId': deviceId,
    };

    if (base64Image != null && base64Image.isNotEmpty) {
      requestBody['image'] = base64Image;
    }

    // isImageGeneration parametresine göre API'ye farklı bir şekilde istek gönderme mantığı
    // Bu kısım, API'nizin görsel oluşturma isteklerini nasıl beklediğine bağlı olarak değişir.
    // Örnek olarak, ayrı bir endpoint veya farklı bir JSON yapısı olabilir.
    if (isImageGeneration) {
      // Görsel oluşturma için farklı bir endpoint veya özel bir yapı
      // Örneğin:
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/generate_image'), // Görsel oluşturma endpoint'i
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({'prompt': message, 'model': model, 'deviceId': deviceId}),
      // );
      // return ChatResponse.fromJson(json.decode(response.body));

      // Şimdilik aynı endpoint'e 'isImageGeneration' bayrağı ile gönderelim,
      // ancak API tarafında bu bayrağı işlediğinizden emin olun.
      requestBody['is_image_generation'] = true; // API'ye gönderilecek bayrak
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/chat'), // Genellikle sohbet için kullanılan endpoint
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      return ChatResponse.fromJson(responseData);
    } else {
      throw Exception(
        'API isteği başarısız oldu: ${response.statusCode} ${response.body}',
      );
    }
  }
}
