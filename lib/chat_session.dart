// lib/chat_session.dart // Renamed file
import 'package:chatbot_app/message.dart'; // Renamed from mesaj.dart

class ChatSession {
  // Renamed class
  final String id;
  String title; // Renamed from baslik
  final List<Message> messages; // Renamed from mesajlar, Message
  final String deviceId;
  String? model; // NEW ADDED: Stores which model the session started with

  ChatSession({
    required this.id,
    required this.title, // Renamed baslik
    required this.messages, // Renamed mesajlar
    required this.deviceId,
    this.model, // Added to constructor
  });

  // Factory method to create a ChatSession object from JSON
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    // Renamed ChatSession
    var messagesList = json['messages'] as List; // Renamed mesajlar
    List<Message> parsedMessages =
        messagesList // Renamed Mesaj, parsedMesajlar
            .map((i) => Message.fromJson(i)) // Renamed Mesaj
            .toList();

    return ChatSession(
      // Renamed ChatSession
      id: json['id'],
      title: json['title'], // Renamed baslik
      messages: parsedMessages, // Renamed parsedMesajlar
      deviceId: json['deviceId'],
      model: json['model'], // Read model from JSON
    );
  }

  // Method to convert ChatSession object to JSON
  Map<String, dynamic> toJson() {
    // Renamed ChatSession
    return {
      'id': id,
      'title': title, // Renamed baslik
      'messages': messages
          .map((message) => message.toJson())
          .toList(), // Renamed mesajlar, message
      'deviceId': deviceId,
      'model': model, // Write model to JSON
    };
  }
}
