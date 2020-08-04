import 'package:flutter/material.dart';
import 'package:penzugy_kezelo/Statisztikak/Napi.dart';
import 'package:penzugy_kezelo/Statisztikak/Heti.dart';
import 'package:penzugy_kezelo/Statisztikak/Havi.dart';

class Statisztika extends StatefulWidget {
  @override
  _StatisztikaState createState() => _StatisztikaState();
}

class _StatisztikaState extends State<Statisztika> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Statisztika"),
          backgroundColor: Colors.green[500],
          bottom: TabBar(
            indicatorColor: Colors.green[500],
            tabs: <Widget>[
              Tab(text: "Napi"),
              Tab(text: "Heti"),
              Tab(text: "Havi"),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Napi(),
            Heti(),
            Havi()
          ],
        ),
      ),
    );
  }
}
