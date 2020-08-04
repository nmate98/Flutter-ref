import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:penzugy_kezelo/Adatbazis/db_provider.dart';
import 'package:penzugy_kezelo/Modellek/Osszesites.dart';

class Napi extends StatefulWidget {
  @override
  _NapiState createState() => _NapiState();
}

class _NapiState extends State<Napi> {
  List<Osszesites> adatok;

  generate() async {
    adatok = List(Jiffy().daysInMonth);
    for (int index = 0; index < adatok.length; index++) {
      adatok[index] = new Osszesites.idoszakkal(
          idoszak: Jiffy().year.toString() +
              "." +
              Jiffy().month.toString() +
              "." +
              (index + 1).toString(),
          bevetel: 0,
          kiadas: 0);
    }

    await db_query();
  }

  Future<dynamic> db_query() async {
    int hossz = 0;
    int ertek = 0;
    String datum = "";
    List<String> datumTomb = [];
    int nap = 0;
    await DbProvider.db
        .haviNapiReszletesBevetelDb()
        .then((value) => {hossz = value});
    await DbProvider.db.haviNapiReszletesBevetel().then((value) => {
          for (int index = 0; index < hossz; index++)
            {
              ertek = value[index]["r_bevetel"],
              datum = value[index]["Datum"],
              datumTomb = datum.split("/"),
              nap = int.parse(datumTomb[1]),
              setValue(ertek, nap - 1, 0),
            }
        });

    await DbProvider.db
        .haviNapiReszletesKiadasDb()
        .then((value) => {hossz = value});
    await DbProvider.db.haviNapiReszletesKiadas().then((value) => {
          for (int index = 0; index < hossz; index++)
            {
              ertek = value[index]["r_kiadas"],
              datum = value[index]["Datum"],
              datumTomb = datum.split("/"),
              nap = int.parse(datumTomb[1]),
              setValue(ertek, nap - 1, 1),
            }
        });
  }

  setValue(int ertek, int nap, int tipus) {
    setState(() {
      if (tipus == 0) {
        adatok[nap].bevetel = ertek;
      } else {
        adatok[nap].kiadas = ertek;
      }
    });
  }
  navigate(String datum){
    List<String> datumTomb = datum.split(".");
    String sqlDatum = datumTomb[1]+"/"+datumTomb[2]+"/"+datumTomb[0];
    Navigator.pushNamed(context, "/statReszlet", arguments: {
      'tipus' : 'napi',
      'datum' : datum,
      'sql_datum' :sqlDatum
    });
  }
  @override
  void initState() {
    super.initState();
    generate();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 500.0,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 3,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return buildCard(adatok[index]);
            },
            childCount: Jiffy().daysInMonth,
          ),
        )
      ],
    );
  }

  GestureDetector buildCard(Osszesites kimutat) {
    return GestureDetector(
      onTap: (){
        if(kimutat.bevetel != 0 && kimutat.kiadas != 0) {
          navigate(kimutat.idoszak);
        }
      },
      child: Card(
        color: kimutat.kulonbozet() >= 0 ? Colors.green[300] : Colors.red[300],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: Text(
                  kimutat.idoszak,
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: Text("Bevétel: ${kimutat.bevetel} Ft",
                    style: TextStyle(fontSize: 18.0))),
            Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: Text("Kiadás: ${kimutat.kiadas} Ft",
                    style: TextStyle(fontSize: 18.0))),
            Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: Text("Különbözet: ${kimutat.kulonbozet()} Ft",
                    style: TextStyle(fontSize: 18.0)))
          ],
        ),
      ),
    );
  }

}



