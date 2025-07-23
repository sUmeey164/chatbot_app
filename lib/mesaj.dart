class Mesaj {
  final String metin;
  final bool kullanici;
  final String? model;

  Mesaj({
    required this.metin,
    required this.kullanici,
    this.model,
    String? dosyaYolu,
  });

  // JSON'dan Mesaj objesi oluşturma
  factory Mesaj.fromJson(Map<String, dynamic> json) {
    return Mesaj(
      metin: json['metin'] as String,
      kullanici: json['kullanici'] as bool,
      model: json['model'] ?? 'Chatbot',
    );
  }

  // Mesaj objesini JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {'metin': metin, 'kullanici': kullanici, 'model': model};
  }
}
