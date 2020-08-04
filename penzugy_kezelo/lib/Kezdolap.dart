import 'package:flutter/material.dart';
import 'package:penzugy_kezelo/Adatbazis/db_provider.dart';
import 'package:penzugy_kezelo/Modellek/Osszesites.dart';

class Kezdolap extends StatefulWidget {
  @override
  _KezdolapState createState() => _KezdolapState();
}

class _KezdolapState extends State<Kezdolap> {
  Osszesites napiKimutat = Osszesites(bevetel: 0, kiadas: 0);
  Osszesites hetiKimutat = Osszesites(bevetel: 0, kiadas: 0);
  Osszesites haviKimutat = Osszesites(bevetel: 0, kiadas: 0);
  List<int> ertekek = List(6);

  napiOsszesites() async {
    await DbProvider.db
        .napiBevetel()
        .then((value) => {ertekek[0] = value});

    await DbProvider.db
        .napiKiadas()
        .then((value) => {ertekek[1] = value});
  }

  hetiOsszesites() async {
    await DbProvider.db
        .hetiBevetel()
        .then((value) => {ertekek[2] = value});
    await DbProvider.db
        .hetiKiadas()
        .then((value) => {ertekek[3] = value});
  }

  haviOsszesites() async {
    await DbProvider.db
        .haviBevetel()
        .then((value) => {ertekek[4] = value});

    await DbProvider.db
        .haviKiadas()
        .then((value) => {ertekek[5] = value});
  }

  betolt() {
    setState(() {
      napiKimutat.bevetel = ertekek[0];
      napiKimutat.kiadas = ertekek[1];
      hetiKimutat.bevetel = ertekek[2];
      hetiKimutat.kiadas = ertekek[3];
      haviKimutat.bevetel = ertekek[4];
      haviKimutat.kiadas = ertekek[5];
    });
  }

  loadKimutat() async {
    await napiOsszesites();
    await hetiOsszesites();
    await haviOsszesites();
  }

  tolt() async {
    await loadKimutat();
    betolt();
  }

  @override
  void initState() {
    super.initState();
    tolt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kezdőlap"),
        backgroundColor: Colors.green[500],
      ),
      body: Column(
        children: <Widget>[
          buildCard(napiKimutat, "Napi"),
          buildCard(hetiKimutat, "Heti"),
          buildCard(haviKimutat, "Havi"),
        ],
      ),
    );
  }

  Card buildCard(Osszesites kimutat, String tipus) {
    return Card(
      color: kimutat.kulonbozet() >= 0 ? Colors.green[300] : Colors.red[300],
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                "$tipus átlag",
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                "Bevétel: ${kimutat.bevetel} Ft",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text("Kiadás: ${kimutat.kiadas} Ft",
                  style: TextStyle(fontSize: 18.0)),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text("Különbözet: ${kimutat.kulonbozet()} Ft",
                  style: TextStyle(fontSize: 18.0)),
            )
          ],
        ),
      ),
    );
  }
}
