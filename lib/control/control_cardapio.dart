import 'package:sqflite/sqflite.dart';

import '../model/cardapio.dart';

class ControlCardapio {
  static final _databaseName = "cardapio.db";
  static Database? database;

  ControlCardapio();

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

  // RF05 - coloca o prato no dia/refeicao (substitui o que tinha)
  // retorna -1 se o prato nao existe
  Future<int> insertDatabase(Cardapio cardapio) async {
    Database db = await startDatabase();
    try {
      List<Map<String, dynamic>> prato = await db.rawQuery(
          "SELECT id FROM prato WHERE nome = '" + cardapio.nomePrato + "'");
      if (prato.length == 0) {
        return -1;
      }
      await db.rawDelete("DELETE FROM cardapio WHERE dia_semana = '" +
          cardapio.diaSemana + "' AND refeicao = '" + cardapio.refeicao + "'");
      String sql = "INSERT INTO cardapio (dia_semana, refeicao, id_prato, preparado) VALUES ('" +
          cardapio.diaSemana + "', '" +
          cardapio.refeicao + "', " +
          prato[0]['id'].toString() + ", 0)";
      return await db.rawInsert(sql);
    } finally {
      //await db.close();
    }
  }

  // consulta a semana inteira
  Future<List<Map<String, dynamic>>> queryFind() async {
    Database db = await startDatabase();
    try {
      return await db.rawQuery(
          "SELECT c.id, c.dia_semana, c.refeicao, c.preparado, p.nome AS prato "
          "FROM cardapio c JOIN prato p ON p.id = c.id_prato");
    } finally {
      //await db.close();
    }
  }

  // RF06 - marca como preparado e desconta da despensa
  // retorna -1 se nao tem prato nesse dia/refeicao, -2 se ja foi preparado
  Future<int> marcarPreparado(String dia, String refeicao) async {
    Database db = await startDatabase();
    try {
      List<Map<String, dynamic>> itens = await db.rawQuery(
          "SELECT id, id_prato, preparado FROM cardapio WHERE dia_semana = '" +
              dia + "' AND refeicao = '" + refeicao + "'");
      if (itens.length == 0) {
        return -1;
      }
      if (itens[0]['preparado'] == 1) {
        return -2;
      }
      String idPrato = itens[0]['id_prato'].toString();
      List<Map<String, dynamic>> ingredientes = await db.rawQuery(
          "SELECT id_ingrediente, quantidade FROM prato_ingrediente WHERE id_prato = " + idPrato);
      // for em vez de forEach para esperar (await) cada desconto
      for (var element in ingredientes) {
        await db.rawUpdate("UPDATE ingrediente SET quantidade = MAX(quantidade - " +
            element['quantidade'].toString() +
            ", 0) WHERE id = " + element['id_ingrediente'].toString());
      }
      return await db.rawUpdate("UPDATE cardapio SET preparado = 1 WHERE id = " +
          itens[0]['id'].toString());
    } finally {
      //await db.close();
    }
  }

  // RF06 - antes de preparar: ingredientes que nao tem o suficiente na despensa
  // (lista vazia = pode preparar)
  Future<List<Map<String, dynamic>>> queryFaltaParaPreparar(
      String dia, String refeicao) async {
    Database db = await startDatabase();
    try {
      return await db.rawQuery(
          "SELECT i.nome, i.unidade, pi.quantidade - i.quantidade AS falta "
          "FROM cardapio c "
          "JOIN prato_ingrediente pi ON pi.id_prato = c.id_prato "
          "JOIN ingrediente i ON i.id = pi.id_ingrediente "
          "WHERE c.dia_semana = '" + dia + "' AND c.refeicao = '" + refeicao + "' "
          "AND pi.quantidade > i.quantidade "
          "ORDER BY i.nome");
    } finally {
      //await db.close();
    }
  }

  // RF06 - desfaz o preparado e devolve os ingredientes para a despensa
  // retorna -1 se nao tem prato nesse dia/refeicao, -2 se ainda nao foi preparado
  Future<int> desfazerPreparado(String dia, String refeicao) async {
    Database db = await startDatabase();
    try {
      List<Map<String, dynamic>> itens = await db.rawQuery(
          "SELECT id, id_prato, preparado FROM cardapio WHERE dia_semana = '" +
              dia + "' AND refeicao = '" + refeicao + "'");
      if (itens.length == 0) {
        return -1;
      }
      if (itens[0]['preparado'] == 0) {
        return -2;
      }
      String idPrato = itens[0]['id_prato'].toString();
      List<Map<String, dynamic>> ingredientes = await db.rawQuery(
          "SELECT id_ingrediente, quantidade FROM prato_ingrediente WHERE id_prato = " + idPrato);
      // for em vez de forEach para esperar (await) cada devolucao
      for (var element in ingredientes) {
        await db.rawUpdate("UPDATE ingrediente SET quantidade = quantidade + " +
            element['quantidade'].toString() +
            " WHERE id = " + element['id_ingrediente'].toString());
      }
      return await db.rawUpdate("UPDATE cardapio SET preparado = 0 WHERE id = " +
          itens[0]['id'].toString());
    } finally {
      //await db.close();
    }
  }

  // RF08 - o que falta comprar para os pratos ainda nao preparados
  Future<List<Map<String, dynamic>>> queryListaCompras() async {
    Database db = await startDatabase();
    try {
      return await db.rawQuery(
          "SELECT i.nome, i.unidade, i.quantidade, SUM(pi.quantidade) AS necessario, "
          "SUM(pi.quantidade) - i.quantidade AS comprar "
          "FROM cardapio c "
          "JOIN prato_ingrediente pi ON pi.id_prato = c.id_prato "
          "JOIN ingrediente i ON i.id = pi.id_ingrediente "
          "WHERE c.preparado = 0 "
          "GROUP BY i.id, i.nome, i.unidade, i.quantidade "
          "HAVING SUM(pi.quantidade) > i.quantidade "
          "ORDER BY i.nome");
    } finally {
      //await db.close();
    }
  }

  // apaga o cardapio da semana para montar outro
  Future<int> limparSemana() async {
    Database db = await startDatabase();
    try {
      return await db.rawDelete("DELETE FROM cardapio");
    } finally {
      //await db.close();
    }
  }
}
