import 'package:flutter/material.dart';
import 'package:penzugy_kezelo/Adatbazis/db_provider.dart';
import 'package:penzugy_kezelo/Modellek/StatReszlet.dart';

class StatReszletek extends StatefulWidget {
  @override
  _StatReszletekState createState() => _StatReszletekState();
}

class _StatReszletekState extends State<StatReszletek> {
  Map data = {};

  List<StatReszlet> lista = [];

  loadkimutatas() async {
    switch (data['tipus']) {
      case 'napi':
        {
          int hossz;
          await DbProvider.db
              .napiKategoriaOsszesitDb(data["sql_datum"])
              .then((value) => hossz = value);
          lista = List(hossz);
          await DbProvider.db
              .napiKategoriaOsszesit(data["sql_datum"])
              .then((value) => {
                    for (int index = 0; index < hossz; index++)
                      {
                        setValue(
                            StatReszlet(
                                kategoria: value[index]['Nev'],
                                osszeg: value[index]['k_ossz'],
                                tipus: value[index]['Tipus']),
                            index),
                      }
                  });
        }
        break;
      case 'heti':
        {
          int hossz;
          await DbProvider.db
              .hetiKategoriaOsszesitDb(
                  ev: int.parse(data["ev"]), het: int.parse(data["het"]))
              .then((value) => hossz = value);
          lista = List(hossz);
          await DbProvider.db
              .hetiKategoriaOsszesit(
                  ev: int.parse(data["ev"]), het: int.parse(data["het"]))
              .then((value) => {
                    for (int index = 0; index < hossz; index++)
                      {
                        setValue(
                            StatReszlet(
                                kategoria: value[index]['Nev'],
                                osszeg: value[index]['k_ossz'],
                                tipus: value[index]['Tipus']),
                            index),
                      }
                  });
        }
        break;
      case 'havi':
        {
          int hossz;
          await DbProvider.db
              .haviKategoriaOsszesitDb(
                  ev: int.parse(data["ev"]), honap: int.parse(data["honap"]))
              .then((value) => hossz = value);
          lista = List(hossz);
          await DbProvider.db
              .haviKategoriaOsszesit(
                  ev: int.parse(data["ev"]), honap: int.parse(data["honap"]))
              .then((value) => {
                    for (int index = 0; index < hossz; index++)
                      {
                        setValue(
                            StatReszlet(
                                kategoria: value[index]['Nev'],
                                osszeg: value[index]['k_ossz'],
                                tipus: value[index]['Tipus']),
                            index),
                      }
                  });
        }
        break;
    }
  }

  setValue(StatReszlet ertek, int index) {
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

  navigate(String datum, String kategoria) {
    print(datum+" "+kategoria);
    switch (data["tipus"]) {
      case 'napi':
        {
          Navigator.pushNamed(context, "/kategReszlet", arguments: {
            'tipus': 'napi',
            'datum' : datum,
            'sql_datum': data["sql_datum"],
            'kategoria': kategoria
          });
        }
        break;
      case 'heti':
        {
          List<String> datumTomb = datum.split(".");
          Navigator.pushNamed(context, "/kategReszlet", arguments: {
            'tipus': 'heti',
            'datum': datum,
            'ev': datumTomb[0],
            'het': datumTomb[1],
            'sql_datum': data["sql_datum"],
            'kategoria': kategoria
          });
        }
        break;
      case 'havi':
        {
          List<String> datumTomb = datum.split(".");
          Navigator.pushNamed(context, "/kategReszlet", arguments: {
            'tipus': 'havi',
            'datum': datum,
            'ev': datumTomb[0],
            'honap': datumTomb[1],
            'kategoria': kategoria
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(data["datum"]), backgroundColor: Colors.green[500]),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 5,
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

  GestureDetector buildCard(StatReszlet kimutat) {
    return GestureDetector(
      onTap: () {
        print(kimutat.kategoria);
        navigate(data["datum"], kimutat.kategoria);
      },
      child: Card(
        color: kimutat.tipus == 0 ? Colors.green[300] : Colors.red[300],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: Text(
                  kimutat.kategoria,
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: Text("Összeg: ${kimutat.osszeg} Ft",
                    style: TextStyle(fontSize: 18.0))),
          ],
        ),
      ),
    );
  }
}
