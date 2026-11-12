import 'package:flutter/material.dart';

import '../control/control_ingrediente.dart';
import '../model/ingrediente.dart';
import '../widgets/cores.dart';
import '../widgets/widget_button.dart';
import '../widgets/widget_cartao.dart';
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
        Cartao(Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputTextos("Buscar ingrediente", "Deixe vazio para ver todos", controller: _busca),
            SizedBox(height: 12),
            Buttons("Consultar", onPressed: _consultar),
          ],
        )),
        TextosCustom("Ingredientes", 18, Cores.texto, negrito: true),
        TextosCustom("Toque em um item para editar. Em vermelho com ⚠: abaixo do estoque mínimo, hora de repor.", 13,
            Cores.textoSuave),
        SizedBox(height: 10),
        Cartao(
          Row(
            children: [
              Expanded(flex: 3, child: TextosCustom("Ingrediente", 14, Cores.texto, negrito: true)),
              Expanded(flex: 2, child: TextosCustom("Tem", 14, Cores.texto, negrito: true)),
              Expanded(flex: 2, child: TextosCustom("Mínimo (alerta)", 14, Cores.texto, negrito: true)),
            ],
          ),
          cor: Cores.cabecalho,
        ),
        Column(children: _itens),
        SizedBox(height: 8),
        Cartao(Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextosCustom("Editar ou excluir", 18, Cores.texto, negrito: true),
            SizedBox(height: 12),
            InputTextos("Nome do ingrediente", "Ex.: arroz", controller: _nome),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InputTextos("Quantidade", "Ex.: 3", controller: _quantidade),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: InputTextos("Unidade", "kg, g, l, un", controller: _unidade),
                ),
              ],
            ),
            SizedBox(height: 10),
            InputTextos("Estoque mínimo (alerta)", "Ex.: 1", controller: _minimo),
            SizedBox(height: 6),
            TextosCustom(
                "É o quanto você quer ter sempre em casa. Quando o estoque ficar abaixo "
                "desse valor, o app avisa em vermelho com ⚠ na Despensa e na Lista de compras. "
                "Ex.: mínimo 1 kg de feijão → aviso quando tiver menos de 1 kg. "
                "Deixe em branco para não receber aviso.",
                13, Cores.textoSuave),
            SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: Buttons("Atualizar", onPressed: _atualizar)),
                SizedBox(width: 10),
                Expanded(child: Buttons("Excluir", onPressed: _excluir)),
              ],
            ),
          ],
        )),
        TextosCustom(_mensagem, 16, Cores.secundaria, negrito: true, centralizado: true),
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
      Color cor = baixo ? Cores.alerta : Cores.texto;
      _itens.add(InkWell(
        onTap: () {
          // preenche os campos de edicao com o item tocado
          _nome.text = element['nome'];
          _quantidade.text = Ingrediente.formatar(element['quantidade']);
          _unidade.text = element['unidade'];
          _minimo.text = Ingrediente.formatar(element['minimo']);
        },
        child: Cartao(
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: TextosCustom((baixo ? "⚠ " : "") + list[index]['nome'], 16, cor,
                      negrito: baixo)),
              Expanded(
                  flex: 2,
                  child: TextosCustom(
                      Ingrediente.formatar(list[index]['quantidade']) + " " + list[index]['unidade'],
                      16, cor)),
              Expanded(
                  flex: 2,
                  child: TextosCustom(Ingrediente.formatar(list[index]['minimo']), 16, cor)),
            ],
          ),
          cor: baixo ? Cores.fundoAlerta : Cores.cartao,
        ),
      ));
      index++;
    });
    if (list.length == 0) {
      _itens.add(TextosCustom("Nenhum ingrediente encontrado.", 15, Cores.textoSuave,
          centralizado: true));
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
