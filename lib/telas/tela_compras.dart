import 'package:flutter/material.dart';

import '../control/control_cardapio.dart';
import '../control/control_ingrediente.dart';
import '../model/ingrediente.dart';
import '../widgets/cores.dart';
import '../widgets/widget_button.dart';
import '../widgets/widget_cartao.dart';
import '../widgets/widget_text_custom.dart';

// RF08 - lista de compras / RF07 - itens abaixo do minimo
class TelaCompras extends StatefulWidget {
  @override
  State<TelaCompras> createState() => _TelaComprasState();
}

class _TelaComprasState extends State<TelaCompras> {
  List<Widget> _compras = [];
  List<Widget> _baixos = [];

  @override
  void initState() {
    super.initState();
    _gerar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de compras"),
      ),
      body: _body(),
    );
  }

  _body() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Buttons("Atualizar lista", onPressed: _gerar),
        SizedBox(height: 16),
        TextosCustom("Para o cardápio da semana", 18, Cores.texto, negrito: true),
        TextosCustom("Conta só os pratos ainda não preparados.", 13, Cores.textoSuave),
        SizedBox(height: 10),
        Cartao(
          Row(
            children: [
              Expanded(flex: 3, child: TextosCustom("Ingrediente", 14, Cores.texto, negrito: true)),
              Expanded(flex: 2, child: TextosCustom("Comprar", 14, Cores.texto, negrito: true)),
            ],
          ),
          cor: Cores.cabecalho,
        ),
        Column(children: _compras),
        SizedBox(height: 16),
        TextosCustom("Abaixo do estoque mínimo", 18, Cores.texto, negrito: true),
        TextosCustom("Ingredientes com menos do que você quer ter em casa. Vale repor mesmo sem estar no cardápio.", 13, Cores.textoSuave),
        SizedBox(height: 10),
        Cartao(
          Row(
            children: [
              Expanded(flex: 3, child: TextosCustom("Ingrediente", 14, Cores.texto, negrito: true)),
              Expanded(flex: 2, child: TextosCustom("Tem / mínimo", 14, Cores.texto, negrito: true)),
            ],
          ),
          cor: Cores.cabecalho,
        ),
        Column(children: _baixos),
      ],
    );
  }

  _gerar() async {
    var controlCardapio = new ControlCardapio();
    List<Map<String, dynamic>> list = await controlCardapio.queryListaCompras();
    _compras = [];
    int index = 0;
    list.forEach((element) {
      _compras.add(Cartao(Row(
        children: [
          Expanded(
              flex: 3,
              child: TextosCustom(list[index]['nome'], 16, Cores.texto, negrito: true)),
          Expanded(
              flex: 2,
              child: TextosCustom(
                  Ingrediente.formatar(list[index]['comprar']) + " " + list[index]['unidade'],
                  16, Cores.primaria, negrito: true)),
        ],
      )));
      index++;
    });
    if (list.length == 0) {
      _compras.add(TextosCustom("Nada a comprar para o cardápio. ✓", 15, Cores.secundaria,
          centralizado: true));
    }

    var controlIngrediente = new ControlIngrediente();
    List<Map<String, dynamic>> baixos = await controlIngrediente.queryEstoqueBaixo();
    _baixos = [];
    index = 0;
    baixos.forEach((element) {
      _baixos.add(Cartao(
        Row(
          children: [
            Expanded(
                flex: 3,
                child: TextosCustom("⚠ " + baixos[index]['nome'], 16, Cores.alerta,
                    negrito: true)),
            Expanded(
                flex: 2,
                child: TextosCustom(
                    Ingrediente.formatar(baixos[index]['quantidade']) + " / " +
                        Ingrediente.formatar(baixos[index]['minimo']) + " " +
                        baixos[index]['unidade'],
                    16, Cores.alerta)),
          ],
        ),
        cor: Cores.fundoAlerta,
      ));
      index++;
    });
    if (baixos.length == 0) {
      _baixos.add(TextosCustom("Nenhum item abaixo do mínimo. ✓", 15, Cores.secundaria,
          centralizado: true));
    }
    setState(() {});
  }
}
