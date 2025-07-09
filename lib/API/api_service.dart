import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<String> mesajGonder(String mesaj) async {
    final url = Uri.parse('http://192.168.1.15:3000/api/chat');

    final headers = {"Content-Type": "application/json"};

    final body = jsonEncode({"message": mesaj});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['cevap'] ?? 'Yanıt alınamadı';
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      print("Hata oluştu: $e"); // Buraya ekledik
      throw Exception('Sunucuya bağlanılamadı.');
    }
  }
}
