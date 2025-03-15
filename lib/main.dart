import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unistream/Views/MainWrapper.dart';
import 'package:unistream/Views/Helpers/Theme_Provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniStream',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: MainWrapper(),
    );
  }
}
