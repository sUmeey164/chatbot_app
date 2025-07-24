// lib/home_page.dart
import 'package:chatbot_app/sobet_oturumlari_sayfasi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io'; // Platform.isAndroid, Platform.isIOS, File için gerekli

// Your custom classes should be imported using package:your_app_name/path_to_file.dart
import 'package:chatbot_app/API/api_service.dart';
import 'package:chatbot_app/baslikOlusturucu.dart';
import 'package:chatbot_app/history_manager.dart';
import 'package:chatbot_app/mesaj.dart';
import 'package:chatbot_app/sohbet_gecmisi_sayfasi.dart';
import 'package:chatbot_app/SohbetOturumu.dart';

final ImagePicker _picker = ImagePicker();

class HomePage extends StatefulWidget {
  final String? kullaniciAdi;
  final String deviceId;

  const HomePage({Key? key, this.kullaniciAdi, required this.deviceId})
    : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SohbetOturumu? _currentSession;
  late String _deviceId;
  late String _username;
  bool _isLoading = true;

  final List<Mesaj> _messages = [];
  final TextEditingController _mesajController = TextEditingController();
  String _selectedModel = 'Chatbot';
  bool _chatStarted = false;

  String? _selectedFilePath;
  String? _selectedFileName;
  String? _selectedFileType; // 'image', 'file', null
  bool _showCloseButton = false; // Kapatma butonu görünürlüğü için durum

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

    _username = widget.kullaniciAdi ?? 'user_${_deviceId.substring(0, 8)}';

    _currentSession = await HistoryManager.getOturumByDeviceId(_deviceId);

    if (_currentSession == null) {
      _currentSession = SohbetOturumu(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        baslik: '',
        mesajlar: [],
        deviceId: _deviceId,
        model: _selectedModel,
      );
      await HistoryManager.saveSession(_currentSession!);
    } else {
      setState(() {
        _selectedModel = _currentSession!.model ?? 'Chatbot';
      });
    }

