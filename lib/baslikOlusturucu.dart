// lib/baslik_olusturucu.dart

class BaslikOlusturucu {
  static String olustur(String ilkMesaj) {
    if (ilkMesaj.isEmpty) {
      return "Yeni Sohbet";
    }
    // İlk mesajın ilk 30 karakterini al ve boşlukları kırp
    String baslik = ilkMesaj.length > 30
        ? ilkMesaj.substring(0, 30) + '...'
        : ilkMesaj;
    return baslik.trim();
  }
}
