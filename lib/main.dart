import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unistream/Views/MainWrapper.dart';
import 'Views/Helpers/Routing.dart';
import 'package:unistream/Views/Helpers/Theme_Provider.dart';

import 'package:unistream/Views/View_Drama.dart';
import 'package:unistream/Views/View_Enregistrement.dart';
import 'package:unistream/Views/View_Film.dart';
import 'package:unistream/Views/View_Serie.dart';
import 'package:unistream/Views/View_Site_Stream_Register.dart';
import 'package:unistream/Views/View_Acceuille.dart';
import 'package:unistream/Views/View_Animer.dart';
//import 'package:unistream/Views/Templates/App_Bar.dart';
//import 'package:unistream/Views/Templates/Navigation_Bar.dart';
//import 'package:unistream/Views/Helpers/Theme.dart';

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
