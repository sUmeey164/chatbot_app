// lib/home_page.dart
import 'package:chatbot_app/chat_sessions_page.dart'; // Renamed from sobet_oturumlari_sayfasi.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io'; // Required for File class
import 'dart:convert'; // Required for base64Decode!
import 'dart:typed_data'; // Required for Uint8List

// Your custom classes should be imported using package:your_app_name/path_to_file.dart
import 'api_service.dart';
import 'package:chatbot_app/title_generator.dart'; // Renamed from baslikOlusturucu.dart
import 'package:chatbot_app/history_manager.dart';
import 'package:chatbot_app/message.dart'; // Renamed from mesaj.dart
import 'package:chatbot_app/chat_history_page.dart'; // Renamed from sohbet_gecmisi_sayfasi.dart (commented out in original)
import 'package:chatbot_app/chat_session.dart'; // Renamed from SohbetOturumu.dart
import 'package:chatbot_app/chat_response.dart'; // New class, already English

final ImagePicker _picker = ImagePicker();

class HomePage extends StatefulWidget {
  final String? userName; // Renamed from kullaniciAdi
  final String deviceId;

  const HomePage({Key? key, this.userName, required this.deviceId})
    : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChatSession? _currentSession; // Renamed from SohbetOturumu
  late String _deviceId;
  late String _username; // Renamed from _kullaniciAdi
  bool _isLoading = true;

  final List<Message> _messages = []; // Renamed from Mesaj
  final TextEditingController _messageController =
      TextEditingController(); // Renamed from _mesajController
  String _selectedModel = 'Chatbot';
  bool _chatStarted = false;

  String? _selectedFilePath;
  String? _selectedFileName;
  String? _selectedFileType; // 'image', 'file', null
  Uint8List? _selectedFileBytes; // Selected file's bytes
  bool _showCloseButton = false; // For close button visibility

