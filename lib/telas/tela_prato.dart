import 'package:flutter/material.dart';

import '../control/control_prato.dart';
import '../model/ingrediente.dart';
import '../model/prato.dart';
import '../widgets/cores.dart';
import '../widgets/widget_button.dart';
import '../widgets/widget_cartao.dart';
import '../widgets/widget_input.dart';
import '../widgets/widget_text_custom.dart';

// RF04 - cadastrar prato com ingredientes
class TelaPrato extends StatefulWidget {
  @override
  State<TelaPrato> createState() => _TelaPratoState();
}

class _TelaPratoState extends State<TelaPrato> {
  final _nomePrato = TextEditingController();
  final _ingrediente = TextEditingController();
  final _quantidade = TextEditingController();

  List<Widget> _itens = [];
  String _mensagem = "";
  String _confirmarExclusao = ""; // nome que espera o segundo toque em Excluir

  @override
  void initState() {
    super.initState();
    _consultar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pratos"),
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
            TextosCustom("Prato", 18, Cores.texto, negrito: true),
            SizedBox(height: 12),
            InputTextos("Nome do prato", "Ex.: arroz com feijão", controller: _nomePrato),
            SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: Buttons("Cadastrar", onPressed: _cadastrar)),
                SizedBox(width: 10),
                Expanded(
                    child: Buttons(_confirmarExclusao == "" ? "Excluir" : "Confirmar",
                        onPressed: _excluir)),
              ],
            ),
          ],
        )),
        Cartao(Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextosCustom("Ingredientes do prato", 18, Cores.texto, negrito: true),
            SizedBox(height: 4),
            TextosCustom(
                "Pode adicionar direto: se o prato ainda não existir, ele é cadastrado junto. "
                "O ingrediente precisa estar na despensa. Na quantidade, pode escrever a "
                "unidade (ex.: 500 g ou 0,5 kg).",
                13, Cores.textoSuave),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: InputTextos("Ingrediente", "Ex.: arroz", controller: _ingrediente),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: InputTextos("Qtd.", "Ex.: 500 g", controller: _quantidade),
                ),
              ],
            ),
            SizedBox(height: 14),
            Buttons("Adicionar ingrediente", onPressed: _adicionarIngrediente),
          ],
        )),
        TextosCustom(_mensagem, 16, Cores.secundaria, negrito: true, centralizado: true),
        SizedBox(height: 12),
        TextosCustom("Pratos cadastrados", 18, Cores.texto, negrito: true),
        TextosCustom("Toque em um prato para selecioná-lo.", 13, Cores.textoSuave),
        SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _itens,
        ),
      ],
    );
  }

  _cadastrar() async {
    String nome = Ingrediente.limpar(_nomePrato.text);
    if (nome == "") {
      setState(() {
        _mensagem = "Informe o nome do prato.";
      });
      return;
    }
    var control = new ControlPrato();
    int id = await control.insertDatabase(Prato(nome: nome));
    _mensagem = id > 0
        ? "Prato \"$nome\" cadastrado! Agora adicione os ingredientes."
        : "O prato \"$nome\" já existe.";
    _consultar();
  }

  _adicionarIngrediente() async {
    String prato = Ingrediente.limpar(_nomePrato.text);
    String ingrediente = Ingrediente.limpar(_ingrediente.text);
    // separa o numero da unidade: "500gr" -> 500 e "g"
    String textoQtd = _quantidade.text.trim().toLowerCase();
    double quantidade =
        Ingrediente.lerNumero(textoQtd.replaceAll(RegExp(r'[^0-9.,]'), ""));
    String unidade =
        Ingrediente.normalizarUnidade(textoQtd.replaceAll(RegExp(r'[0-9.,\s]'), ""));
    if (prato == "" || ingrediente == "" || quantidade <= 0) {
      setState(() {
        _mensagem = "Preencha o prato, o ingrediente e a quantidade (ex.: 0,5 ou 500 g).";
      });
      return;
    }
    var control = new ControlPrato();
    int resultado =
        await control.insertIngrediente(prato, ingrediente, quantidade, unidade);
    if (resultado == -2) {
      _mensagem = "\"$ingrediente\" não está na despensa. Cadastre-o primeiro em Cadastrar ingrediente.";
    } else if (resultado == -3) {
      _mensagem = "A unidade \"$unidade\" não combina com a do ingrediente na despensa. "
          "Use a mesma unidade (ou g/kg, ml/l).";
    } else {
      _mensagem = "\"$ingrediente\" adicionado em \"$prato\".";
      _ingrediente.text = "";
      _quantidade.text = "";
    }
    _consultar();
  }

  _excluir() async {
    String nome = Ingrediente.limpar(_nomePrato.text);
    if (nome == "") {
      setState(() {
        _mensagem = "Informe o nome do prato.";
      });
      return;
    }
    // primeiro toque so pede confirmacao
    if (_confirmarExclusao != nome) {
      setState(() {
        _confirmarExclusao = nome;
        _mensagem = "Excluir o prato \"$nome\"? Toque em Confirmar para excluir de vez.";
      });
      return;
    }
    _confirmarExclusao = "";
    var control = new ControlPrato();
    int excluidos = await control.deleteDatabase(nome);
    _mensagem = excluidos > 0 ? "Prato \"$nome\" excluído!" : "Prato \"$nome\" não encontrado.";
    _consultar();
  }

  _consultar() async {
    _confirmarExclusao = ""; // qualquer outra acao cancela o pedido de confirmacao
    var control = new ControlPrato();
    List<Map<String, dynamic>> list = await control.queryFind("");
    _itens = [];
    String pratoAtual = "";
    List<Widget> linhas = [];
    int index = 0;
    list.forEach((element) {
      if (list[index]['prato'] != pratoAtual) {
        if (pratoAtual != "") {
          _itens.add(_cartaoPrato(pratoAtual, linhas));
        }
        pratoAtual = list[index]['prato'];
        linhas = [];
      }
      if (list[index]['ingrediente'] != null) {
        linhas.add(TextosCustom(
            "• " + list[index]['ingrediente'] + ": " +
                Ingrediente.formatar(list[index]['quantidade']) + " " +
                list[index]['unidade'],
            15, Cores.texto));
      } else {
        linhas.add(TextosCustom("(sem ingredientes)", 15, Cores.textoSuave));
      }
      index++;
    });
    if (pratoAtual != "") {
      _itens.add(_cartaoPrato(pratoAtual, linhas));
    }
    if (list.length == 0) {
      _itens.add(TextosCustom("Nenhum prato cadastrado.", 15, Cores.textoSuave,
          centralizado: true));
    }
    setState(() {});
  }

  // um cartao por prato, com o nome e a lista de ingredientes
  Widget _cartaoPrato(String nome, List<Widget> linhas) {
    return InkWell(
      onTap: () {
        _nomePrato.text = nome;
      },
      child: Cartao(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextosCustom(nome, 17, Cores.primaria, negrito: true),
          SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: linhas,
          ),
        ],
      )),
    );
  }
}
