import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unistream/Views/Helpers/Theme_Provider.dart';
import 'package:unistream/Views/View_Acceuille.dart';
import 'package:unistream/Views/View_Animer.dart';
import 'package:unistream/Views/View_Drama.dart';
import 'package:unistream/Views/View_Enregistrement.dart';
import 'package:unistream/Views/View_Film.dart';
import 'package:unistream/Views/View_Serie.dart';
import 'package:unistream/Views/View_Site_Stream_Register.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => MainWrapperState();
}

class MainWrapperState extends State<MainWrapper> {
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
    return Scaffold(
      appBar: AppBar(
        title: SafeArea(
            child: IndexedStack(
          index: this._currentindex,
          children: [
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
          ],
        )),
        leading: Icon(Icons.bed),
        centerTitle: true,
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
      body: SafeArea(
          child: IndexedStack(
        index: this._currentindex,
        children: [
          ViewAcceuille(),
          ViewAnimer(),
          ViewDrama(),
          ViewSerie(),
          ViewFilm(),
          ViewEnregistrement(),
          //ViewSiteStreamRegister(),
        ],
      )),
      bottomNavigationBar: NavigationBar(
          selectedIndex: this._currentindex,
          elevation: 10,
          onDestinationSelected: (index) {
            this.setCurrentIndex(index);
          },
          destinations: const [
            NavigationDestination(
                selectedIcon: Icon(Icons.house),
                icon: Icon(Icons.house_outlined),
                label: "Acceuille"),
            NavigationDestination(
                selectedIcon: Icon(Icons.view_stream),
                icon: Icon(Icons.view_stream_outlined),
                label: "Animer"),
            NavigationDestination(
                selectedIcon: Icon(Icons.view_stream),
                icon: Icon(Icons.view_stream_outlined),
                label: "Drama"),
            NavigationDestination(
                selectedIcon: Icon(Icons.view_stream),
                icon: Icon(Icons.view_stream_outlined),
                label: "Serie"),
            NavigationDestination(
                selectedIcon: Icon(Icons.view_stream),
                icon: Icon(Icons.view_stream_outlined),
                label: "Film"),
            NavigationDestination(
                selectedIcon: Icon(Icons.search),
                icon: Icon(Icons.search_outlined),
                label: "Enregistrements"),
            NavigationDestination(
                selectedIcon: Icon(Icons.import_contacts),
                icon: Icon(Icons.import_contacts_outlined),
                label: "Sites enregistrements"),
          ]),
    );
  }
}