  bool _isChatInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isChatInitialized) {
      _initializeChat();
      _isChatInitialized = true;
    }
  }

  Future<void> _initializeChat() async {
    setState(() {
      _isLoading = true;
    });

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      _deviceId = 'web_user_${DateTime.now().millisecondsSinceEpoch}';
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _deviceId = androidInfo.id;
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor!;
    } else {
      _deviceId = 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }

    _username = widget.userName ?? 'user_${_deviceId.substring(0, 8)}';

    _currentSession = await HistoryManager.getSessionByDeviceId(_deviceId);

    if (_currentSession == null) {
      _currentSession = ChatSession(
        // Renamed SohbetOturumu
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '', // Renamed from baslik
        messages: [], // Renamed from mesajlar
        deviceId: _deviceId,
        model: _selectedModel,
      );
      await HistoryManager.saveSession(_currentSession!);
    } else {
      setState(() {
        _selectedModel = _currentSession!.model ?? 'Chatbot';
      });
    }

    if (_currentSession!.messages.isNotEmpty) {
      // Renamed messages
      setState(() {
        _messages.clear();
        _messages.addAll(_currentSession!.messages); // Renamed messages
        _chatStarted = true;
      });
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

    final model = message.model;
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

  IconData getModelIcon(String model) {
    switch (model) {
      case 'Chatbot':
        return Icons.smart_toy;
      case 'ChatGPT':
        return Icons.chat_bubble_outline;
      case 'Gemini':
        return Icons.auto_awesome;
      case 'DeepSeek':
        return Icons.search;
      default:
        return Icons.smart_toy;
    }
  }

  void changeModel(String newModel) async {
    // Renamed modelDegistir
    if (_currentSession != null && _currentSession!.messages.isNotEmpty) {
      // Renamed messages
      _currentSession!.model = _selectedModel;
      await HistoryManager.saveSession(_currentSession!);
    }

    _currentSession = ChatSession(
      // Renamed SohbetOturumu
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '', // Renamed baslik
      messages: [], // Renamed mesajlar
      deviceId: _deviceId,
      model: newModel,
    );
    await HistoryManager.saveSession(_currentSession!);

    setState(() {
      _selectedModel = newModel;
      _messages.clear();
      _chatStarted = false;
    });
  }

  Color messageColor() {
    // Renamed mesajRengi
    switch (_selectedModel) {
      case 'ChatGPT':
        return Colors.pink;
      case 'Gemini':
        return Colors.blue;
      case 'DeepSeek':
        return Colors.amber;
      case 'Chatbot':
      default:
        return Colors.deepPurple;
    }
  }

  Widget _modelSelectionCard(String modelName, IconData icon, Color color) {
    // Renamed _modelSecimCard, modelAdi, ikon, renk
    return GestureDetector(
      onTap: () {
        changeModel(modelName); // Renamed modelDegistir
        Navigator.pop(context);
      },
      child: Card(
        color: color.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Text(
                modelName,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UPDATED: sendMessageAndGetResponse method - Can process both text and image responses
  void sendMessageAndGetResponse(String message) async {
    // Renamed mesajGonderVeGetir, mesaj
    if (message.trim().isEmpty && _selectedFilePath == null) return;

    if (!_chatStarted) {
      setState(() {
        _chatStarted = true;
      });
    }

    String textToSend = message.trim(); // Renamed gonderilecekMetin
    String? filePathToSend = _selectedFilePath; // Renamed gonderilecekFilePath
    String? fileTypeToSend = _selectedFileType; // Renamed gonderilecekFileType
    String? base64ImageData; // New: Base64 image data

    // If an image file is selected, convert it to Base64
    if (filePathToSend != null && fileTypeToSend == 'image') {
      try {
        if (kIsWeb && _selectedFileBytes != null) {
          // For web, use bytes directly from memory
          base64ImageData = base64Encode(_selectedFileBytes!);
          debugPrint(
            'Selected image (Web) converted to Base64. Length: ${base64ImageData.length}',
          );
        } else if (!kIsWeb) {
          // For Mobile/Desktop, read from file
          final file = File(filePathToSend);
          final bytes = await file.readAsBytes();
          base64ImageData = base64Encode(bytes);
          debugPrint(
            'Selected image (Mobile/Desktop) converted to Base64. Length: ${base64ImageData.length}',
          );
        }
      } catch (e) {
        debugPrint(
          'Error converting image to Base64: $e',
        ); // Renamed error message
        // If error, don't try to send the image
        base64ImageData = null;
      }
    }

    if (filePathToSend != null) {
      if (fileTypeToSend == 'file' && textToSend.isEmpty) {
        textToSend =
            '[Dosya: ${_selectedFileName ?? 'Seçili Dosya'}]'; // Kept Turkish
      }
    }

    final userMessage = Message(
      // Renamed Mesaj
      isUser: true, // Renamed kullanici to isUser
      text: textToSend, // Renamed metin to text
      model: _selectedModel,
      filePath: filePathToSend,
      fileType: fileTypeToSend,
    );

    setState(() {
      _messages.add(userMessage);
      _selectedFileName = null;
      _selectedFilePath = null;
      _selectedFileType = null;
      _selectedFileBytes = null; // Clear selected bytes too
      _showCloseButton = false; // Hide X button when message is sent
    });

    _messageController.clear(); // Renamed _mesajController

    if (_currentSession != null &&
        _currentSession!.title.isEmpty && // Renamed baslik to title
        userMessage.text.isNotEmpty) {
      // Renamed text
      _currentSession!.title = TitleGenerator.generate(
        userMessage.text,
      ); // Renamed BaslikOlusturucu.olustur
      await HistoryManager.updateSession(_currentSession!);
    } else if (_currentSession != null &&
        _currentSession!.title.isEmpty && // Renamed baslik to title
        userMessage.filePath != null) {
      _currentSession!.title = userMessage.fileType == 'image'
          ? 'Resimli Sohbet' // Kept Turkish
          : 'Dosyalı Sohbet'; // Kept Turkish
      await HistoryManager.updateSession(_currentSession!);
    }

    await HistoryManager.addMessage(userMessage, _currentSession!.id);

    try {
      // Get ChatResponse object from API
      final ChatResponse apiResponse = await ApiService.sendMessage(
        // Renamed ApiService.mesajGonder
        textToSend,
        model: _selectedModel,
        deviceId: _deviceId,
        base64Image: base64ImageData, // Send Base64 image data
      );

      // Add text response if available
      if (apiResponse.replyText != null && apiResponse.replyText!.isNotEmpty) {
        final botMessage = Message(
          // Renamed Mesaj
          text: apiResponse.replyText!, // Renamed text
          isUser: false, // Renamed isUser
          model: _selectedModel,
        );
        setState(() {
          _messages.add(botMessage);
        });
        await HistoryManager.addMessage(botMessage, _currentSession!.id);
      }

      // Add Base64 image if available
      if (apiResponse.base64Image != null &&
          apiResponse.base64Image!.isNotEmpty) {
        debugPrint(
          'Base64 image data received. Length: ${apiResponse.base64Image!.length}',
        );
        final botImageMessage = Message(
          // Renamed Mesaj
          isUser: false, // Renamed isUser
          text: 'İşte oluşturduğum görsel:', // Kept Turkish
          model: _selectedModel,
          base64Image:
              apiResponse.base64Image!, // Save Base64 image to Message object
        );
        setState(() {
          _messages.add(botImageMessage);
        });
        await HistoryManager.addMessage(botImageMessage, _currentSession!.id);
      } else {
        debugPrint('Base64 image data not found or empty in API response.');
      }

      // If neither text nor image is received, show an error message
      if (apiResponse.replyText == null && apiResponse.base64Image == null) {
        setState(() {
          _messages.add(
            Message(
              // Renamed Mesaj
              text: 'Sunucudan geçerli bir yanıt alınamadı.', // Kept Turkish
              isUser: false, // Renamed isUser
              model: _selectedModel,
            ),
          );
        });
        await HistoryManager.addMessage(
          Message(
            // Renamed Mesaj
            text: 'Sunucudan geçerli bir yanıt alınamadı.', // Kept Turkish
            isUser: false, // Renamed isUser
            model: _selectedModel,
          ),
          _currentSession!.id,
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e'); // Print error details to console
      setState(() {
        _messages.add(
          Message(
            // Renamed Mesaj
            text:
                'Sunucuya bağlanılamadı veya bir hata oluştu: $e', // Kept Turkish
            isUser: false, // Renamed isUser
            model: _selectedModel,
          ),
        );
      });
      await HistoryManager.addMessage(
        Message(
          // Renamed Mesaj
          text:
              'Sunucuya bağlanılamadı veya bir hata oluştu: $e', // Kept Turkish
          isUser: false, // Renamed isUser
          model: _selectedModel,
        ),
        _currentSession!.id,
      );
    }
  }

  void pickImageFromCamera() async {
    // Renamed kameraIleCek
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
    ); // Renamed foto
    if (photo != null) {
      setState(() {
        _selectedFilePath = photo.path;
        _selectedFileName = photo.name;
        _selectedFileType = 'image';
        if (kIsWeb) {
          // For web, get bytes directly from XFile and use for preview
          photo.readAsBytes().then((bytes) {
            setState(() {
              _selectedFileBytes = bytes;
            });
          });
        }
      });
    }
  }

  void pickImageFromGallery() async {
    // Renamed galeridenSec
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
    ); // Renamed foto
    if (photo != null) {
      setState(() {
        _selectedFilePath = photo.path;
        _selectedFileName = photo.name;
        _selectedFileType = 'image';
        if (kIsWeb) {
          // For web, get bytes directly from XFile and use for preview
          photo.readAsBytes().then((bytes) {
            setState(() {
              _selectedFileBytes = bytes;
            });
          });
        }
      });
    }
  }

  void pickFile() async {
    // Renamed dosyaSec
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      String fileName = result.files.single.name; // Renamed dosyaAdi
      String filePath = result.files.single.path!; // Renamed dosyaYolu
      Uint8List? fileBytes = result.files.single.bytes; // For web, bytes

      setState(() {
        _selectedFilePath = filePath;
        _selectedFileName = fileName;
        _selectedFileType = 'file';
        _selectedFileBytes = fileBytes; // Save bytes for web
      });
    }
  }

  void _showFileSelectionDialog() {
    // Renamed _dosyaSecimDialog
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionColumn(Icons.image, 'Galeri', () {
                    // Kept Turkish
                    Navigator.pop(context);
                    pickImageFromGallery(); // Renamed galeridenSec
                  }),
                  _buildActionColumn(Icons.camera_alt, 'Kamera', () {
                    // Kept Turkish
                    Navigator.pop(context);
                    pickImageFromCamera(); // Renamed kameraIleCek
                  }),
                  _buildActionColumn(Icons.insert_drive_file, 'Dosya', () {
                    // Kept Turkish
                    Navigator.pop(context);
                    pickFile(); // Renamed dosyaSec
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionColumn(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, size: 28, color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String text) {
    // Renamed _chip, yazi
    return ActionChip(
      label: Text(text), // Renamed yazi
      backgroundColor: messageColor().withOpacity(0.7),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14, // Set font size
        height:
            0.9, // Try this value (e.g., 0.8, 0.9, 1.0) to vertically center the text
        leadingDistribution: TextLeadingDistribution
            .even, // Distribute line spacing evenly top and bottom
      ),
      onPressed: () => sendMessageAndGetResponse(text),
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ), // Adjusted ActionChip's general padding a bit
    );
  }

  // UPDATED: Image generation method - Now directly calls sendMessageAndGetResponse
  void _generateImageFromPrompt(String prompt) async {
    // We send the image generation request directly to the sendMessageAndGetResponse method.
    // The backend should detect this prompt and return an image.
    sendMessageAndGetResponse('Görsel oluştur: "$prompt"'); // Kept Turkish
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: messageColor(),
        elevation: 0,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.grey,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _modelSelectionCard(
                          "Chatbot",
                          Icons.smart_toy,
                          Colors.deepPurple,
                        ),
                        const SizedBox(height: 10),
                        _modelSelectionCard(
                          "ChatGPT",
                          Icons.chat_bubble_outline,
                          Colors.pink,
                        ),
                        const SizedBox(height: 10),
                        _modelSelectionCard(
                          "Gemini",
                          Icons.auto_awesome,
                          Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        _modelSelectionCard(
                          "DeepSeek",
                          Icons.search,
                          Colors.amber,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: SizedBox(
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    getModelIcon(_selectedModel),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          _selectedModel,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ChatSessionsPage(), // Renamed SohbetOturumlariSayfasi
                ),
              ).then((_) {
                _initializeChat();
              });
            },
            tooltip: 'Sohbet Oturumları', // Kept Turkish
          ),
          /* COMMENTED OUT: Chat History button removed.
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatHistoryPage(deviceId: _deviceId), // Renamed SohbetGecmisiSayfasi
                ),
              ).then((_) {
                _initializeChat();
              });
            },
            tooltip: 'Bu Sohbetin Geçmişi', // Kept Turkish
          ),
          */
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: messageColor()))
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];

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
                                // Show Base64 image if available
                                if (message.base64Image != null &&
                                    message.base64Image!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.memory(
                                        // Fix: .split(',').last removed as prefix is not expected from backend.
                                        base64Decode(message.base64Image!),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          debugPrint(
                                            'Failed to load Base64 image: $error',
                                          );
                                          return const Text(
                                            'Görsel yüklenemedi (Base64).', // Kept Turkish
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                // Show external URL if available (current code)
                                // Note: This part might not be used currently as your backend returns base64.
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
                                        errorBuilder: (context, error, stackTrace) {
                                          debugPrint(
                                            'Failed to load URL image: $error',
                                          );
                                          return const Text(
                                            'Görsel yüklenemedi (URL).', // Kept Turkish
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          );
                                        },
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
                                          kIsWeb &&
                                              message.filePath!.startsWith(
                                                'blob:',
                                              ) // If web and it's a blob URL, try MemoryImage
                                          ? (_selectedFileBytes !=
                                                    null // If bytes are still in memory
                                                ? Image.memory(
                                                    _selectedFileBytes!,
                                                    width: 200,
                                                    height: 200,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    // Otherwise, try NetworkImage (for blob URLs)
                                                    message.filePath!,
                                                    width: 200,
                                                    height: 200,
                                                    fit: BoxFit.cover,
                                                  ))
                                          : Image.file(
                                              // For other platforms (and web if not blob), use Image.file (might need adjustment for web to NetworkImage if _selectedFileBytes is not retained in Mesaj)
                                              File(message.filePath!),
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    debugPrint(
                                                      'Failed to load local image (Mobile/Desktop): $error',
                                                    );
                                                    return const Text(
                                                      'Görsel yüklenemedi.', // Kept Turkish
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    );
                                                  },
                                            ),
                                    ),
                                  ),
                                // If it's a file, show file name and icon
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
                                            message.text.contains(
                                                      '[Dosya:',
                                                    ) && // Kept Turkish
                                                    message.text.contains(']')
                                                ? message.text.substring(
                                                    message.text.indexOf(
                                                          '[Dosya:', // Kept Turkish
                                                        ) +
                                                        8,
                                                    message.text.indexOf(']'),
                                                  )
                                                : message.text,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
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
                  ),
                  if (!_chatStarted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      height: 48,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _suggestionChip(
                              "Bana çalışma ipuçları ver",
                            ), // Kept Turkish
                            const SizedBox(width: 8),
                            _suggestionChip("Bana tavsiye ver"), // Kept Turkish
                            const SizedBox(width: 8),
                            _suggestionChip("Bir şey öner"), // Kept Turkish
                          ],
                        ),
                      ),
                    ),
                  // Preview area for selected file (above message input box)
                  if (_selectedFilePath != null)
                    Align(
                      // Aligned to the left
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 16,
                          top: 4,
                          bottom: 4,
                        ), // Left padding only
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              // Make preview area clickable
                              onTap: () {
                                setState(() {
                                  _showCloseButton =
                                      !_showCloseButton; // Toggle X button visibility
                                });
                              },
                              child: Stack(
                                clipBehavior:
                                    Clip.none, // Allows button to overflow
                                children: [
                                  // Preview content (image or file icon)
                                  if (_selectedFileType == 'image')
                                    Container(
                                      width: 80, // Size increased
                                      height: 80, // Size increased
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image:
                                              kIsWeb &&
                                                  _selectedFileBytes !=
                                                      null // For web and if bytes are available, use MemoryImage
                                              ? MemoryImage(_selectedFileBytes!)
                                              : (kIsWeb // If web but no bytes, or NetworkImage needed for URL
                                                    ? NetworkImage(
                                                        _selectedFilePath!,
                                                      )
                                                    : FileImage(
                                                        File(
                                                          _selectedFilePath!,
                                                        ),
                                                      )), // For other platforms, use FileImage
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  else // _selectedFileType == 'file'
                                    // New layout for file name and icon
                                    Container(
                                      width: 120, // Wider area
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade700,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.insert_drive_file,
                                            color: Colors.white70,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 4),
                                          Flexible(
                                            child: Text(
                                              _selectedFileName ??
                                                  'Seçili Dosya', // Kept Turkish
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Close button (visible only if _showCloseButton is true)
                                  if (_showCloseButton)
                                    Positioned(
                                      top: 5, // Positioned inside preview
                                      right: 5, // Positioned inside preview
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(
                                            0.6,
                                          ), // Transparent black circle background
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          ), // Smaller icon
                                          onPressed: () {
                                            setState(() {
                                              _selectedFilePath = null;
                                              _selectedFileName = null;
                                              _selectedFileType = null;
                                              _selectedFileBytes =
                                                  null; // Clear selected bytes too
                                              _showCloseButton =
                                                  false; // Hide X button after clearing
                                            });
                                          },
                                          visualDensity: VisualDensity
                                              .compact, // Makes button more compact
                                          padding: EdgeInsets
                                              .zero, // Removes extra padding
                                          constraints: const BoxConstraints(
                                            minWidth: 28,
                                            minHeight: 28,
                                          ), // Size constraints
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Mesaj yaz...", // Kept Turkish
                              hintStyle: TextStyle(
                                color: messageColor().withOpacity(0.7),
                              ),
                              filled: true,
                              fillColor: messageColor().withOpacity(0.15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: Row(
                                // Row used to show icons side by side
                                mainAxisSize: MainAxisSize
                                    .min, // Shrink Row to its content
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.auto_awesome_outlined,
                                      color: messageColor(),
                                    ),
                                    onPressed: () => _generateImageFromPrompt(
                                      _messageController.text,
                                    ),
                                    tooltip: 'Görsel Oluştur', // Kept Turkish
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.attach_file,
                                      color: messageColor(),
                                    ),
                                    onPressed: _showFileSelectionDialog,
                                  ),
                                ],
                              ),
                            ),
                            onSubmitted: sendMessageAndGetResponse,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.send, color: messageColor()),
                          onPressed: () => sendMessageAndGetResponse(
                            _messageController.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
