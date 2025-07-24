// lib/mesaj.dart (or wherever your Mesaj class is defined)
class Mesaj {
  final bool kullanici;
  final String metin;
  final String? model;
  final String? filePath;
  final String? fileType;
  final String? imageUrl; // Bu alan bir resmin harici URL'si içindir
  final String? base64Image; // YENİ: Base64 verisi için bu alanı ekliyoruz

  Mesaj({
    required this.kullanici,
    required this.metin,
    this.model,
    this.filePath,
    this.fileType,
    this.imageUrl,
    this.base64Image, // Constructor'a ekledik
  });

  // fromJson ve toJson metodlarını da güncellediğinizden emin olun
  factory Mesaj.fromJson(Map<String, dynamic> json) {
    return Mesaj(
      kullanici: json['kullanici'],
      metin: json['metin'],
      model: json['model'],
      filePath: json['filePath'],
      fileType: json['fileType'],
      imageUrl: json['imageUrl'],
      base64Image: json['base64Image'], // fromJson'a ekledik
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kullanici': kullanici,
      'metin': metin,
      'model': model,
      'filePath': filePath,
      'fileType': fileType,
      'imageUrl': imageUrl,
      'base64Image': base64Image, // toJson'a ekledik
    };
  }
}
