// lib/chat_screen.dart // Renamed file
import 'package:flutter/material.dart';
import 'package:chatbot_app/chat_session.dart'; // Corrected import (renamed from SohbetOturumu.dart)
import 'package:chatbot_app/history_manager.dart'; // Corrected import
import 'package:chatbot_app/message.dart'; // Corrected import (renamed from mesaj.dart)
import 'dart:io'; // Required for File class

class ChatScreen extends StatefulWidget {
  // Renamed class
  final ChatSession session; // Renamed ChatSession

  const ChatScreen({
    Key? key,
    required this.session, // Only this parameter is sufficient
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState(); // Renamed state class
}

class _ChatScreenState extends State<ChatScreen> {
  // Renamed state class
  late List<Message> _messages; // Renamed _mesajlar, Message
  final TextEditingController _messageController =
      TextEditingController(); // Renamed _mesajController

  @override
  void initState() {
    super.initState();
    _messages = List.from(
      widget.session.messages,
    ); // Renamed _mesajlar, messages
  }

  // A simple function to determine message colors
  Color _getMessageColor(Message message) {
    // Renamed _getMesajRengi, Message
    if (message.isUser) {
      // Renamed kullanici to isUser
      return Colors.blue[200]!;
    }
    switch (message.model) {
      // Renamed mesaj.model
      case 'Gemini':
        return Colors.blue.shade100;
      case 'ChatGPT':
        return Colors.pink.shade100;
      case 'DeepSeek':
        return Colors.amber.shade100;
      case 'Chatbot':
      default:
        return Colors.grey[300]!;
    }
  }

  void _sendMessage() async {
    // Renamed _mesajGonder
    final text = _messageController.text
        .trim(); // Renamed metin, _mesajController
    if (text.isEmpty) return;

    final userModel = widget.session.model ?? 'Chatbot'; // Null check performed

    setState(() {
      _messages.add(
        Message(text: text, isUser: true, model: userModel),
      ); // Renamed Mesaj, metin, kullanici, text, isUser
    });
    _messageController.clear(); // Renamed _mesajController

    final botResponse =
        "Bot response: $text"; // Simulated bot response // Renamed botCevabi, translated string literal

    setState(() {
      _messages.add(
        Message(
          text: botResponse,
          isUser: false,
          model: userModel,
        ), // Renamed Mesaj, metin, kullanici, text, isUser
      );
    });

    final updatedSession = ChatSession(
      // Renamed SohbetOturumu
      id: widget.session.id,
      title: widget.session.title, // Renamed baslik to title
      messages: _messages, // Renamed mesajlar to messages
      deviceId: widget.session.deviceId, // Correct deviceId usage
      model: widget.session.model, // Correct model usage
    );

    await HistoryManager.updateSession(updatedSession);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.session.title, // Renamed baslik to title
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length, // Renamed _mesajlar
              itemBuilder: (context, index) {
                final message = _messages[index]; // Renamed mesaj, _mesajlar
                return Align(
                  alignment:
                      message
                          .isUser // Renamed kullanici
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: _getMessageColor(
                        message,
                      ), // Renamed _getMesajRengi, mesaj
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NEW: Show if the generated image URL is available
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
                                      'Image failed to load.', // Translated string literal
                                      style: TextStyle(color: Colors.black),
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
                              child: Image.file(
                                File(message.filePath!),
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Text(
                                      'Image failed to load.', // Translated string literal
                                      style: TextStyle(color: Colors.black),
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
                                  color: Colors.black54,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    message.text.contains(
                                              '[Dosya:',
                                            ) && // Renamed metin, string literal will change
                                            message.text.contains(
                                              ']',
                                            ) // Renamed metin
                                        ? message.text.substring(
                                            // Renamed metin
                                            message.text.indexOf('[Dosya:') +
                                                8, // Renamed metin, string literal will change
                                            message.text.indexOf(
                                              ']',
                                            ), // Renamed metin
                                          )
                                        : message.text, // Renamed metin
                                    style: const TextStyle(color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (message.text.isNotEmpty) // Renamed metin
                          Text(
                            message.text, // Renamed metin
                            style: const TextStyle(color: Colors.black),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController, // Renamed _mesajController
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                          'Type a message...', // Translated string literal
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (value) =>
                        _sendMessage(), // Renamed _mesajGonder
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
                  onPressed: _sendMessage, // Renamed _mesajGonder
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
