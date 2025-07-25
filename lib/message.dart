// lib/message.dart // Renamed file
class Message {
  // Renamed class
  final bool isUser; // Renamed from kullanici
  final String text; // Renamed from metin
  final String? model;
  final String? filePath;
  final String? fileType;
  final String? imageUrl; // This field is for an external URL of an image
  final String? base64Image; // NEW: We add this field for Base64 data

  Message({
    required this.isUser, // Renamed kullanici
    required this.text, // Renamed metin
    this.model,
    this.filePath,
    this.fileType,
    this.imageUrl,
    this.base64Image, // Added to constructor
  });

  // Make sure you have updated fromJson and toJson methods as well
  factory Message.fromJson(Map<String, dynamic> json) {
    // Renamed Mesaj
    return Message(
      // Renamed Mesaj
      isUser: json['isUser'], // Updated key
      text: json['text'], // Updated key
      model: json['model'],
      filePath: json['filePath'],
      fileType: json['fileType'],
      imageUrl: json['imageUrl'],
      base64Image: json['base64Image'], // Added to fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isUser': isUser, // Updated key
      'text': text, // Updated key
      'model': model,
      'filePath': filePath,
      'fileType': fileType,
      'imageUrl': imageUrl,
      'base64Image': base64Image, // Added to toJson
    };
  }
}
