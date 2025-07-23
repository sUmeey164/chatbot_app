class BaslikOlusturucu {
  // Yaygın Türkçe kelimeleri (stop words) - bunları başlıktan çıkaracağız
  static const Set<String> _stopWords = {
    'bir',
    'bu',
    'şu',
    'o',
    've',
    'ile',
    'de',
    'da',
    'den',
    'dan',
    'için',
    'gibi',
    'kadar',
    'daha',
    'çok',
    'az',
    'ya',
    'yada',
    'veya',
    'ki',
    'ama',
    'ancak',
    'fakat',
    'lakin',
    'ne',
    'nasıl',
    'neden',
    'niçin',
    'niye',
    'ben',
    'sen',
    'biz',
    'siz',
    'onlar',
    'benim',
    'senin',
    'onun',
    'bizim',
    'sizin',
    'onların',
    'bana',
    'sana',
    'ona',
    'bize',
    'size',
    'onlara',
    'mı',
    'mi',
    'mu',
    'mü',
    'ın',
    'in',
    'un',
    'ün',
  };

  // Önemli anahtar kelimeler - bunlar varsa başlığa dahil et
  static const Map<String, String> _anahtarKelimeler = {
    'nasıl': 'Nasıl',
    'nedir': 'Nedir',
    'ne': 'Ne',
    'kim': 'Kim',
    'nerede': 'Nerede',
    'ne zaman': 'Ne Zaman',
    'hangi': 'Hangi',
    'kaç': 'Kaç',
    'kod': 'Kod',
    'program': 'Program',
    'uygulama': 'Uygulama',
    'yazılım': 'Yazılım',
    'flutter': 'Flutter',
    'dart': 'Dart',
    'chatbot': 'Chatbot',
    'bot': 'Bot',
    'sohbet': 'Sohbet',
    'mesaj': 'Mesaj',
    'yardım': 'Yardım',
    'problem': 'Problem',
    'hata': 'Hata',
    'çözüm': 'Çözüm',
    'öğren': 'Öğrenme',
    'anlat': 'Anlatım',
    'göster': 'Gösterim',
    'yap': 'Yapım',
    'oluştur': 'Oluşturma',
    'geliştir': 'Geliştirme',
  };

  /// İlk mesajdan otomatik başlık oluşturur
  static String otomatikBaslikOlustur(String ilkMesaj) {
    if (ilkMesaj.trim().isEmpty) {
      return "Yeni Sohbet";
    }

    // Mesajı temizle ve küçük harfe çevir
    String temizMesaj = ilkMesaj
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sçğıöşü]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (temizMesaj.isEmpty) {
      return "Yeni Sohbet";
    }

    // Kelimeleri ayır
    List<String> kelimeler = temizMesaj.split(' ');

    // Çok kısa mesajlar için direkt kullan
    if (kelimeler.length <= 3) {
      return _ilkHarfleriKapital(ilkMesaj.trim());
    }

    // Önemli kelimeleri bul
    List<String> onemliKelimeler = [];

    // Önce anahtar kelimeleri kontrol et
    for (var kelime in kelimeler) {
      if (_anahtarKelimeler.containsKey(kelime)) {
        onemliKelimeler.add(_anahtarKelimeler[kelime]!);
      }
    }

    // Anahtar kelime bulunamazsa, stop word olmayan kelimeleri al
    if (onemliKelimeler.isEmpty) {
      for (var kelime in kelimeler) {
        if (!_stopWords.contains(kelime) && kelime.length > 2) {
          onemliKelimeler.add(_ilkHarfiKapital(kelime));
        }
      }
    }

    // Başlık oluştur
    String baslik;
    if (onemliKelimeler.isEmpty) {
      // Hiç önemli kelime bulunamazsa ilk 3 kelimeyi al
      baslik = kelimeler.take(3).map(_ilkHarfiKapital).join(' ');
    } else {
      // En fazla 4 önemli kelime al
      baslik = onemliKelimeler.take(4).join(' ');
    }

    // Başlık çok uzunsa kısalt
    if (baslik.length > 30) {
      baslik = baslik.substring(0, 27) + '...';
    }

    return baslik.isEmpty ? "Yeni Sohbet" : baslik;
  }

  /// Konuya göre kategori belirler
  static String konuKategorisi(String mesaj) {
    String kucukMesaj = mesaj.toLowerCase();

    if (kucukMesaj.contains('kod') ||
        kucukMesaj.contains('program') ||
        kucukMesaj.contains('flutter') ||
        kucukMesaj.contains('dart')) {
      return '💻 Programlama';
    } else if (kucukMesaj.contains('yardım') || kucukMesaj.contains('nasıl')) {
      return '❓ Yardım';
    } else if (kucukMesaj.contains('öğren') || kucukMesaj.contains('anlat')) {
      return '📚 Öğrenme';
    } else if (kucukMesaj.contains('problem') || kucukMesaj.contains('hata')) {
      return '🔧 Problem';
    } else if (kucukMesaj.contains('sohbet') ||
        kucukMesaj.contains('merhaba')) {
      return '💬 Sohbet';
    }

    return '💭 Genel';
  }

  /// Kelimeyi başlık formatına çevirir (ilk harf büyük)
  static String _ilkHarfiKapital(String kelime) {
    if (kelime.isEmpty) return kelime;
    return kelime[0].toUpperCase() + kelime.substring(1);
  }

  /// Tüm kelimelerin ilk harfini büyük yapar
  static String _ilkHarfleriKapital(String metin) {
    return metin.split(' ').map((kelime) => _ilkHarfiKapital(kelime)).join(' ');
  }

  /// Başlığı günceller (yeni mesajlar eklendikçe çağrılabilir)
  static String basligiGuncelle(String mevcutBaslik, List<String> tumMesajlar) {
    // Eğer başlık hala "Yeni Sohbet" ise ve mesaj varsa güncelle
    if (mevcutBaslik == "Yeni Sohbet" && tumMesajlar.isNotEmpty) {
      return otomatikBaslikOlustur(tumMesajlar.first);
    }

    return mevcutBaslik;
  }
}
