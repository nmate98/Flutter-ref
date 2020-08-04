import 'package:flutter/material.dart';
import 'package:penzugy_kezelo/Kezdolap.dart';
import 'package:penzugy_kezelo/Hozzaad.dart';
import 'package:penzugy_kezelo/Modellek/KategReszlet.dart';
import 'package:penzugy_kezelo/Statisztika.dart';
import 'package:penzugy_kezelo/Statisztikak/StatReszletek.dart';
import 'package:penzugy_kezelo/Statisztikak/KategReszletek.dart';
void main() => runApp(App());

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  int selectedPage = 0;
  final pages = [
    Kezdolap(),
    Hozzaad(),
    Statisztika()
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: pages[selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.green[500],
          currentIndex: selectedPage,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text("Kezdőlap")),
            BottomNavigationBarItem(
                icon: Icon(Icons.input), title: Text("Bevitel")),
            BottomNavigationBarItem(
                icon: Icon(Icons.monetization_on), title: Text("Statisztika"))
          ],
          onTap: (int index){
            setState(() {
              selectedPage = index;
            });
          },
        ),
      ),
      routes: {
        '/statReszlet' : (context) => StatReszletek(),
        '/kategReszlet' : (context) => KategReszletek()
      },
    );
  }
}
