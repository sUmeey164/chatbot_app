// lib/chat_response.dart
class ChatResponse {
  final String? reply; // Backend'den gelen 'reply' alanı
  final String? base64Image; // Base64 kodlu görsel verisi

  ChatResponse({this.reply, this.base64Image});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      // API yanıtında 'reply' alanı varsa al, yoksa null
      reply: json['reply'] as String?,
      // API yanıtında 'base64Image' alanı varsa al, yoksa null
      base64Image: json['base64Image'] as String?,
    );
  }
}
