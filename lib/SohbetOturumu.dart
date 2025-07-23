import 'package:chatbot_app/mesaj.dart';

class SohbetOturumu {
  final String id;
  String baslik;
  final List<Mesaj> mesajlar;
  final String deviceId;
  String? model; // YENİ EKLENDİ: Oturumun hangi modelle başladığını tutar

  SohbetOturumu({
    required this.id,
    required this.baslik,
    required this.mesajlar,
    required this.deviceId,
    this.model, // Constructor'a ekledik
  });

  // JSON'dan SohbetOturumu nesnesi oluşturan factory metot
  factory SohbetOturumu.fromJson(Map<String, dynamic> json) {
    var mesajlarList = json['mesajlar'] as List;
    List<Mesaj> parsedMesajlar = mesajlarList
        .map((i) => Mesaj.fromJson(i))
        .toList();

    return SohbetOturumu(
      id: json['id'],
      baslik: json['baslik'],
      mesajlar: parsedMesajlar,
      deviceId: json['deviceId'],
      model: json['model'], // JSON'dan modeli oku
    );
  }

  // SohbetOturumu nesnesini JSON'a dönüştüren metot
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baslik': baslik,
      'mesajlar': mesajlar.map((mesaj) => mesaj.toJson()).toList(),
      'deviceId': deviceId,
      'model': model, // JSON'a modeli yaz
    };
  }
}
