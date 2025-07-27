// lib/home_page.dart
import 'package:chatbot_app/chat_sessions_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'api_service.dart';
import 'package:chatbot_app/title_generator.dart';
import 'package:chatbot_app/history_manager.dart';
import 'package:chatbot_app/message.dart';
import 'package:chatbot_app/chat_session.dart';
import 'package:chatbot_app/chat_response.dart';

final ImagePicker _picker = ImagePicker();

class HomePage extends StatefulWidget {
  final String? userName;
  final String deviceId;

  const HomePage({Key? key, this.userName, required this.deviceId})
    : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChatSession? _currentSession;
  late String _deviceId;
  late String _username;
  bool _isLoading = true;

  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  String _selectedModel = 'Chatbot'; // Default model
  bool _chatStarted = false;

  String? _selectedFilePath;
  String? _selectedFileName;
  String? _selectedFileType; // 'image', 'file', null
  Uint8List? _selectedFileBytes; // Selected file's bytes
  bool _isCloseButtonVisible = false; // State for close button visibility

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

    // Try to load the session for the current device and default model
    _currentSession = await HistoryManager.getSessionByDeviceIdAndModel(
      _deviceId,
      _selectedModel,
    );

    if (_currentSession == null) {
      _currentSession = ChatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '',
        messages: [],
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
      setState(() {
        _messages.clear();
        _messages.addAll(_currentSession!.messages);
        _chatStarted = true;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Color getMessageColor(Message message) {
    if (message.isUser) {
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
    // Save the current session before changing the model, only if it's not null
    if (_currentSession != null) {
      // Ensure the model is set before saving
      _currentSession!.model = _selectedModel;
      await HistoryManager.saveSession(_currentSession!);
    }

    // Try to load an existing session for the new model
    final existingSession = await HistoryManager.getSessionByDeviceIdAndModel(
      _deviceId,
      newModel,
    );

    setState(() {
      _selectedModel = newModel;
      _messages.clear();
      _chatStarted = false;
    });

    if (existingSession != null) {
      _currentSession = existingSession;
      setState(() {
        _messages.addAll(_currentSession!.messages);
        if (_currentSession!.messages.isNotEmpty) {
          _chatStarted = true;
        }
      });
    } else {
      // Create a new session if no existing session is found for the new model
      _currentSession = ChatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '',
        messages: [],
        deviceId: _deviceId,
        model: newModel,
      );
      await HistoryManager.saveSession(_currentSession!);
    }
  }

  Color messageColor() {
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
    return GestureDetector(
      onTap: () {
        changeModel(modelName);
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

  void sendMessageAndGetResponse(String message) async {
    if (message.trim().isEmpty && _selectedFilePath == null) return;

    if (!_chatStarted) {
      setState(() {
        _chatStarted = true;
      });
    }

    String textToSend = message.trim();
    String? filePathToSend = _selectedFilePath;
    String? fileTypeToSend = _selectedFileType;
    String? base64ImageData;
    bool isImageGenerationPrompt = false;
    String imageGenerationPrompt = '';

    const String imagePromptPrefix = 'Görsel oluştur:';
    if (textToSend.toLowerCase().startsWith(imagePromptPrefix.toLowerCase())) {
      imageGenerationPrompt = textToSend
          .substring(imagePromptPrefix.length)
          .trim();
      isImageGenerationPrompt = true;
      textToSend =
          ''; // Clear the text message as it's an image generation command
    }

    // If an image file is selected, convert it to Base64
    if (filePathToSend != null && fileTypeToSend == 'image') {
      try {
        if (kIsWeb && _selectedFileBytes != null) {
          base64ImageData = base64Encode(_selectedFileBytes!);
          debugPrint(
            'Selected image (Web) converted to Base64. Length: ${base64ImageData.length}',
          );
        } else if (!kIsWeb) {
          final file = File(filePathToSend);
          final bytes = await file.readAsBytes();
          base64ImageData = base64Encode(bytes);
          debugPrint(
            'Selected image (Mobile/Desktop) converted to Base64. Length: ${base64ImageData.length}',
          );
        }
      } catch (e) {
        debugPrint('Error converting image to Base64: $e');
        base64ImageData = null;
      }
    }

    if (filePathToSend != null) {
      if (fileTypeToSend == 'file' && textToSend.isEmpty) {
        textToSend = '[Dosya: ${_selectedFileName ?? 'Seçili Dosya'}]';
      }
    }

    final userMessage = Message(
      isUser: true,
      text: isImageGenerationPrompt
          ? 'Görsel oluşturma isteği: "$imageGenerationPrompt"'
          : textToSend,
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
      _isCloseButtonVisible = false; // Reset close button visibility on send
    });

    _messageController.clear();

    if (_currentSession != null &&
        _currentSession!.title.isEmpty &&
        userMessage.text.isNotEmpty) {
      _currentSession!.title = TitleGenerator.generate(userMessage.text);
      await HistoryManager.updateSession(_currentSession!);
    } else if (_currentSession != null &&
        _currentSession!.title.isEmpty &&
        userMessage.filePath != null) {
      _currentSession!.title = userMessage.fileType == 'image'
          ? 'Resimli Sohbet'
          : 'Dosyalı Sohbet';
      await HistoryManager.updateSession(_currentSession!);
    }

    await HistoryManager.addMessage(userMessage, _currentSession!.id);

    try {
      final ChatResponse apiResponse;
      if (isImageGenerationPrompt) {
        apiResponse = await ApiService.sendMessage(
          imageGenerationPrompt,
          model: _selectedModel,
          deviceId: _deviceId,
          isImageGeneration: true,
        );
      } else {
        apiResponse = await ApiService.sendMessage(
          textToSend,
          model: _selectedModel,
          deviceId: _deviceId,
          base64Image: base64ImageData,
        );
      }

      if (apiResponse.replyText != null && apiResponse.replyText!.isNotEmpty) {
        final botMessage = Message(
          text: apiResponse.replyText!,
          isUser: false,
          model: _selectedModel,
        );
        setState(() {
          _messages.add(botMessage);
        });
        await HistoryManager.addMessage(botMessage, _currentSession!.id);
      }

      if (apiResponse.base64Image != null &&
          apiResponse.base64Image!.isNotEmpty) {
        debugPrint(
          'Base64 image data received. Length: ${apiResponse.base64Image!.length}',
        );
        final botImageMessage = Message(
          isUser: false,
          text: 'İşte oluşturduğum görsel:',
          model: _selectedModel,
          base64Image: apiResponse.base64Image!,
        );
        setState(() {
          _messages.add(botImageMessage);
        });
        await HistoryManager.addMessage(botImageMessage, _currentSession!.id);
      } else {
        debugPrint('Base64 image data not found or empty in API response.');
      }

      if (apiResponse.replyText == null && apiResponse.base64Image == null) {
        setState(() {
          _messages.add(
            Message(
              text: 'Sunucudan geçerli bir yanıt alınamadı.',
              isUser: false,
              model: _selectedModel,
            ),
          );
        });
        await HistoryManager.addMessage(
          Message(
            text: 'Sunucudan geçerli bir yanıt alınamadı.',
            isUser: false,
            model: _selectedModel,
          ),
          _currentSession!.id,
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      setState(() {
        _messages.add(
          Message(
            text: 'Sunucuya bağlanılamadı veya bir hata oluştu: $e',
            isUser: false,
            model: _selectedModel,
          ),
        );
      });
      await HistoryManager.addMessage(
        Message(
          text: 'Sunucuya bağlanılamadı veya bir hata oluştu: $e',
          isUser: false,
          model: _selectedModel,
        ),
        _currentSession!.id,
      );
    }
  }

  void pickImageFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedFilePath = photo.path;
        _selectedFileName = photo.name;
        _selectedFileType = 'image';
        if (kIsWeb) {
          photo.readAsBytes().then((bytes) {
            setState(() {
              _selectedFileBytes = bytes;
            });
          });
        }
        _isCloseButtonVisible =
            false; // Initially hide button for new selection
      });
    }
  }

  void pickImageFromGallery() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() {
        _selectedFilePath = photo.path;
        _selectedFileName = photo.name;
        _selectedFileType = 'image';
        if (kIsWeb) {
          photo.readAsBytes().then((bytes) {
            setState(() {
              _selectedFileBytes = bytes;
            });
          });
        }
        _isCloseButtonVisible =
            false; // Initially hide button for new selection
      });
    }
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      String fileName = result.files.single.name;
      String filePath = result.files.single.path!;
      Uint8List? fileBytes = result.files.single.bytes;

      setState(() {
        _selectedFilePath = filePath;
        _selectedFileName = fileName;
        _selectedFileType = 'file';
        _selectedFileBytes = fileBytes;
        _isCloseButtonVisible =
            false; // Initially hide button for new selection
      });
    }
  }

  void _showFileSelectionDialog() {
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
                    Navigator.pop(context);
                    pickImageFromGallery();
                  }),
                  _buildActionColumn(Icons.camera_alt, 'Kamera', () {
                    Navigator.pop(context);
                    pickImageFromCamera();
                  }),
                  _buildActionColumn(Icons.insert_drive_file, 'Dosya', () {
                    Navigator.pop(context);
                    pickFile();
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
    return ActionChip(
      label: Text(text),
      backgroundColor: messageColor().withOpacity(0.7),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 0.9,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      onPressed: () => sendMessageAndGetResponse(text),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    );
  }

  // Helper widget to display the file preview
  Widget _buildFilePreviewWidget() {
    if (_selectedFilePath == null) {
      return const SizedBox.shrink(); // Return empty widget if no file selected
    }

    Widget previewContent;
    double previewWidth;
    double previewHeight;

    if (_selectedFileType == 'image') {
      previewWidth = 80; // Desired image preview size
      previewHeight = 80;
      previewContent = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: kIsWeb && _selectedFileBytes != null
            ? Image.memory(
                _selectedFileBytes!,
                width: previewWidth,
                height: previewHeight,
                fit: BoxFit.cover,
              )
            : (kIsWeb
                  ? Image.network(
                      _selectedFilePath!,
                      width: previewWidth,
                      height: previewHeight,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(_selectedFilePath!),
                      width: previewWidth,
                      height: previewHeight,
                      fit: BoxFit.cover,
                    )),
      );
    } else {
      // file type
      previewWidth = 100; // Desired file preview size (wider for text)
      previewHeight = 80;
      previewContent = Container(
        width: previewWidth,
        height: previewHeight,
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(8),
        ),
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
                _selectedFileName ?? 'Seçili Dosya',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      // Make the entire preview clickable to toggle 'X' visibility
      onTap: () {
        setState(() {
          _isCloseButtonVisible =
              !_isCloseButtonVisible; // Toggle visibility of 'X'
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12.0,
          top: 8.0,
          bottom: 4.0,
        ), // Padding within the input bar
        child: Stack(
          clipBehavior: Clip.none, // Allow X button to overflow
          children: [
            previewContent,
            // Close Button for the preview (conditionally visible)
            if (_isCloseButtonVisible) // Only show if _isCloseButtonVisible is true
              Positioned(
                top: -10, // Adjust to position outside the box
                right: -10, // Adjust to position outside the box
                child: GestureDetector(
                  // Ensure this GestureDetector captures taps
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _selectedFilePath = null;
                      _selectedFileName = null;
                      _selectedFileType = null;
                      _selectedFileBytes = null;
                      _messageController
                          .clear(); // Clear text field if user had typed something with file
                      _isCloseButtonVisible =
                          false; // Hide button after clearing
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    width: 24, // Slightly larger tap target
                    height: 24, // Slightly larger tap target
                    alignment: Alignment.center, // Center the icon
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16, // Small size for the close icon
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatSessionsPage(
                    selectedModel:
                        _selectedModel, // Pass the currently selected model
                  ),
                ),
              ).then((_) {
                _initializeChat(); // Reload sessions on return
              });
            },
            tooltip: 'Sohbet Oturumları',
          ),
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
                                        base64Decode(message.base64Image!),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          debugPrint(
                                            'Failed to load Base64 image: $error',
                                          );
                                          return const Text(
                                            'Görsel yüklenemedi (Base64).',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                // Show external URL if available (current code)
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
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              debugPrint(
                                                'Failed to load URL image: $error',
                                              );
                                              return const Text(
                                                'Görsel yüklenemedi (URL).',
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
                                              )
                                          ? (_selectedFileBytes != null
                                                ? Image.memory(
                                                    _selectedFileBytes!,
                                                    width: 200,
                                                    height: 200,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    message.filePath!,
                                                    width: 200,
                                                    height: 200,
                                                    fit: BoxFit.cover,
                                                  ))
                                          : Image.file(
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
                                                      'Görsel yüklenemedi.',
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
                                            message.text.contains('[Dosya:') &&
                                                    message.text.contains(']')
                                                ? message.text.substring(
                                                    message.text.indexOf(
                                                          '[Dosya:',
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
                            _suggestionChip("Bana çalışma ipuçları ver"),
                            const SizedBox(width: 8),
                            _suggestionChip("Bana tavsiye ver"),
                            const SizedBox(width: 8),
                            _suggestionChip("Bir şey öner"),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: messageColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.only(
                        bottom: 4,
                      ), // Added bottom padding to the container
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.end, // Align items to the bottom
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize:
                                  MainAxisSize.min, // Wrap content height
                              children: [
                                // File preview area (conditionally visible)
                                if (_selectedFilePath != null)
                                  _buildFilePreviewWidget(), // Now it's clickable
                                TextField(
                                  controller: _messageController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: (_selectedFilePath != null)
                                        ? ""
                                        : "Mesaj yaz...", // Hide hint when file is selected
                                    hintStyle: TextStyle(
                                      color: messageColor().withOpacity(0.7),
                                    ),
                                    filled:
                                        false, // Background is on the parent Container
                                    border: InputBorder
                                        .none, // Remove default TextField border
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onSubmitted: sendMessageAndGetResponse,
                                  minLines: 1,
                                  maxLines:
                                      5, // Allow multiple lines for text input
                                ),
                              ],
                            ),
                          ),
                          // Attach file button (always visible)
                          IconButton(
                            icon: Icon(
                              Icons.attach_file,
                              color: messageColor(),
                            ),
                            onPressed: _showFileSelectionDialog,
                          ),
                          // Send message button (always visible)
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
                  ),
                ],
              ),
            ),
    );
  }
}
