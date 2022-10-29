import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snake_game/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCnBdUc9lrTJ0mmloCzIySFQpdwwkYoQ_k",
          authDomain: "snakegame-f0ff8.firebaseapp.com",
          projectId: "snakegame-f0ff8",
          storageBucket: "snakegame-f0ff8.appspot.com",
          messagingSenderId: "227223981223",
          appId: "1:227223981223:web:457140cd88055128fbdf82",
          measurementId: "G-6WT4G9YCPZ"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Game',
      theme: ThemeData(brightness: Brightness.dark),
      home: HomePage(),
    );
  }
}
