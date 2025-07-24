// lib/mesaj.dart
class Mesaj {
  final bool kullanici;
  final String metin;
  final String model; // Hangi modelin konuştuğu bilgisini tutar
  final String? filePath; // Kullanıcının gönderdiği dosyanın/görselin yolu
  final String?
  fileType; // Kullanıcının gönderdiği dosyanın/görselin tipi ('image', 'file')
  final String?
  imageUrl; // YENİ: Yapay zeka tarafından oluşturulan görselin URL'si

  Mesaj({
    required this.kullanici,
    required this.metin,
    required this.model,
    this.filePath,
    this.fileType,
    this.imageUrl, // YENİ: Buraya da ekleyin
  });

  // Factory metodu veya fromJson metodu varsa onu da imageUrl ile güncelleyin
  factory Mesaj.fromJson(Map<String, dynamic> json) {
    return Mesaj(
      kullanici: json['kullanici'] as bool,
      metin: json['metin'] as String,
      model: json['model'] as String,
      filePath: json['filePath'] as String?,
      fileType: json['fileType'] as String?,
      imageUrl: json['imageUrl'] as String?, // YENİ: Burada da ekleyin
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kullanici': kullanici,
      'metin': metin,
      'model': model,
      'filePath': filePath,
      'fileType': fileType,
      'imageUrl': imageUrl, // YENİ: Burada da ekleyin
    };
  }
}
