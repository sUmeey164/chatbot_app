// lib/chat_sessions_page.dart // Renamed file
import 'package:flutter/material.dart';
import 'package:chatbot_app/history_manager.dart';
import 'package:chatbot_app/chat_session.dart'; // Renamed from SohbetOturumu.dart
import 'package:chatbot_app/chat_history_page.dart'; // Renamed from sohbet_gecmisi_sayfasi.dart

class ChatSessionsPage extends StatefulWidget {
  // Renamed class
  const ChatSessionsPage({Key? key}) : super(key: key);

  @override
  _ChatSessionsPageState createState() => // Renamed state class
      _ChatSessionsPageState(); // Renamed state class
}

class _ChatSessionsPageState extends State<ChatSessionsPage> {
  // Renamed state class
  List<ChatSession> _sessions = []; // Renamed ChatSession
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });
    final sessions = await HistoryManager.getAllSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  // Similar to the messageColor function in HomePage, used here to determine session color
  Color getSessionColor(String? model) {
    // Renamed getSessionColor
    switch (model) {
      case 'Gemini':
        return Colors.blue;
      case 'ChatGPT':
        return Colors.pink;
      case 'DeepSeek':
        return Colors.amber;
      case 'Chatbot':
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Chat Sessions', // Translated string literal
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : _sessions.isEmpty
          ? const Center(
              child: Text(
                'No chat sessions found yet.', // Translated string literal
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final sessionCardColor = getSessionColor(session.model);
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 4.0,
                  ),
                  color: sessionCardColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: sessionCardColor, width: 1.5),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.chat_bubble_outline,
                      color: sessionCardColor,
                    ),
                    title: Text(
                      session
                              .title
                              .isNotEmpty // Renamed baslik to title
                          ? session
                                .title // Renamed baslik to title
                          : 'Untitled Chat Session', // Translated string literal
                      style: TextStyle(
                        color: sessionCardColor, // Use color directly here
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${session.messages.length} messages - ${session.model ?? 'Unknown Model'}', // Renamed mesajlar, translated string literal
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade300),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'Delete Session', // Translated string literal
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to delete this chat session?', // Translated string literal
                              style: TextStyle(color: Colors.white70),
                            ),
                            backgroundColor: Colors.grey[850],
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text(
                                  'Cancel', // Translated string literal
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete', // Translated string literal
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await HistoryManager.deleteSession(session.id);
                          _loadSessions();
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatHistoryPage(
                            // Renamed SohbetGecmisiSayfasi
                            deviceId: session.deviceId,
                            sessionId: session
                                .id, // Send session ID to load a specific session
                          ),
                        ),
                      ).then((_) {
                        _loadSessions();
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
