// lib/home_page.dart
import 'package:chatbot_app/sobet_oturumlari_sayfasi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart'; // Bu satır düzeltildi!
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
  // YENİ EKLENDİ: Oturum ve kullanıcı yönetimi için değişkenler
  SohbetOturumu? _currentSession;
  late String _deviceId;
  late String _username;
  bool _isLoading = true;

  // Mevcut değişkenleriniz
  final List<Mesaj> _messages = [];
  final TextEditingController _mesajController = TextEditingController();
  String _selectedModel = 'Chatbot';
  bool _chatStarted = false;

  // YENİ/GÜNCELLENEN Değişkenler:
  String? _selectedFilePath;
  String? _selectedFileName;
  String? _selectedFileType; // 'image', 'file', null

  // _initializeChat'in sadece bir kez çalışmasını sağlamak için bayrak
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

    // Eğer görsel seçildi ama metin boşsa, metni boş bırak
    // Eğer dosya seçildi ve metin boşsa, metni "[Dosya: dosya_adı]" şeklinde yap
    if (gonderilecekFilePath != null) {
      if (gonderilecekFileType == 'file' && gonderilecekMetin.isEmpty) {
        gonderilecekMetin = '[Dosya: ${_selectedFileName ?? 'Seçili Dosya'}]';
      }
      // Görsel ise, metin kısmı kullanıcının yazdığı kadar kalır, eğer boşsa boş kalır.
      // Görsel direkt olarak Image.file ile gösterilecek.
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
    });

    _mesajController.clear();

    if (_currentSession != null &&
        _currentSession!.baslik.isEmpty &&
        userMessage.metin.isNotEmpty) {
      // Başlık için kullanıcının metni yeterli
      _currentSession!.baslik = BaslikOlusturucu.olustur(userMessage.metin);
      await HistoryManager.updateSession(_currentSession!);
    } else if (_currentSession != null &&
        _currentSession!.baslik.isEmpty &&
        userMessage.filePath != null) {
      // Eğer sadece dosya/resim gönderildiyse ve başlık yoksa, basit bir başlık oluştur
      _currentSession!.baslik = userMessage.fileType == 'image'
          ? 'Resimli Sohbet'
          : 'Dosyalı Sohbet';
      await HistoryManager.updateSession(_currentSession!);
    }

    await HistoryManager.addMessage(userMessage, _currentSession!.id);

    try {
      // API Servisi görsel veya dosya göndermeyi desteklemiyorsa, burada hata alabilirsiniz.
      // API entegrasyonu için ek çalışma gerekebilir.
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
      // Bottom sheet'i kapatmak için Navigator.pop
      // _dosyaSecimDialog metodu içinde zaten çağrılıyor, burada tekrar çağırmaya gerek yok.
      // Eğer ayrı ayrı çağırıyorsanız, bu satırı eklemelisiniz: Navigator.pop(context);
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
      // Navigator.pop(context);
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
      // Navigator.pop(context);
    }
  }

  void _dosyaSecimDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey, // Bu rengi de dinamik yapabilirsiniz
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
                    Navigator.pop(
                      context,
                    ); // Seçim sonrası bottom sheet'i kapat
                    galeridenSec();
                  }),
                  _buildActionColumn(Icons.camera_alt, 'Kamera', () {
                    Navigator.pop(
                      context,
                    ); // Seçim sonrası bottom sheet'i kapat
                    kameraIleCek();
                  }),
                  _buildActionColumn(Icons.insert_drive_file, 'Dosya', () {
                    Navigator.pop(
                      context,
                    ); // Seçim sonrası bottom sheet'i kapat
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
      labelStyle: const TextStyle(color: Colors.white),
      onPressed: () => mesajGonderVeGetir(yazi),
    );
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
                                // Eğer resim varsa, önizlemesini göster
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
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => const Text(
                                              'Görsel yüklenemedi.',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ), // Sadece bir tane color kullanın// Hata mesajı beyaz olsun
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
                                // Eğer mesaj metni varsa göster (görsel veya dosya olsa bile)
                                if (mesaj
                                    .metin
                                    .isNotEmpty) // Sadece metin varsa göster
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
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if (_selectedFileType == 'image')
                            // Görsel önizlemesi
                            Container(
                              width: 60,
                              height: 60,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(File(_selectedFilePath!)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            // Dosya ikonu
                            const Icon(
                              Icons.insert_drive_file,
                              color: Colors.white70,
                              size: 20, // İkon boyutu
                            ),
                          const SizedBox(
                            width: 8,
                          ), // İkon ile kapatma butonu arasına boşluk
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedFilePath = null;
                                _selectedFileName = null;
                                _selectedFileType = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  // Mesaj giriş alanı: Bu tek kopya kalacak.
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.attach_file,
                                  color: mesajRengi(),
                                ),
                                onPressed: _dosyaSecimDialog,
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
