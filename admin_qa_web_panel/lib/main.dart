import 'package:admin_qa_web_panel/dashboard/side_navigation_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyA6bgPRJPq1c7aa_4RCRIH5wnupS6mMyxw",
        authDomain: "flutter-bla-clone-with-admin.firebaseapp.com",
        databaseURL: "https://flutter-bla-clone-with-admin-default-rtdb.firebaseio.com",
        projectId: "flutter-bla-clone-with-admin",
        storageBucket: "flutter-bla-clone-with-admin.appspot.com",
        messagingSenderId: "602159083558",
        appId: "1:602159083558:web:b242eac3132166385df6e7",
        measurementId: "G-TY6SHZV1ZQ"
    )
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TRUNG TÂM ĐIỀU PHỐI',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: SideNavigationDrawer(),
    );
  }
}

