import 'package:eventra/data/app_config.dart';
import 'package:eventra/data/eventra_session.dart';
import 'package:eventra/features/auth/views/login_page.dart';
import 'package:eventra/features/home/views/main_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.instance.load();
  await EventraSession.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventra',
      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.purple,
      ),

      home: EventraSession.instance.isLoggedIn
          ? const MainScreen()
          : const LoginPage(),
    );
  }
}
