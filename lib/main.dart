import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_scout/firebase_options.dart';
import 'package:trash_scout/provider/bottom_navigation_provider.dart';
import 'package:trash_scout/screens/user/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => BottomNavigationProvider(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: true,
      home: SplashScreen(),
    );
  }
}
