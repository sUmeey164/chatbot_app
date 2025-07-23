// lib/history_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatbot_app/SohbetOturumu.dart';
import 'package:chatbot_app/mesaj.dart'; // Mesaj sınıfını da import et

class HistoryManager {
  static const String _sessionKeyPrefix = 'chat_session_';
  static const String _allSessionIdsKey = 'all_chat_session_ids';

  // Tüm oturumları döndüren metot
  static Future<List<SohbetOturumu>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final allSessionIds = prefs.getStringList(_allSessionIdsKey) ?? [];
    List<SohbetOturumu> sessions = [];

    for (String id in allSessionIds) {
      final jsonString = prefs.getString('$_sessionKeyPrefix$id');
      if (jsonString != null) {
        sessions.add(SohbetOturumu.fromJson(jsonDecode(jsonString)));
      }
    }
    // Opsiyonel: Oturumları en yeniye göre sırala
    sessions.sort((a, b) => b.id.compareTo(a.id));
    return sessions;
  }

  // Belirli bir oturumu ID'ye göre döndüren metot
  static Future<SohbetOturumu?> getOturumById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_sessionKeyPrefix$id');
    if (jsonString != null) {
      return SohbetOturumu.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  // Cihaz ID'sine göre en son oturumu döndüren metot
  static Future<SohbetOturumu?> getOturumByDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final allSessionIds = prefs.getStringList(_allSessionIdsKey) ?? [];
    SohbetOturumu? latestSession;

    for (String id in allSessionIds) {
      final jsonString = prefs.getString('$_sessionKeyPrefix$id');
      if (jsonString != null) {
        final session = SohbetOturumu.fromJson(jsonDecode(jsonString));
        if (session.deviceId == deviceId) {
          // En yeni oturumu bulmak için ID'leri karşılaştır (ID'ler genellikle timestamp'tir)
          if (latestSession == null ||
              int.parse(session.id) > int.parse(latestSession.id)) {
            latestSession = session;
          }
        }
      }
    }
    return latestSession;
  }

  // Oturumu kaydet veya güncelle
  static Future<void> saveSession(SohbetOturumu session) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(session.toJson());
    await prefs.setString('$_sessionKeyPrefix${session.id}', jsonString);

    // Oturum ID'sini tüm oturumların listesine ekle (eğer yoksa)
    final allSessionIds = prefs.getStringList(_allSessionIdsKey) ?? [];
    if (!allSessionIds.contains(session.id)) {
      allSessionIds.add(session.id);
      await prefs.setStringList(_allSessionIdsKey, allSessionIds);
    }
  }

  // Oturumu güncelle (Başlık gibi alanlar değiştiğinde kullanılabilir)
  static Future<void> updateSession(SohbetOturumu session) async {
    // saveSession zaten bir oturum varsa güncelleyecektir,
    // o yüzden ayrı bir updateSession metoduna gerek kalmayabilir.
    // Ancak daha açıklayıcı olması için bırakılabilir.
    await saveSession(session);
  }

  // Mesaj ekle ve oturumu kaydet
  static Future<void> addMessage(Mesaj mesaj, String sessionId) async {
    SohbetOturumu? session = await getOturumById(sessionId);
    if (session != null) {
      session.mesajlar.add(mesaj);
      await saveSession(session);
    }
  }

  // Oturumu sil
  static Future<void> deleteSession(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_sessionKeyPrefix$id');

    // Oturum ID'sini tüm oturumların listesinden çıkar
    final allSessionIds = prefs.getStringList(_allSessionIdsKey) ?? [];
    allSessionIds.remove(id);
    await prefs.setStringList(_allSessionIdsKey, allSessionIds);
  }

  // Tüm sohbet geçmişini temizle (Tüm oturumları siler)
  static Future<void> clearAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final allSessionIds = prefs.getStringList(_allSessionIdsKey) ?? [];

    for (String id in allSessionIds) {
      await prefs.remove('$_sessionKeyPrefix$id');
    }
    await prefs.remove(_allSessionIdsKey);
  }
}
