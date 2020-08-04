class Osszesites{
  String idoszak;
  int bevetel;
  int kiadas;

  Osszesites({this.bevetel, this.kiadas});
  Osszesites.idoszakkal({this.idoszak, this.bevetel, this.kiadas});

  int kulonbozet(){
    return bevetel - kiadas;
  }

}