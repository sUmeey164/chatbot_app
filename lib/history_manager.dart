import 'dart:convert';
import 'package:chatbot_app/mesaj.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SohbetOturumu.dart';

class HistoryManager {
  static const String _keyPrefix = 'oturum_';

  static Future<void> saveSession(SohbetOturumu session) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${session.id}';
    final jsonData = jsonEncode(session.toJson());
    await prefs.setString(key, jsonData);
  }

  static Future<SohbetOturumu?> getSession(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$id';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return SohbetOturumu.fromJson(jsonDecode(jsonString));
  }

  static Future<void> deleteSession(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$id';
    await prefs.remove(key);
  }

  static Future<List<SohbetOturumu>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    List<SohbetOturumu> sessions = [];

    for (var key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          sessions.add(SohbetOturumu.fromJson(jsonDecode(jsonString)));
        } catch (e) {
          // Hata varsa görmezden gel
          print('Hata: $e');
        }
      }
    }
    return sessions;
  }

  static Future<void> updateSession(SohbetOturumu updatedSession) async {
    await saveSession(updatedSession);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (var key in keys) {
      await prefs.remove(key);
    }
  }

  static Future<void> addMessage(Mesaj mesaj, String sessionId) async {
    final session = await getSession(sessionId);
    if (session != null) {
      final updatedMessages = List<Mesaj>.from(session.mesajlar);
      updatedMessages.add(mesaj);

      final updatedSession = SohbetOturumu(
        id: session.id,
        baslik: session.baslik,
        mesajlar: updatedMessages,
        deviceId: session.deviceId,
      );

      await saveSession(updatedSession);
    } else {
      print("Session bulunamadı: $sessionId");
    }
  }

  static Future<SohbetOturumu?> getOturumByDeviceId(String deviceId) async {
    final sessions = await getAllSessions();
    try {
      return sessions.firstWhere((session) => session.deviceId == deviceId);
    } catch (e) {
      return null;
    }
  }

  // Buraya eklediğimiz getHistory metodu:
  static Future<List<Mesaj>> getHistory() async {
    final sessions = await getAllSessions();
    List<Mesaj> tumMesajlar = [];
    for (var session in sessions) {
      tumMesajlar.addAll(session.mesajlar);
    }
    return tumMesajlar;
  }
}
