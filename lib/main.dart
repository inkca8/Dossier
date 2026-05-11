import 'package:flutter/material.dart';

import 'repo.dart';
import 'screens/contacts_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  repo = await ContactsRepo.load();
  runApp(const DossierApp());
}

class DossierApp extends StatelessWidget {
  const DossierApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6B4F8E);
    return MaterialApp(
      title: 'Dossier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const ContactsListScreen(),
    );
  }
}
