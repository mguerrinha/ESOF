import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spantry/pages/nav_bar.dart';
import 'package:spantry/services/notification/local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spantry/utils/utils.dart';
import 'package:spantry/pages/authentication/auth_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDH_QRjjOzHS4Y0Fgi5Z8_K0kUSeF_FhoE",
        appId: "1:73252815940:android:1202a082cfc8a38e39e811",
        messagingSenderId: "73252815940",
        projectId: "spantry-1de44")
  );
  await LocalNotifications.init();
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  static const String title = 'Spantry';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    scaffoldMessengerKey: Utils.messengerKey,
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    title: title,
    home: const MainPage(),
  );
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        else if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong!'));
        }
        if (snapshot.hasData) {
          return const NavBar();
        } else{
          return const AuthPage();
        }
      },
    ),
  );
}