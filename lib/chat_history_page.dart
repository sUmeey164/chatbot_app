// lib/chat_history_page.dart // Renamed file
import 'package:flutter/material.dart';
import 'package:chatbot_app/history_manager.dart';
import 'package:chatbot_app/message.dart'; // Renamed from mesaj.dart
import 'package:chatbot_app/chat_session.dart'; // Renamed from SohbetOturumu.dart
import 'dart:io'; // Required for File class
import 'package:flutter/foundation.dart'
    show kIsWeb; // Add this import for kIsWeb

class ChatHistoryPage extends StatefulWidget {
  // Renamed class
  final String deviceId;
  final String? sessionId;

  const ChatHistoryPage({Key? key, required this.deviceId, this.sessionId})
    : super(key: key);

  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState(); // Renamed state class
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  // Renamed state class
  ChatSession? _currentSession; // Renamed SohbetOturumu
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.sessionId != null) {
      _currentSession = await HistoryManager.getSessionById(
        widget.sessionId!,
      ); // Renamed getOturumById
    } else {
      _currentSession = await HistoryManager.getSessionByDeviceId(
        // Renamed getOturumByDeviceId
        widget.deviceId,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Color getMessageColor(Message message) {
    // Renamed getMesajRengi, Mesaj
    if (message.isUser) {
      // Renamed kullanici to isUser
      return Colors.grey.shade800;
    }
    final model = message.model ?? 'Chatbot'; // Renamed mesaj.model
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
        title: Text(
          _currentSession?.title.isNotEmpty ==
                  true // Renamed baslik to title
              ? _currentSession!
                    .title // Renamed baslik to title
              : 'Chat History', // Translated string literal
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : _currentSession == null ||
                _currentSession!
                    .messages
                    .isEmpty // Renamed mesajlar to messages
          ? const Center(
              child: Text(
                'No messages found in this session.', // Translated string literal
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _currentSession!
                  .messages
                  .length, // Renamed mesajlar to messages
              itemBuilder: (context, index) {
                final message =
                    _currentSession!.messages[index]; // Renamed mesaj, messages
                return Align(
                  alignment:
                      message
                          .isUser // Renamed kullanici to isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: getMessageColor(
                        message,
                      ), // Renamed getMesajRengi, mesaj
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show if the generated image URL is available
                        if (message.imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                // Image.network used
                                message.imageUrl!,
                                width: 200, // Image size
                                height: 200, // Image size
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Text(
                                      'Image failed to load.', // Translated string literal
                                      style: TextStyle(color: Colors.white),
                                    ),
                              ),
                            ),
                          ),
                        // If user sent a local image path
                        if (message.filePath != null &&
                            message.fileType == 'image')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child:
                                  kIsWeb // Check if running on Web
                                  ? Image.network(
                                      // Use Image.network for Web
                                      message.filePath!,
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => const Text(
                                            'Image failed to load.', // Translated string literal
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                    )
                                  : Image.file(
                                      // Use Image.file for other platforms
                                      File(message.filePath!),
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => const Text(
                                            'Image failed to load.', // Translated string literal
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                    ),
                            ),
                          ),
                        // If there is a file, show its name and icon
                        if (message.filePath != null &&
                            message.fileType == 'file')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  color: Colors
                                      .white70, // Changed from Colors.black54 for consistency with other parts in this file
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    message.text.contains(
                                              '[File:',
                                            ) && // Renamed metin, string literal will change
                                            message.text.contains(
                                              ']',
                                            ) // Renamed metin
                                        ? message.text.substring(
                                            // Renamed metin
                                            message.text.indexOf('[File:') +
                                                8, // Renamed metin, string literal will change
                                            message.text.indexOf(
                                              ']',
                                            ), // Renamed metin
                                          )
                                        : message.text, // Renamed metin
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ), // Changed from Colors.black for consistency with other parts in this file
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (message.text.isNotEmpty) // Renamed metin
                          Text(
                            message.text, // Renamed metin
                            style: const TextStyle(
                              color: Colors.white,
                            ), // Changed from Colors.black for consistency with other parts in this file
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
