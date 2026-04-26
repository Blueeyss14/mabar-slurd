import 'package:flutter/material.dart';
import 'package:mabar_slurd/core/notification_service.dart';
import 'package:mabar_slurd/src/feat/common/presentation/views/splash_screen.dart'; // [NEW] Import SplashScreen

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // [UPDATE] Arahkan ke SplashScreen pertama kali
    );
  }
}
