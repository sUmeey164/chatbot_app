import 'dart:io'; // Platform.isIOS, Platform.isAndroid vb. için

class Mesaj {
  final String metin;
  final bool kullanici; // true ise kullanıcı mesajı, false ise bot mesajı
  final String? model; // Hangi modelden geldiği bilgisi
  final String?
  filePath; // YENİ: Gönderilen dosyanın yolu (resim veya başka bir dosya)
  String? fileType; // YENİ: Dosya türü (e.g., 'image', 'file')

  Mesaj({
    required this.metin,
    required this.kullanici,
    this.model,
    this.filePath, // Constructor'a eklendi
    this.fileType, // Constructor'a eklendi
  });

  factory Mesaj.fromJson(Map<String, dynamic> json) {
    return Mesaj(
      metin: json['metin'] as String,
      kullanici: json['kullanici'] as bool,
      model: json['model'] as String?,
      filePath: json['filePath'] as String?, // JSON'dan oku
      fileType: json['fileType'] as String?, // JSON'dan oku
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metin': metin,
      'kullanici': kullanici,
      'model': model,
      'filePath': filePath, // JSON'a yaz
      'fileType': fileType, // JSON'a yaz
    };
  }
}