    if (_currentSession!.mesajlar.isNotEmpty) {
      setState(() {
        _messages.clear();
        _messages.addAll(_currentSession!.mesajlar);
        _chatStarted = true;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Color getMesajRengi(Mesaj mesaj) {
    if (mesaj.kullanici) {
      return Colors.grey.shade800;
    }

    final model = mesaj.model ?? 'Chatbot';
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

  void modelDegistir(String yeniModel) async {
    if (_currentSession != null && _currentSession!.mesajlar.isNotEmpty) {
      _currentSession!.model = _selectedModel;
      await HistoryManager.saveSession(_currentSession!);
    }

    _currentSession = SohbetOturumu(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      baslik: '',
      mesajlar: [],
      deviceId: _deviceId,
      model: yeniModel,
    );
    await HistoryManager.saveSession(_currentSession!);

    setState(() {
      _selectedModel = yeniModel;
      _messages.clear();
      _chatStarted = false;
    });
  }

  Color mesajRengi() {
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

  Widget _modelSecimCard(String modelAdi, IconData ikon, Color renk) {
    return GestureDetector(
      onTap: () {
        modelDegistir(modelAdi);
        Navigator.pop(context);
      },
      child: Card(
        color: renk.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(ikon, color: renk, size: 28),
              const SizedBox(width: 16),
              Text(
                modelAdi,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void mesajGonderVeGetir(String mesaj) async {
    if (mesaj.trim().isEmpty && _selectedFilePath == null) return;

    if (!_chatStarted) {
      setState(() {
        _chatStarted = true;
      });
    }

    String gonderilecekMetin = mesaj.trim();
    String? gonderilecekFilePath = _selectedFilePath;
    String? gonderilecekFileType = _selectedFileType;

    if (gonderilecekFilePath != null) {
      if (gonderilecekFileType == 'file' && gonderilecekMetin.isEmpty) {
        gonderilecekMetin = '[Dosya: ${_selectedFileName ?? 'Seçili Dosya'}]';
      }
    }

    final userMessage = Mesaj(
      kullanici: true,
      metin: gonderilecekMetin,
      model: _selectedModel,
      filePath: gonderilecekFilePath,
      fileType: gonderilecekFileType,
    );

    setState(() {
      _messages.add(userMessage);
      _selectedFileName = null;
      _selectedFilePath = null;
      _selectedFileType = null;
      _showCloseButton = false; // Mesaj gönderildiğinde X butonunu gizle
    });

    _mesajController.clear();

    if (_currentSession != null &&
        _currentSession!.baslik.isEmpty &&
        userMessage.metin.isNotEmpty) {
      _currentSession!.baslik = BaslikOlusturucu.olustur(userMessage.metin);
      await HistoryManager.updateSession(_currentSession!);
    } else if (_currentSession != null &&
        _currentSession!.baslik.isEmpty &&
        userMessage.filePath != null) {
      _currentSession!.baslik = userMessage.fileType == 'image'
          ? 'Resimli Sohbet'
          : 'Dosyalı Sohbet';
      await HistoryManager.updateSession(_currentSession!);
    }

    await HistoryManager.addMessage(userMessage, _currentSession!.id);

    try {
      final cevap = await ApiService.mesajGonder(
        gonderilecekMetin,
        model: _selectedModel,
        deviceId: _deviceId,
      );

      final botMessage = Mesaj(
        metin: cevap,
        kullanici: false,
        model: _selectedModel,
      );

      setState(() {
        _messages.add(botMessage);
      });

      await HistoryManager.addMessage(botMessage, _currentSession!.id);
    } catch (e) {
      setState(() {
        _messages.add(
          Mesaj(
            metin: 'Sunucuya bağlanılamadı.',
            kullanici: false,
            model: _selectedModel,
          ),
        );
      });
      await HistoryManager.addMessage(
        Mesaj(
          metin: 'Sunucuya bağlanılamadı.',
          kullanici: false,
          model: _selectedModel,
        ),
        _currentSession!.id,
      );
    }
  }

  void kameraIleCek() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      setState(() {
        _selectedFilePath = foto.path;
        _selectedFileName = foto.name;
        _selectedFileType = 'image';
      });
    }
  }

  void galeridenSec() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.gallery);
    if (foto != null) {
      setState(() {
        _selectedFilePath = foto.path;
        _selectedFileName = foto.name;
        _selectedFileType = 'image';
      });
    }
  }

  void dosyaSec() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      String dosyaAdi = result.files.single.name;
      String dosyaYolu = result.files.single.path!;

      setState(() {
        _selectedFilePath = dosyaYolu;
        _selectedFileName = dosyaAdi;
        _selectedFileType = 'file';
      });
    }
  }

  void _dosyaSecimDialog() {
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
                    galeridenSec();
                  }),
                  _buildActionColumn(Icons.camera_alt, 'Kamera', () {
                    Navigator.pop(context);
                    kameraIleCek();
                  }),
                  _buildActionColumn(Icons.insert_drive_file, 'Dosya', () {
                    Navigator.pop(context);
                    dosyaSec();
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

  Widget _chip(String yazi) {
    return ActionChip(
      label: Text(yazi),
      backgroundColor: mesajRengi().withOpacity(0.7),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14, // Yazı boyutunu belirginleştirdim
        height:
            0.9, // Bu değeri (örn: 0.8, 0.9, 1.0) deneyerek yazıyı dikeyde ortalamaya çalışın
        leadingDistribution: TextLeadingDistribution
            .even, // Satır boşluğunu üste ve alta eşit dağıt
      ),
      onPressed: () => mesajGonderVeGetir(yazi),
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ), // ActionChip'in genel padding'ini de biraz ayarladım
    );
  }

  // YENİ: Görsel oluşturma metodu
  void _generateImageFromPrompt(String prompt) async {
    if (prompt.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Görsel oluşturmak için bir açıklama girin.'),
        ),
      );
      return;
    }

    final userImageRequest = Mesaj(
      kullanici: true,
      metin: 'Görsel oluştur: "$prompt"',
      model: _selectedModel,
    );
    setState(() {
      _messages.add(userImageRequest);
      _mesajController.clear();
      _showCloseButton =
          false; // Görsel oluşturma isteği gönderildiğinde X butonunu gizle
    });
    await HistoryManager.addMessage(userImageRequest, _currentSession!.id);

    try {
      final imageUrl = await ApiService.generateImage(
        prompt,
        deviceId: _deviceId,
      );

      final botImageMessage = Mesaj(
        kullanici: false,
        metin: 'İşte oluşturduğum görsel:',
        model: _selectedModel,
        imageUrl: imageUrl, // Oluşturulan görselin URL'sini buraya ata
      );

      setState(() {
        _messages.add(botImageMessage);
      });
      await HistoryManager.addMessage(botImageMessage, _currentSession!.id);
    } catch (e) {
      final errorMessage = Mesaj(
        metin: 'Görsel oluşturulamadı: $e',
        kullanici: false,
        model: _selectedModel,
      );
      setState(() {
        _messages.add(errorMessage);
      });
      await HistoryManager.addMessage(errorMessage, _currentSession!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: mesajRengi(),
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
                        _modelSecimCard(
                          "Chatbot",
                          Icons.smart_toy,
                          Colors.deepPurple,
                        ),
                        const SizedBox(height: 10),
                        _modelSecimCard(
                          "ChatGPT",
                          Icons.chat_bubble_outline,
                          Colors.pink,
                        ),
                        const SizedBox(height: 10),
                        _modelSecimCard(
                          "Gemini",
                          Icons.auto_awesome,
                          Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        _modelSecimCard("DeepSeek", Icons.search, Colors.amber),
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
                  builder: (context) => const SohbetOturumlariSayfasi(),
                ),
              ).then((_) {
                _initializeChat();
              });
            },
            tooltip: 'Sohbet Oturumları',
          ),
          /* YORUM SATIRI YAPILDI: Sohbet Geçmişi butonu kaldırıldı.
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SohbetGecmisiSayfasi(deviceId: _deviceId),
                ),
              ).then((_) {
                _initializeChat();
              });
            },
            tooltip: 'Bu Sohbetin Geçmişi',
          ),
          */
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: mesajRengi()))
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final mesaj = _messages[index];

                        return Align(
                          alignment: mesaj.kullanici
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: getMesajRengi(mesaj),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // YENİ: Eğer oluşturulan görselin URL'si varsa göster
                                if (mesaj.imageUrl != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        // Image.network widget'ını kullanıyoruz
                                        mesaj.imageUrl!,
                                        width: 200, // Görsel boyutu
                                        height: 200, // Görsel boyutu
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Text(
                                                  'Görsel yüklenemedi.',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                // Eğer kullanıcının gönderdiği bir görsel yolu varsa
                                if (mesaj.filePath != null &&
                                    mesaj.fileType == 'image')
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.file(
                                        File(mesaj.filePath!),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Text(
                                                  'Görsel yüklenemedi.',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                // Eğer dosya varsa, dosya adını ve ikonu göster
                                if (mesaj.filePath != null &&
                                    mesaj.fileType == 'file')
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
                                            mesaj.metin.contains('[Dosya:') &&
                                                    mesaj.metin.contains(']')
                                                ? mesaj.metin.substring(
                                                    mesaj.metin.indexOf(
                                                          '[Dosya:',
                                                        ) +
                                                        8,
                                                    mesaj.metin.indexOf(']'),
                                                  )
                                                : mesaj.metin,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (mesaj.metin.isNotEmpty)
                                  Text(
                                    mesaj.metin,
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
                            _chip("Bana çalışma ipuçları ver"),
                            const SizedBox(width: 8),
                            _chip("Bana tavsiye ver"),
                            const SizedBox(width: 8),
                            _chip("Bir şey öner"),
                          ],
                        ),
                      ),
                    ),
                  // Seçilen dosya için önizleme alanı (mesaj giriş kutusunun üstünde)
                  if (_selectedFilePath != null)
                    Align(
                      // Sol köşeye hizalamak için Align eklendi
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 16,
                          top: 4,
                          bottom: 4,
                        ), // Sadece soldan boşluk bırakıldı
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              // Önizleme alanını tıklanabilir yapmak için
                              onTap: () {
                                setState(() {
                                  _showCloseButton =
                                      !_showCloseButton; // X butonunun görünürlüğünü aç/kapa
                                });
                              },
                              child: Stack(
                                clipBehavior:
                                    Clip.none, // Butonun taşmasına izin verir
                                children: [
                                  // Önizleme içeriği (görsel veya dosya ikonu)
                                  if (_selectedFileType == 'image')
                                    Container(
                                      width: 80, // Boyutu büyütüldü
                                      height: 80, // Boyutu büyütüldü
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(_selectedFilePath!),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  else // _selectedFileType == 'file'
                                    // Dosya adı ve ikonu için yeni düzenleme
                                    Container(
                                      width: 120, // Daha geniş bir alan
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
                                                  'Seçili Dosya',
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

                                  // Kapatma butonu (sadece _showCloseButton true ise görünür)
                                  if (_showCloseButton)
                                    Positioned(
                                      top: 5, // Önizleme içinde konumlandırıldı
                                      right:
                                          5, // Önizleme içinde konumlandırıldı
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(
                                            0.6,
                                          ), // Saydam siyah daire arkaplan
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          ), // Daha küçük ikon
                                          onPressed: () {
                                            setState(() {
                                              _selectedFilePath = null;
                                              _selectedFileName = null;
                                              _selectedFileType = null;
                                              _showCloseButton =
                                                  false; // Silindikten sonra X butonunu gizle
                                            });
                                          },
                                          visualDensity: VisualDensity
                                              .compact, // Butonu daha kompakt yapar
                                          padding: EdgeInsets
                                              .zero, // Fazla padding'i kaldırır
                                          constraints: const BoxConstraints(
                                            minWidth: 28,
                                            minHeight: 28,
                                          ), // Boyut kısıtlaması
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
                            controller: _mesajController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Mesaj yaz...",
                              hintStyle: TextStyle(
                                color: mesajRengi().withOpacity(0.7),
                              ),
                              filled: true,
                              fillColor: mesajRengi().withOpacity(0.15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: Row(
                                // İkonları yan yana göstermek için Row kullanıldı
                                mainAxisSize: MainAxisSize
                                    .min, // Row'u içeriği kadar daralt
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.auto_awesome_outlined,
                                      color: mesajRengi(),
                                    ),
                                    onPressed: () => _generateImageFromPrompt(
                                      _mesajController.text,
                                    ),
                                    tooltip: 'Görsel Oluştur',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.attach_file,
                                      color: mesajRengi(),
                                    ),
                                    onPressed: _dosyaSecimDialog,
                                  ),
                                ],
                              ),
                            ),
                            onSubmitted: mesajGonderVeGetir,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.send, color: mesajRengi()),
                          onPressed: () =>
                              mesajGonderVeGetir(_mesajController.text),
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
