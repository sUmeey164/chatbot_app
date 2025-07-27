// lib/history_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatbot_app/chat_session.dart';
import 'package:chatbot_app/message.dart';

class HistoryManager {
  static const String _sessionKeyPrefix = 'chat_session_';
  static const String _allSessionIdsKey = 'all_chat_session_ids';

  // Method that returns all sessions
  static Future<List<ChatSession>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final allSessionIds = prefs.getStringList(_allSessionIdsKey) ?? [];
    List<ChatSession> sessions = [];

    for (String id in allSessionIds) {
      final jsonString = prefs.getString('$_sessionKeyPrefix$id');
      if (jsonString != null) {
        sessions.add(ChatSession.fromJson(jsonDecode(jsonString)));
      }
    }
    // Optional: Sort sessions by latest
    sessions.sort((a, b) => b.id.compareTo(a.id));
    return sessions;
  }

  // Method that returns a specific session by ID
  static Future<ChatSession?> getSessionById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_sessionKeyPrefix$id');
    if (jsonString != null) {
      return ChatSession.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  // Method that returns the latest session by Device ID AND Model
  static Future<ChatSession?> getSessionByDeviceIdAndModel(
    String deviceId,
    String model,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final allSessionIds = prefs.getStringList(_allSessionIdsKey) ?? [];
    ChatSession? latestSession;

    for (String id in allSessionIds) {
      final jsonString = prefs.getString('$_sessionKeyPrefix$id');
      if (jsonString != null) {
        final session = ChatSession.fromJson(jsonDecode(jsonString));
        // Check both deviceId and model
        if (session.deviceId == deviceId && session.model == model) {
          if (latestSession == null ||
              int.parse(session.id) > int.parse(latestSession.id)) {
            latestSession = session;
          }
        }
      }
    }
    return latestSession;
  }

  // Save or update session
  static Future<void> saveSession(ChatSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(session.toJson());
    await prefs.setString('$_sessionKeyPrefix${session.id}', jsonString);

    // Add session ID to the list of all sessions (if not already present)
    final allSessionIds = prefs.getStringList(_allSessionIdsKey) ?? [];
    if (!allSessionIds.contains(session.id)) {
      allSessionIds.add(session.id);
      await prefs.setStringList(_allSessionIdsKey, allSessionIds);
    }
  }

  // Update session (can be used when fields like title change)
  static Future<void> updateSession(ChatSession session) async {
    await saveSession(session);
  }

  // Add message and save session
  static Future<void> addMessage(Message message, String sessionId) async {
    ChatSession? session = await getSessionById(sessionId);
    if (session != null) {
      session.messages.add(message);
      await saveSession(session);
    }
  }

  // Delete session
  static Future<void> deleteSession(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_sessionKeyPrefix$id');

    // Remove session ID from the list of all sessions
    final allSessionIds = prefs.getStringList(_allSessionIdsKey) ?? [];
    allSessionIds.remove(id);
    await prefs.setStringList(_allSessionIdsKey, allSessionIds);
  }

  // Clear all chat history (Deletes all sessions)
  static Future<void> clearAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final allSessionIds = prefs.getStringList(_allSessionIdsKey) ?? [];

    for (String id in allSessionIds) {
      await prefs.remove('$_sessionKeyPrefix$id');
    }
    await prefs.remove(_allSessionIdsKey);
  }
}
