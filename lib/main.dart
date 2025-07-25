import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// device_info_plus is no longer directly used here, will be used in HomePage
// import 'package:device_info_plus/device_info_plus.dart'; // Remove this line
import 'package:shared_preferences/shared_preferences.dart'; // For username

import 'home_page.dart';
// ChatHistoryPage route definition is no longer needed here, navigation is done from HomePage.
// import 'sohbet_gecmisi_sayfasi.dart'; // You can remove this line if accessed only from HomePage

// getDeviceId() function is no longer needed in main.dart, handled in HomePage.
/*
Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (kIsWeb) {
    return 'web_user_${DateTime.now().millisecondsSinceEpoch}';
  }

  try {
    final info = await deviceInfo.deviceInfo;
    final data = info.data;
    return data['id'] ??
        data['identifierForVendor'] ??
        data['deviceId'] ??
        'unknown_device';
  } catch (e) {
    return 'device_id_error';
  }
}
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // No need to get deviceId here, HomePage will handle it internally.
  // final deviceId = await getDeviceId(); // Remove this line

  final prefs = await SharedPreferences.getInstance();
  // Get username from SharedPreferences. If not available, we can assign a default value.
  // Since HomePage's _initializeChat method will determine deviceId internally,
  // we can pass a temporary value or null for userName.
  // The logic in HomePage will create a username based on its deviceId if null.
  final userName = prefs.getString('userName'); // Just get the saved username

  runApp(MyApp(userName: userName)); // Remove deviceId parameter
}

class MyApp extends StatelessWidget {
  final String? userName; // Can now be nullable

  // Remove deviceId parameter from constructor
  const MyApp({this.userName, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot Application',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      // Pass only userName to HomePage. HomePage will manage deviceId internally.
      // Since deviceId is required in HomePage's constructor, we'll pass an empty string for now.
      // HomePage's _initializeChat method will override this.
      home: HomePage(userName: userName, deviceId: ''),
      // Redirection to ChatHistoryPage is now handled via MaterialPageRoute from HomePage.
      // This route definition is unnecessary here and could lead to incorrect deviceId passing.
      // routes: {
      //   '/chatHistory': (context) => const ChatHistoryPage(deviceId: ''),
      // },
    );
  }
}
