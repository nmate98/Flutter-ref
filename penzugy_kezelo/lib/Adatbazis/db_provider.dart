import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:penzugy_kezelo/Modellek/Kategoria.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:penzugy_kezelo/Modellek/Adat.dart';

class DbProvider {
  DbProvider._();

  static final DbProvider db = DbProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    return await openDatabase(
        join(await getDatabasesPath(), "finance_database.Db"),
        onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE adatok(
        ID INTEGER PRIMARY KEY,
        Kategoria TEXT NOT NULL,
        Osszeg INTEGER NOT NULL,
        Leiras TEXT NOT NULL,
        Datum TEXT NOT NULL,
        Ev INTEGER NOT NULL,
        Honap INTEGER NOT NULL,
        Het INTEGER NOT NULL,
        FOREIGN KEY (Kategoria)
          REFERENCES kategoriak (ID)
        )
        ''');
      await db.execute('''
        CREATE TABLE kategoriak(
        ID INTEGER PRIMARY KEY,
        Nev TEXT NOT NULL UNIQUE,
        Tipus INTEGER NOT NULL
        )
        ''');
      List<Kategoria> kategoria = [
        Kategoria(nev: "Élelmiszer", tipus: 1),
        Kategoria(nev: "Számla", tipus: 1),
        Kategoria(nev: "Szórakozás", tipus: 1),
        Kategoria(nev: "Elektronika", tipus: 1),
        Kategoria(nev: "Kozmetikum", tipus: 1),
        Kategoria(nev: "Egyéb kiadás", tipus: 1),
        Kategoria(nev: "Fizetés", tipus: 0),
        Kategoria(nev: "Ajándék", tipus: 0),
        Kategoria(nev: "Nyeremény", tipus: 0),
        Kategoria(nev: "Egyéb bevétel", tipus: 0),
      ];
      for (int index = 0; index < kategoria.length; index++) {
        await db.execute('''INSERT INTO kategoriak(Nev, Tipus)
                VALUES (?, ?)
            ''', [kategoria[index].nev, kategoria[index].tipus]);
      }
    }, version: 1);
  }

  ujAdat(Adat ujadat) async {
    final db = await database;
    var res = await db.rawInsert('''
    INSERT INTO adatok( Kategoria, Osszeg, Leiras, Datum, Honap,  Het, Ev)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', [
      ujadat.kategoria,
      ujadat.osszeg,
      ujadat.leiras,
      ujadat.datum,
      ujadat.honap,
      ujadat.het,
      ujadat.ev
    ]);
    return res;
  }

  ujKategoria(Kategoria kategoria) async {
    final db = await database;
    var res = await db.rawInsert('''
    INSERT INTO kategoriak(Nev, Tipus)
    VALUES (?, ?)
    ''', [kategoria.nev, kategoria.tipus]);
    return res;
  }

  Future<int> countKategoria() async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT Count(*) as db FROM kategoriak
    ''');
    return res[0]["db"];
  }

  Future<dynamic> osszesKategoria() async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT ID, Nev, Tipus FROM kategoriak
    ''');
    return res;
  }

  Future<dynamic> napiBevetel() async {
    final db = await database;
    String ma = DateFormat.yMd().format(DateTime.now());
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as bevetel FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.Datum = ? AND k.tipus = 0
    ''', [ma]);
    return res[0]["bevetel"] == null ? 0 : res[0]["bevetel"];
  }

  Future<dynamic> napiKiadas() async {
    final db = await database;
    String ma = DateFormat.yMd().format(DateTime.now());
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as kiadas FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.Datum = ? AND k.tipus = 1
    ''', [ma]);
    return res[0]["kiadas"] == null ? 0 : res[0]["kiadas"];
  }

  Future<dynamic> hetiBevetel() async {
    final db = await database;
    int het = Jiffy().week;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as bevetel FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.het = ? AND a.ev = ? AND k.tipus = 0
    ''', [het, ev]);
    return res[0]["bevetel"] == null ? 0 : res[0]["bevetel"];
  }

  Future<dynamic> hetiKiadas() async {
    final db = await database;
    int het = Jiffy().week;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as kiadas FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.het = ? AND a.ev = ? AND k.tipus = 1
    ''', [het, ev]);
    return res[0]["kiadas"] == null ? 0 : res[0]["kiadas"];
  }

  Future<dynamic> haviBevetel() async {
    final db = await database;
    int honap = Jiffy().month;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as bevetel FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.Honap = ? AND a.ev = ? AND k.tipus = 0
    ''', [honap, ev]);
    return res[0]["bevetel"] == null ? 0 : res[0]["bevetel"];
  }

  Future<dynamic> haviKiadas() async {
    final db = await database;
    int honap = Jiffy().month;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as kiadas FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.Honap = ? AND a.ev = ? AND k.tipus = 1
    ''', [honap, ev]);
    return res[0]["kiadas"] == null ? 0 : res[0]["kiadas"];
    ;
  }

  Future<dynamic> haviNapiReszletesBevetel() async {
    final db = await database;
    int honap = Jiffy().month;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as r_bevetel, Datum FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.Honap = ? AND a.ev = ? AND k.tipus = 0 GROUP BY a.Datum 
    ''', [honap, ev]);
    return res;
  }

  Future<dynamic> haviNapiReszletesBevetelDb() async {
    final db = await database;
    int honap = Jiffy().month;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT Datum FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.Honap = ? AND a.ev = ? AND k.tipus = 0 GROUP BY a.Datum  
    ''', [honap, ev]);
    return res.length;
  }

  Future<dynamic> haviNapiReszletesKiadas() async {
    final db = await database;
    int honap = Jiffy().month;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as r_kiadas, Datum FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.Honap = ? AND a.ev = ? AND k.tipus = 1 GROUP BY a.Datum 
    ''', [honap, ev]);
    return res;
  }

  Future<dynamic> haviNapiReszletesKiadasDb() async {
    final db = await database;
    int honap = Jiffy().month;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT Datum FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.Honap = ? AND a.ev = ? AND k.tipus = 1 GROUP BY a.Datum  
    ''', [honap, ev]);
    return res.length;
  }

  Future<dynamic> eviHetiReszletesBevetel() async {
    final db = await database;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as r_bevetel, Het FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.ev = ? AND k.tipus = 0 GROUP BY a.Het 
    ''', [ev]);
    return res;
  }

  Future<dynamic> eviHetiReszletesBevetelDb() async {
    final db = await database;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT Datum FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where  a.ev = ? AND k.tipus = 0 GROUP BY a.Het 
    ''', [ev]);
    return res.length;
  }

  Future<dynamic> eviHetiReszletesKiadas() async {
    final db = await database;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as r_kiadas, Het  FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.ev = ? AND k.tipus = 1 GROUP BY a.Het 
    ''', [ev]);
    return res;
  }

  Future<dynamic> eviHetiReszletesKiadasDb() async {
    final db = await database;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT Datum FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where  a.ev = ? AND k.tipus = 1 GROUP BY a.Het 
    ''', [ev]);
    return res.length;
  }

  Future<dynamic> eviHaviReszletesBevetel() async {
    final db = await database;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as r_bevetel, Honap  FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where  a.ev = ? AND k.tipus = 0 GROUP BY a.Honap 
    ''', [ev]);
    return res;
  }

  Future<dynamic> eviHaviReszletesBevetelDb() async {
    final db = await database;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT Datum  FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where  a.ev = ? AND k.tipus = 0 GROUP BY a.Honap 
    ''', [ev]);
    return res.length;
  }

  Future<dynamic> eviHaviReszletesKiadas() async {
    final db = await database;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as r_kiadas, Honap FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where  a.ev = ? AND k.tipus = 1 GROUP BY a.Honap 
    ''', [ev]);
    return res;
  }

  Future<dynamic> eviHaviReszletesKiadasDb() async {
    final db = await database;
    int ev = Jiffy().year;
    var res = await db.rawQuery('''
    SELECT Datum FROM adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where  a.Ev = ? AND k.Tipus = 1 GROUP BY a.Honap 
    ''', [ev]);
    return res.length;
  }

  Future<dynamic> napiKategoriaOsszesit(String datum) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as k_ossz, k.Nev, k.Tipus from adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.Datum = ? GROUP BY a.Kategoria
    ''', [datum]);
    return res;
  }

  Future<dynamic> napiKategoriaOsszesitDb(String datum) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT Kategoria from adatok where Datum = ? GROUP BY kategoria
    ''', [datum]);
    return res.length;
  }

  Future<dynamic> hetiKategoriaOsszesit({int ev, int het}) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as k_ossz, k.Nev, k.Tipus from adatok  a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.ev = ? AND a.het = ? GROUP BY a.Kategoria
    ''', [ev, het]);
    return res;
  }

  Future<dynamic> hetiKategoriaOsszesitDb({int ev, int het}) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT Kategoria from adatok where ev = ? AND het = ? GROUP BY kategoria
    ''', [ev, het]);
    return res.length;
  }

  Future<dynamic> haviKategoriaOsszesit({int ev, int honap}) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT SUM(Osszeg) as k_ossz, k.Nev, k.Tipus from adatok  a INNER JOIN kategoriak k on a.Kategoria = k.ID where a.ev = ? AND a.honap = ? GROUP BY a.Kategoria
    ''', [ev, honap]);
    return res;
  }

  Future<dynamic> haviKategoriaOsszesitDb({int ev, int honap}) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT Kategoria from adatok where ev = ? AND honap = ? GROUP BY kategoria
    ''', [ev, honap]);
    return res.length;
  }

  Future<dynamic> napiKategoriaBontas({String datum, String kategoria}) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT Leiras, osszeg, datum from adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where k.nev = ? AND datum = ?
    ''',[kategoria, datum]);
    return res;
  }

  Future<dynamic> napiKategoriaBontasDb({String datum, String kategoria}) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT Leiras from adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where k.nev = ? AND datum = ?
    ''',[kategoria, datum]);
    return res.length;
  }

  Future<dynamic> hetiKategoriaBontas({int ev, int het, String kategoria}) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT Leiras, osszeg, datum from adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where k.nev = ? AND a.ev = ? AND a.het = ?
    ''',[kategoria, ev, het]);
    return res;
  }

  Future<dynamic> hetiKategoriaBontasDb({int ev, int het, String kategoria}) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT Leiras from adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where k.nev = ? AND a.ev = ? AND a.het = ?
    ''',[kategoria, ev, het]);
    return res.length;
  }

  Future<dynamic> haviKategoriaBontas({int ev, int honap, String kategoria}) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT Leiras, osszeg, datum from adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where k.nev = ? AND a.ev = ? AND a.honap = ?
    ''',[kategoria, ev, honap]);
    return res;
  }

  Future<dynamic> haviKategoriaBontasDb({int ev, int honap, String kategoria}) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT Leiras from adatok a INNER JOIN kategoriak k on a.Kategoria = k.ID where k.nev = ? AND a.ev = ? AND a.honap = ?
    ''',[kategoria, ev , honap]);
    return res.length;
  }
}
