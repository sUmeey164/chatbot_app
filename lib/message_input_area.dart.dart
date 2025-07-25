// lib/message_input_area.dart // Renamed file
import 'package:flutter/material.dart';

class MessageInputArea extends StatelessWidget {
  // Renamed class
  final TextEditingController messageController; // Renamed mesajController
  final String? fileName; // Renamed dosyaAdi
  final VoidCallback onFileSelectionDialogOpen; // Renamed onDosyaSecimDialogAc
  final ValueChanged<String> onMessageSend; // Renamed onMesajGonder
  final ValueChanged<String> onFileNameUpdate; // Renamed onDosyaAdiGuncelle

  const MessageInputArea({
    Key? key,
    required this.messageController, // Renamed mesajController
    this.fileName, // Renamed dosyaAdi
    required this.onFileSelectionDialogOpen, // Renamed onDosyaSecimDialogAc
    required this.onMessageSend, // Renamed onMesajGonder
    required this.onFileNameUpdate, // Renamed onDosyaAdiGuncelle
    required void Function(String message)
    sendMessageAndGetResponse, // Renamed mesajGonderVeGetir
    required void Function()
    showFileSelectionDialog, // Renamed dosyaSecimDialogAc
    required Color Function() messageColor, // Renamed mesajRengi
  }) : super(key: key);

  Color _messageColor() {
    // Renamed _mesajRengi
    // You can get theme or color from outside here if you want.
    // But usually it can also be provided as a parameter from outside.
    return Colors.deepPurple; // Example fixed color
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fileName != null) // Renamed dosyaAdi
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName!, // Renamed dosyaAdi
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () {
                      onFileNameUpdate(''); // Renamed onDosyaAdiGuncelle
                    },
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController, // Renamed mesajController
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type a message...", // Translated string literal
                    hintStyle: TextStyle(
                      color: _messageColor().withOpacity(0.7),
                    ), // Renamed _mesajRengi
                    filled: true,
                    fillColor: _messageColor().withOpacity(
                      0.15,
                    ), // Renamed _mesajRengi
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.attach_file,
                        color: _messageColor(),
                      ), // Renamed _mesajRengi
                      onPressed:
                          onFileSelectionDialogOpen, // Renamed onDosyaSecimDialogAc
                    ),
                  ),
                  onSubmitted: onMessageSend, // Renamed onMesajGonder
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: _messageColor(),
                ), // Renamed _mesajRengi
                onPressed: () => onMessageSend(
                  messageController.text,
                ), // Renamed onMesajGonder, mesajController
              ),
            ],
          ),
        ],
      ),
    );
  }
}
