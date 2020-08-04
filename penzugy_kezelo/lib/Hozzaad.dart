import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:penzugy_kezelo/Adatbazis/db_provider.dart';
import 'package:penzugy_kezelo/Modellek/Kategoria.dart';
import 'package:penzugy_kezelo/Modellek/Adat.dart';

class Hozzaad extends StatefulWidget {
  @override
  _HozzaadState createState() => _HozzaadState();
}

class _HozzaadState extends State<Hozzaad> {
  int tipus = 0;
  String selectedItem;
  final TextEditingController osszegcontroller = new TextEditingController();
  final TextEditingController leirascontroller = new TextEditingController();
  List<Kategoria> lista = [];
  Adat adat;
  List<DropdownMenuItem<String>> dropList = [];
  var key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    tipus = 0;
    loadCategories();
  }

  void loadData() {
    dropList.clear();
    for (int index = 0; index < lista.length; index++) {
      if (tipus == lista[index].tipus) {
        dropList.add(DropdownMenuItem(
          child: Text(lista[index].nev),
          value: lista[index].nev,
        ));
      }
    }
    selectedItem = dropList[0].value;
  }

  loadCategories() async {
    int hossz = lista.length;
    List<Kategoria> kat = [];
    if (hossz == 0) {
      await DbProvider.db.countKategoria().then((value) => {hossz = value});
      await DbProvider.db.osszesKategoria().then((value) {
        int index = 0;

        while (index < hossz) {
          kat.add(Kategoria.ID(
              id: value[index]["ID"],
              nev: value[index]["Nev"],
              tipus: value[index]["Tipus"]));
          index++;
        }
      });
    }
    lista = kat;
    selectRadioButton(0);
  }

  selectRadioButton(int val) {
    setState(() {
      tipus = val;
      loadData();
    });
  }

  int findListElement(String nev) {
    int index = 0;
    while (nev != lista[index].nev) {
      index++;
    }
    return lista[index].id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Új bevétel/kiadás"),
        backgroundColor: Colors.green[500],
      ),
      body: Form(
        key: key,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: leirascontroller,
                decoration: InputDecoration(hintText: "Leiras"),
                // ignore: missing_return
                validator: (String value) {
                  if (value.isEmpty) {
                    return "Ez a mező nem lehet üres!";
                  }
                },
              ),
              TextFormField(
                controller: osszegcontroller,
                decoration: InputDecoration(hintText: "Összeg"),
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                // ignore: missing_return
                validator: (String value) {
                  if (value.isEmpty) {
                    return "Ez a mező nem lehet üres!";
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Radio(
                            activeColor: Colors.green[500],
                            value: 0,
                            groupValue: tipus,
                            onChanged: (val) {
                              selectRadioButton(val);
                            }),
                        Text("Bevétel"),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Radio(
                            activeColor: Colors.green[500],
                            value: 1,
                            groupValue: tipus,
                            onChanged: (val) {
                              selectRadioButton(val);
                            }),
                        Text("Kiadás"),
                      ],
                    ),
                  )
                ],
              ),
              DropdownButton(
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    selectedItem = value;
                  });
                },
                items: dropList,
                value: selectedItem,
              ),
              FlatButton(
                onPressed: () {
                  setState(() {
                    if (key.currentState.validate()) {
                      adat = new Adat(
                        kategoria: findListElement(selectedItem),
                        osszeg: int.parse(osszegcontroller.text),
                        leiras: leirascontroller.text,
                        datum: Jiffy().yMd,
                        ev: Jiffy().year.toString(),
                        honap: Jiffy().month.toString(),
                        het: Jiffy().week.toString(),
                      );
                      DbProvider.db.ujAdat(adat);
                      osszegcontroller.text = "";
                      leirascontroller.text = "";
                      selectRadioButton(0);
                    }
                  });
                },
                child: Text(
                  "BEVITEL",
                  style: TextStyle(
                    color: Colors.green[500],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
