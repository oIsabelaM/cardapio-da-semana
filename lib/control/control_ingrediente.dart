import 'package:sqflite/sqflite.dart';

import '../model/ingrediente.dart';

class ControlIngrediente {
  static final _databaseName = "cardapio.db";
  static Database? database;

  ControlIngrediente();

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

  // RF01 / RF02 - se o ingrediente ja existe, soma a quantidade
  Future<int> insertDatabase(Ingrediente ingrediente) async {
    Database db = await startDatabase();
    try {
      List<Map<String, dynamic>> existe = await db.rawQuery(
          "SELECT * FROM ingrediente WHERE nome = '" + ingrediente.nome + "'");
      if (existe.length > 0) {
        String sqlSoma = "UPDATE ingrediente SET quantidade = quantidade + " +
            ingrediente.quantidade.toString() +
            ", unidade = '" + ingrediente.unidade +
            "', minimo = " + ingrediente.minimo.toString() +
            " WHERE nome = '" + ingrediente.nome + "'";
        return await db.rawUpdate(sqlSoma);
      }
      String sql = "INSERT INTO ingrediente (nome, quantidade, unidade, minimo) VALUES ('" +
          ingrediente.nome + "', " +
          ingrediente.quantidade.toString() + ", '" +
          ingrediente.unidade + "', " +
          ingrediente.minimo.toString() + ")";
      return await db.rawInsert(sql);
    } finally {
      //await db.close();
    }
  }

  // RF03 - consulta (vazio traz todos)
  Future<List<Map<String, dynamic>>> queryFind(String nome) async {
    Database db = await startDatabase();
    try {
      return await db.rawQuery(
          "SELECT * FROM ingrediente WHERE nome like '%" + nome + "%' ORDER BY nome");
    } finally {
      //await db.close();
    }
  }

  // RF07 - ingredientes abaixo do minimo
  Future<List<Map<String, dynamic>>> queryEstoqueBaixo() async {
    Database db = await startDatabase();
    try {
      return await db.rawQuery(
          "SELECT * FROM ingrediente WHERE quantidade < minimo ORDER BY nome");
    } finally {
      //await db.close();
    }
  }

  // RF03 - editar
  Future<int> updateDatabase(Ingrediente ingrediente) async {
    Database db = await startDatabase();
    try {
      String sql = "UPDATE ingrediente SET quantidade = " +
          ingrediente.quantidade.toString() +
          ", unidade = '" + ingrediente.unidade +
          "', minimo = " + ingrediente.minimo.toString() +
          " WHERE nome = '" + ingrediente.nome + "'";
      return await db.rawUpdate(sql);
    } finally {
      //await db.close();
    }
  }

  // RF03 - excluir (tambem tira o ingrediente dos pratos)
  Future<int> deleteDatabase(String nome) async {
    Database db = await startDatabase();
    try {
      await db.rawDelete(
          "DELETE FROM prato_ingrediente WHERE id_ingrediente IN "
          "(SELECT id FROM ingrediente WHERE nome = '" + nome + "')");
      return await db.rawDelete(
          "DELETE FROM ingrediente WHERE nome = '" + nome + "'");
    } finally {
      //await db.close();
    }
  }
}
