import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mirror/home_screen.dart';
import 'package:mirror/screens/alarm_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/notification_service2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final NotificationService notificationService = NotificationService();

  await NotificationService.init();

  await Permission.notification.request();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirror Hours',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: GoogleFonts.pangolin().fontFamily,
      ),
      home: const HomeScreen(),
    );
  }
}
