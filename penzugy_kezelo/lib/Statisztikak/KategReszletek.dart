import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:penzugy_kezelo/Adatbazis/db_provider.dart';
import 'package:penzugy_kezelo/Modellek/KategReszlet.dart';
import 'package:penzugy_kezelo/Modellek/Osszesites.dart';

class KategReszletek extends StatefulWidget {
  @override
  _KategReszletekState createState() => _KategReszletekState();
}

class _KategReszletekState extends State<KategReszletek> {
  List<KategReszlet> lista = [];
  Map data = {};

  loadkimutatas() async {
    switch (data['tipus']) {
      case 'napi':
        {
          int hossz;
          await DbProvider.db
              .napiKategoriaBontasDb(
                  datum: data["sql_datum"], kategoria: data["kategoria"])
              .then((value) => hossz = value);
          lista = List(hossz);
          await DbProvider.db
              .napiKategoriaBontas(
                  datum: data["sql_datum"], kategoria: data["kategoria"])
              .then((value) => {
                    for (int index = 0; index < hossz; index++)
                      {
                        setValue(
                            KategReszlet(
                                leiras: value[index]["Leiras"],
                                osszeg: value[index]["Osszeg"],
                                datum: value[index]["Datum"]),
                            index),
                      }
                  });
        }
        break;
      case 'heti':
        {
          int hossz;
          await DbProvider.db
              .hetiKategoriaBontasDb(
                  ev: int.parse(data["ev"]),
                  het: int.parse(data["het"]),
                  kategoria: data["kategoria"])
              .then((value) => hossz = value);
          lista = List(hossz);
          await DbProvider.db
              .hetiKategoriaBontas(
                  ev: int.parse(data["ev"]),
                  het: int.parse(data["het"]),
                  kategoria: data["kategoria"])
              .then((value) => {
                    for (int index = 0; index < hossz; index++)
                      {
                        setValue(
                            KategReszlet(
                                leiras: value[index]["Leiras"],
                                osszeg: value[index]["Osszeg"],
                                datum: value[index]["Datum"]),
                            index),
                      }
                  });
        }
        break;
      case 'havi':
        {
          int hossz;
          await DbProvider.db
              .haviKategoriaBontasDb(
                  ev: int.parse(data["ev"]),
                  honap: int.parse(data["honap"]),
                  kategoria: data["kategoria"])
              .then((value) => hossz = value);
          lista = List(hossz);
          await DbProvider.db
              .haviKategoriaBontas(
                  ev: int.parse(data["ev"]),
                  honap: int.parse(data["honap"]),
                  kategoria: data["kategoria"])
              .then((value) => {
                    for (int index = 0; index < hossz; index++)
                      {
                        setValue(
                            KategReszlet(
                                leiras: value[index]["Leiras"],
                                osszeg: value[index]["Osszeg"],
                                datum: value[index]["Datum"]),
                            index),
                      }
                  });
        }
        break;
    }
  }

  setValue(KategReszlet ertek, int index) {
    setState(() {
      lista[index] = ertek;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        data = ModalRoute.of(context).settings.arguments;
      });
      loadkimutatas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[500],
        title: Text(data['datum'] + ": " + data['kategoria']),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 4,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return buildCard(lista[index]);
              },
              childCount: lista.length,
            ),
          )
        ],
      ),
    );
  }

  Card buildCard(KategReszlet kimutat) {
    List<String> datumTomb = kimutat.datum.split("/");
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
              child: Text(
                "Leírás: ${kimutat.leiras}",
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5),
              )),
          Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
              child: Text("Összeg: ${kimutat.osszeg} Ft",
                  style: TextStyle(fontSize: 18.0))),
          Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
              child: Text(
                  "Dátum: ${datumTomb[2]}.${datumTomb[0]}.${datumTomb[1]}",
                  style: TextStyle(fontSize: 18.0)))
        ],
      ),
    );
  }
}
