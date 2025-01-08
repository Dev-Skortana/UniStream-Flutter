import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final String nameofapplication = "UniStream";
  int _currentindex = 0;

  void setCurrentIndex(int index) {
    setState(() {
      this._currentindex = index;
    });
  }

  void setCurrentTheme() {
    setState(() {
      Provider.of<ThemeProvider>(context, listen: false).toogleTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UniStream',
        theme: Provider.of<ThemeProvider>(context).themeData,
        home: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: [
              Row(spacing: 15, children: [
                Text(this.nameofapplication),
                Text("Acceuille", style: TextStyle(fontSize: 20))
              ]),
              Row(spacing: 15, children: [
                Text(this.nameofapplication),
                Text("Animer", style: TextStyle(fontSize: 20))
              ]),
              Row(spacing: 15, children: [
                Text(this.nameofapplication),
                Text("Drama", style: TextStyle(fontSize: 20))
              ]),
              Row(spacing: 15, children: [
                Text(this.nameofapplication),
                Text("Serie", style: TextStyle(fontSize: 20))
              ]),
              Row(spacing: 15, children: [
                Text(this.nameofapplication),
                Text("Film", style: TextStyle(fontSize: 20))
              ]),
              Row(spacing: 15, children: [
                Text(this.nameofapplication),
                Text("Enregistrements", style: TextStyle(fontSize: 20))
              ]),
              Row(spacing: 15, children: [
                Text(this.nameofapplication),
                Text("Sites enregistrements", style: TextStyle(fontSize: 16))
              ])
            ][this._currentindex],
            leading: Icon(Icons.bed),
            centerTitle: true,
            //backgroundColor: Colors.blueGrey,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.accessibility),
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                onPressed: () {
                  this.setCurrentTheme();
                },
              )
            ],
          ),
          body: [
            ViewAcceuille(),
            ViewAnimer(),
            ViewDrama(),
            ViewSerie(),
            ViewFilm(),
            ViewEnregistrement(),
            ViewSiteStreamRegister()
          ][this._currentindex],
          bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: this._currentindex,
              onTap: (index) => this.setCurrentIndex(index),
              selectedItemColor: Colors.lightBlue,
              unselectedItemColor: Colors.black87,
              iconSize: 32,
              elevation: 10,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.house), label: "Acceuille"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.view_stream), label: "Animer"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.view_stream), label: "Drama"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.view_stream), label: "Serie"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.view_stream), label: "Film"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search), label: "Enregistrements"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.import_contacts),
                    label: "Sites enregistrements")
              ]),
        ));
  }
}
