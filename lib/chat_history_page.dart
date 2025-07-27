// lib/chat_history_page.dart
import 'package:flutter/material.dart';
import 'package:chatbot_app/history_manager.dart';
import 'package:chatbot_app/message.dart';
import 'package:chatbot_app/chat_session.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatHistoryPage extends StatefulWidget {
  final String deviceId;
  final String? sessionId;

  const ChatHistoryPage({Key? key, required this.deviceId, this.sessionId})
    : super(key: key);

  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  ChatSession? _currentSession;
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

    // We now primarily rely on sessionId to load a specific chat history.
    // If sessionId is not provided, _currentSession will remain null,
    // and the page will display "No messages found".
    if (widget.sessionId != null) {
      _currentSession = await HistoryManager.getSessionById(widget.sessionId!);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Color getMessageColor(Message message) {
    if (message.isUser) {
      return Colors.grey.shade800;
    }
    final model = message.model ?? 'Chatbot';
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
          _currentSession?.title.isNotEmpty == true
              ? _currentSession!.title
              : 'Chat History',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : _currentSession == null || _currentSession!.messages.isEmpty
          ? const Center(
              child: Text(
                'No messages found in this session.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _currentSession!.messages.length,
              itemBuilder: (context, index) {
                final message = _currentSession!.messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: getMessageColor(message),
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
                                message.imageUrl!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Text(
                                      'Image failed to load.',
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
                              child: kIsWeb
                                  ? Image.network(
                                      message.filePath!,
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Text(
                                                'Image failed to load.',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                    )
                                  : Image.file(
                                      File(message.filePath!),
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Text(
                                                'Image failed to load.',
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
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    message.text.contains('[File:') &&
                                            message.text.contains(']')
                                        ? message.text.substring(
                                            message.text.indexOf('[File:') + 8,
                                            message.text.indexOf(']'),
                                          )
                                        : message.text,
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (message.text.isNotEmpty)
                          Text(
                            message.text,
                            style: const TextStyle(color: Colors.white),
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
