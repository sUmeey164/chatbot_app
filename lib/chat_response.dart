// lib/chat_response.dart
class ChatResponse {
  final String? replyText; // Yanıt metni
  final String? base64Image; // Oluşturulan görselin Base64 verisi

  ChatResponse({this.replyText, this.base64Image});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      // API'den gelen JSON anahtarlarının doğru olduğundan emin olun
      // Örneğin, API 'text' yerine 'response_text' veya 'answer' gönderiyor olabilir.
      replyText:
          json['reply_text']
              as String?, // API yanıtındaki anahtara göre düzeltin
      base64Image:
          json['base64_image']
              as String?, // API yanıtındaki anahtara göre düzeltin
    );
  }

  Map<String, dynamic> toJson() {
    return {'reply_text': replyText, 'base64_image': base64Image};
  }
}
