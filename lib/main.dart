import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '/auth_page.dart';
import '/firebase_options.dart';
import '/screens/admin.dart';
import '/screens/home.dart';



void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
    home: AuthPage(),
    routes: {
      "/homepage":(context) => const HomeScreen(),
      "/adminpage":(context) => const AdminPage(),
      },
    );
  }
}