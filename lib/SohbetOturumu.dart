// TODO Implement this library.
import 'mesaj.dart'; // Mesaj sınıfının bulunduğu dosya yolunu kontrol et, gerekirse düzenle

class SohbetOturumu {
  final String id;
  final String baslik;
  final List<Mesaj> mesajlar;
  final String deviceId;

  SohbetOturumu({
    required this.id,
    required this.baslik,
    required this.mesajlar,
    required this.deviceId,
  });

  factory SohbetOturumu.fromJson(Map<String, dynamic> json) => SohbetOturumu(
    id: json['id'],
    baslik: json['baslik'],
    mesajlar: (json['mesajlar'] as List).map((m) => Mesaj.fromJson(m)).toList(),
    deviceId: json['deviceId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'baslik': baslik,
    'mesajlar': mesajlar.map((m) => m.toJson()).toList(),
    'deviceId': deviceId,
  };
}
