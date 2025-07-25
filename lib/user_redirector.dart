// lib/user_redirector.dart // Renamed file
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart'; // Adjust this according to your file path

class UserRedirector extends StatefulWidget {
  // Renamed class
  const UserRedirector({Key? key}) : super(key: key);

  @override
  State<UserRedirector> createState() => _UserRedirectorState(); // Renamed state class
}

class _UserRedirectorState extends State<UserRedirector> {
  // Renamed state class
  String? _deviceId;
  bool _isLoading = true; // Renamed _yukleniyor
  final TextEditingController _usernameController =
      TextEditingController(); // Renamed _kullaniciAdiController

  @override
  void initState() {
    super.initState();
    _performSetup(); // Renamed _hazirliklariYap
  }

  Future<void> _performSetup() async {
    // Renamed _hazirliklariYap
    // Get Device ID
    final deviceId = await _getDeviceId(); // Renamed _cihazIdAl

    // Get registered username from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final registeredUsername = prefs.getString(
      'userName',
    ); // Renamed kayitliKullaniciAdi, 'kullaniciAdi' to 'userName'

    // Update State
    setState(() {
      _deviceId = deviceId;
      _isLoading = false; // Renamed _yukleniyor
    });

    // If registered user exists, redirect directly to homepage
    if (registeredUsername != null && registeredUsername.isNotEmpty) {
      _navigateToHomePage(
        registeredUsername,
        deviceId,
      ); // Renamed _anaSayfayaGec
    }
  }

  // Device ID retrieval function
  Future<String> _getDeviceId() async {
    // Renamed _cihazIdAl
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id ?? 'unknown_android'; // Translated string literal
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ??
            'unknown_ios'; // Translated string literal
      } else {
        return 'unknown_platform'; // Translated string literal
      }
    } catch (e) {
      print('Could not get Device ID: $e'); // Translated string literal
      return 'unknown_device'; // Translated string literal
    }
  }

  // Homepage navigation function
  void _navigateToHomePage(String username, String deviceId) {
    // Renamed _anaSayfayaGec, kullaniciAdi to username
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          deviceId: deviceId,
          userName: username,
        ), // Renamed kullaniciAdi to userName
      ),
    );
  }

  // Function to run when login button is pressed
  Future<void> _login() async {
    // Renamed _girisYap
    final username = _usernameController.text
        .trim(); // Renamed kullaniciAdi to username, _kullaniciAdiController
    if (username.isEmpty || _deviceId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'userName',
      username,
    ); // Renamed 'kullaniciAdi' to 'userName'

    _navigateToHomePage(username, _deviceId!); // Renamed _anaSayfayaGec
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Renamed _yukleniyor
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')), // Translated string literal
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter Your Username', // Translated string literal
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller:
                  _usernameController, // Renamed _kullaniciAdiController
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: sumeyye01', // Translated string literal
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Login'), // Translated string literal
              onPressed: _login, // Renamed _girisYap
            ),
          ],
        ),
      ),
    );
  }
}
