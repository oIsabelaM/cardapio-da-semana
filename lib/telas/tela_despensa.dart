import 'package:flutter/material.dart';

import '../control/control_ingrediente.dart';
import '../model/ingrediente.dart';
import '../widgets/widget_button.dart';
import '../widgets/widget_input.dart';
import '../widgets/widget_text_custom.dart';

// RF03 - manter despensa / RF07 - alertar estoque baixo
class TelaDespensa extends StatefulWidget {
  @override
  State<TelaDespensa> createState() => _TelaDespensaState();
}

class _TelaDespensaState extends State<TelaDespensa> {
  final _busca = TextEditingController();
  final _nome = TextEditingController();
  final _quantidade = TextEditingController();
  final _unidade = TextEditingController();
  final _minimo = TextEditingController();

  List<Widget> _itens = [];
  String _mensagem = "";

  @override
  void initState() {
    super.initState();
    _consultar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Despensa"),
      ),
      body: _body(),
    );
  }

  _body() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InputTextos("Buscar ingrediente", "Deixe vazio para ver todos", controller: _busca),
        Buttons("Consultar", onPressed: _consultar),
        TextosCustom("Em vermelho: abaixo do mínimo", 14, Colors.red),
        Row(
          children: [
            Expanded(flex: 3, child: TextosCustom("Ingrediente", 16, Colors.black)),
            Expanded(flex: 2, child: TextosCustom("Tem", 16, Colors.black)),
            Expanded(flex: 2, child: TextosCustom("Mínimo", 16, Colors.black)),
          ],
        ),
        Divider(),
        Column(children: _itens),
        Divider(),
        TextosCustom("Editar ou excluir", 20, Colors.black87),
        InputTextos("Nome do ingrediente", "Ex.: arroz", controller: _nome),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: InputTextos("Quantidade", "Ex.: 3", controller: _quantidade),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: InputTextos("Unidade", "kg, g, l, un", controller: _unidade),
            ),
          ],
        ),
        InputTextos("Quantidade mínima", "Ex.: 1", controller: _minimo),
        Row(
          children: [
            Expanded(child: Buttons("Atualizar", onPressed: _atualizar)),
            SizedBox(width: 12),
            Expanded(child: Buttons("Excluir", onPressed: _excluir)),
          ],
        ),
        TextosCustom(_mensagem, 16, Colors.black87),
      ],
    );
  }

  _consultar() async {
    var control = new ControlIngrediente();
    List<Map<String, dynamic>> list = await control.queryFind(Ingrediente.limpar(_busca.text));
    _itens = [];
    int index = 0;
    list.forEach((element) {
      bool baixo = list[index]['quantidade'] < list[index]['minimo'];
      Color cor = baixo ? Colors.red : Colors.black87;
      _itens.add(Row(
        children: [
          Expanded(flex: 3, child: TextosCustom(list[index]['nome'], 16, cor)),
          Expanded(
              flex: 2,
              child: TextosCustom(
                  Ingrediente.formatar(list[index]['quantidade']) + " " + list[index]['unidade'],
                  16, cor)),
          Expanded(
              flex: 2,
              child: TextosCustom(Ingrediente.formatar(list[index]['minimo']), 16, cor)),
        ],
      ));
      index++;
    });
    if (list.length == 0) {
      _itens.add(TextosCustom("Nenhum ingrediente encontrado.", 16, Colors.grey));
    }
    setState(() {});
  }

  _atualizar() async {
    String nome = Ingrediente.limpar(_nome.text);
    double quantidade = Ingrediente.lerNumero(_quantidade.text);
    double minimo = _minimo.text.trim() == "" ? 0 : Ingrediente.lerNumero(_minimo.text);
    if (nome == "" || quantidade < 0 || minimo < 0) {
      setState(() {
        _mensagem = "Preencha nome, quantidade e mínimo com números válidos.";
      });
      return;
    }
    var control = new ControlIngrediente();
    int alterados = await control.updateDatabase(Ingrediente(
      nome: nome,
      quantidade: quantidade,
      unidade: _unidade.text.trim() == "" ? "un" : Ingrediente.limpar(_unidade.text),
      minimo: minimo,
    ));
    _mensagem = alterados > 0 ? "\"$nome\" atualizado!" : "Ingrediente \"$nome\" não encontrado.";
    _consultar();
  }

  _excluir() async {
    String nome = Ingrediente.limpar(_nome.text);
    if (nome == "") {
      setState(() {
        _mensagem = "Informe o nome do ingrediente.";
      });
      return;
    }
    var control = new ControlIngrediente();
    int excluidos = await control.deleteDatabase(nome);
    _mensagem = excluidos > 0 ? "\"$nome\" excluído!" : "Ingrediente \"$nome\" não encontrado.";
    _consultar();
  }
}
