// lib/API/api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chatbot_app/chat_response.dart'; // New class we created, already English

class ApiService {
  // Your API's base URL. Make sure the base URL always ends with a /
  static const String _baseUrl =
      'https://YOUR_NGROK_URL_HERE.ngrok-free.app/api/';

  // UPDATED: sendMessage method now returns ChatResponse and can receive Base64 image
  static Future<ChatResponse> sendMessage(
    // Renamed from mesajGonder
    String message, {
    required String model,
    required String deviceId,
    String? base64Image, // New: Base64 image data
  }) async {
    final url = Uri.parse('${_baseUrl}chat');
    try {
      final Map<String, dynamic> bodyData = {
        'sessionId': deviceId, // deviceId is used as Session ID
        'message': message,
        'model': model,
      };

      // Add Base64 image data to the body if available
      if (base64Image != null && base64Image.isNotEmpty) {
        bodyData['image_data'] = base64Image; // The key your backend expects!
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'x-device-id': deviceId},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        String? replyText;
        String? base64ImageResponse;

        if (data.containsKey('reply')) {
          replyText = data['reply'];
        }

        // IMPORTANT: Verify which JSON key your backend sends the Base64 data in.
        // For example, if your backend returns {"base64_image": "iVBORw0KGgoAAA..."} write 'base64_image'.
        // For example, if your backend returns {"image_data": "iVBORw0KGgoAAA..."} write 'image_data'.
        if (data.containsKey('base64_image')) {
          // Hypothetical key: Please change according to your backend!
          base64ImageResponse = data['base64_image'];
        }

        if (replyText == null && base64ImageResponse == null) {
          debugPrint(
            'Invalid response from server: "reply" or "base64_image" not found in response.',
          );
          throw Exception('Invalid response from server.');
        }

        return ChatResponse(
          replyText: replyText,
          base64Image: base64ImageResponse,
        );
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'API request failed: ${response.statusCode} - ${errorBody['message'] ?? response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw Exception('An error occurred while sending the message: $e');
    }
  }

  static Future<void> saveUser(String deviceId, String username) async {
    // Renamed kullaniciKaydet
    final url = Uri.parse('${_baseUrl}users');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deviceId': deviceId, 'username': username}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('User successfully saved/updated.');
      } else {
        final errorBody = jsonDecode(response.body);
        print(
          'Failed to save user: ${response.statusCode} - ${errorBody['message'] ?? response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  // generateImage method was removed as it's no longer used.
  // All operations will be done via sendMessage.
}
