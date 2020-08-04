import 'package:flutter/material.dart';
import 'package:penzugy_kezelo/Modellek/Osszesites.dart';
import 'package:penzugy_kezelo/Adatbazis/db_provider.dart';
import 'package:jiffy/jiffy.dart';

class Havi extends StatefulWidget {
  @override
  _HaviState createState() => _HaviState();
}

class _HaviState extends State<Havi> {
  List<Osszesites> adatok;

  generate() async {
    adatok = List(12);
    for (int index = 0; index < adatok.length; index++) {
      adatok[index] = new Osszesites.idoszakkal(
          idoszak:
          Jiffy().year.toString() + "." + (index + 1).toString() + ".hó",
          bevetel: 0,
          kiadas: 0);
    }

    await db_query();
  }

  Future<dynamic> db_query() async {
    int hossz = 0;
    int ertek = 0;
    int honap = 0;
    await DbProvider.db
        .eviHaviReszletesBevetelDb()
        .then((value) => {hossz = value});
    await DbProvider.db.eviHaviReszletesBevetel().then((value) =>
    {
      for (int index = 0; index < hossz; index++)
        {
          ertek = value[index]["r_bevetel"],
          honap = value[index]["Honap"],
          setValue(ertek, honap - 1, 0),
        }
    });

    await DbProvider.db
        .eviHaviReszletesKiadasDb()
        .then((value) => {hossz = value});
    await DbProvider.db.eviHaviReszletesKiadas().then((value) =>
    {
      for (int index = 0; index < hossz; index++)
        {
          ertek = value[index]["r_kiadas"],
          honap = value[index]["Honap"],
          setValue(ertek, honap - 1, 1),
        }
    });
  }

  setValue(int ertek, int honap, int tipus) {
    setState(() {
      if (tipus == 0) {
        adatok[honap].bevetel = ertek;
      } else {
        adatok[honap].kiadas = ertek;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    generate();
  }

  navigate(String datum){
    List<String> datumTomb = datum.split(".");
    Navigator.pushNamed(context, "/statReszlet", arguments: {
      'tipus' : 'havi',
      'datum' : datum,
      'ev' : datumTomb[0],
      'honap' :datumTomb[1]
    });
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
            childCount: 12,
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