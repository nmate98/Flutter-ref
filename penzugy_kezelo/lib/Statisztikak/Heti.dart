import 'package:flutter/material.dart';
import 'package:penzugy_kezelo/Modellek/Osszesites.dart';
import 'package:penzugy_kezelo/Adatbazis/db_provider.dart';
import 'package:jiffy/jiffy.dart';

class Heti extends StatefulWidget {
  @override
  _HetiState createState() => _HetiState();
}

class _HetiState extends State<Heti> {
  List<Osszesites> adatok;

  generate() async {
    adatok = List(52);
    for (int index = 0; index < adatok.length; index++) {
      adatok[index] = new Osszesites.idoszakkal(
          idoszak:
              Jiffy().year.toString() + "." + (index+1).toString() + ".hét",
          bevetel: 0,
          kiadas: 0);
    }

    await db_query();
  }

  Future<dynamic> db_query() async {
    int hossz = 0;
    int ertek = 0;
    int het = 0;
    await DbProvider.db
        .eviHetiReszletesBevetelDb()
        .then((value) => {hossz = value});
    await DbProvider.db.eviHetiReszletesBevetel().then((value) => {
          for (int index = 0; index < hossz; index++)
            {
              ertek = value[index]["r_bevetel"],
              het = value[index]["Het"],
              setValue(ertek, het - 1, 0),
            }
        });

    await DbProvider.db
        .eviHetiReszletesKiadasDb()
        .then((value) => {hossz = value});
    await DbProvider.db.eviHetiReszletesKiadas().then((value) => {
          for (int index = 0; index < hossz; index++)
            {
              ertek = value[index]["r_kiadas"],
              het = value[index]["Het"],
              setValue(ertek, het - 1, 1),
            }
        });
  }

  setValue(int ertek, int het, int tipus) {
    setState(() {
      if (tipus == 0) {
        adatok[het].bevetel = ertek;
      } else {
        adatok[het].kiadas = ertek;
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
      'tipus' : 'heti',
      'datum' : datum,
      'ev' : datumTomb[0],
      'het' :datumTomb[1]
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
            childCount: 52,
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
        color: kimutat.kulonbozet()>=0 ? Colors.green[300] : Colors.red[300],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: Text(kimutat.idoszak,style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5),
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: Text("Bevétel: ${kimutat.bevetel} Ft", style: TextStyle(fontSize: 18.0))),
            Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: Text("Kiadás: ${kimutat.kiadas} Ft", style: TextStyle(fontSize: 18.0))),
            Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: Text("Különbözet: ${kimutat.kulonbozet()} Ft", style: TextStyle(fontSize: 18.0)))
          ],
        ),
      ),
    );
  }

}

