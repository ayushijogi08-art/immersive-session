import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/ambience/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive and open a local box for our journals
  await Hive.initFlutter();
  await Hive.openBox('journalBox');
  runApp(const ProviderScope(child: ArvyaXApp()));
}

class ArvyaXApp extends StatelessWidget {
  const ArvyaXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArvyaX Session',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}