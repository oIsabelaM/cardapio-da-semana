import 'package:sqflite/sqflite.dart';

import '../model/prato.dart';

class ControlPrato {
  static final _databaseName = "cardapio.db";
  static Database? database;

  ControlPrato();

  Future startDatabase() async {
    if (database != null) {
      return database;
    }
    database = await _openOrCreateDatabase();
    return database;
  }

  Future _openOrCreateDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + _databaseName;
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE IF NOT EXISTS ingrediente ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "nome TEXT, quantidade REAL, unidade TEXT, minimo REAL)");
    await db.execute("CREATE TABLE IF NOT EXISTS prato ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT)");
    await db.execute("CREATE TABLE IF NOT EXISTS prato_ingrediente ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "id_prato INTEGER, id_ingrediente INTEGER, quantidade REAL)");
    await db.execute("CREATE TABLE IF NOT EXISTS cardapio ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "dia_semana TEXT, refeicao TEXT, id_prato INTEGER, preparado INTEGER)");
  }

  // RF04 - cadastra o prato (0 = ja existe)
  Future<int> insertDatabase(Prato prato) async {
    Database db = await startDatabase();
    try {
      List<Map<String, dynamic>> existe = await db.rawQuery(
          "SELECT * FROM prato WHERE nome = '" + prato.nome + "'");
      if (existe.length > 0) {
        return 0;
      }
      String sql = "INSERT INTO prato (nome) VALUES ('" + prato.nome + "')";
      return await db.rawInsert(sql);
    } finally {
      //await db.close();
    }
  }

  // RF04 - liga um ingrediente ao prato
  // retorna -1 se o prato nao existe, -2 se o ingrediente nao existe
  Future<int> insertIngrediente(
      String nomePrato, String nomeIngrediente, double quantidade) async {
    Database db = await startDatabase();
    try {
      List<Map<String, dynamic>> prato = await db.rawQuery(
          "SELECT id FROM prato WHERE nome = '" + nomePrato + "'");
      if (prato.length == 0) {
        return -1;
      }
      List<Map<String, dynamic>> ingrediente = await db.rawQuery(
          "SELECT id FROM ingrediente WHERE nome = '" + nomeIngrediente + "'");
      if (ingrediente.length == 0) {
        return -2;
      }
      String idPrato = prato[0]['id'].toString();
      String idIngrediente = ingrediente[0]['id'].toString();
      await db.rawDelete("DELETE FROM prato_ingrediente WHERE id_prato = " +
          idPrato + " AND id_ingrediente = " + idIngrediente);
      String sql = "INSERT INTO prato_ingrediente (id_prato, id_ingrediente, quantidade) VALUES (" +
          idPrato + ", " + idIngrediente + ", " + quantidade.toString() + ")";
      return await db.rawInsert(sql);
    } finally {
      //await db.close();
    }
  }

  // consulta pratos com os ingredientes (uma linha por ingrediente)
  Future<List<Map<String, dynamic>>> queryFind(String nome) async {
    Database db = await startDatabase();
    try {
      return await db.rawQuery(
          "SELECT p.nome AS prato, i.nome AS ingrediente, pi.quantidade, i.unidade "
          "FROM prato p "
          "LEFT JOIN prato_ingrediente pi ON pi.id_prato = p.id "
          "LEFT JOIN ingrediente i ON i.id = pi.id_ingrediente "
          "WHERE p.nome like '%" + nome + "%' ORDER BY p.nome, i.nome");
    } finally {
      //await db.close();
    }
  }

  // exclui o prato, seus ingredientes e onde ele estava no cardapio
  Future<int> deleteDatabase(String nome) async {
    Database db = await startDatabase();
    try {
      await db.rawDelete(
          "DELETE FROM prato_ingrediente WHERE id_prato IN "
          "(SELECT id FROM prato WHERE nome = '" + nome + "')");
      await db.rawDelete(
          "DELETE FROM cardapio WHERE id_prato IN "
          "(SELECT id FROM prato WHERE nome = '" + nome + "')");
      return await db.rawDelete("DELETE FROM prato WHERE nome = '" + nome + "'");
    } finally {
      //await db.close();
    }
  }
}
