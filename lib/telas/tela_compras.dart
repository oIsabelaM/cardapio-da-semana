import 'package:flutter/material.dart';

import '../control/control_cardapio.dart';
import '../control/control_ingrediente.dart';
import '../model/ingrediente.dart';
import '../widgets/widget_button.dart';
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
        TextosCustom("Para o cardápio da semana", 20, Colors.black87),
        TextosCustom("Conta só os pratos ainda não preparados.", 14, Colors.grey),
        Row(
          children: [
            Expanded(flex: 3, child: TextosCustom("Ingrediente", 16, Colors.black)),
            Expanded(flex: 2, child: TextosCustom("Comprar", 16, Colors.black)),
          ],
        ),
        Divider(),
        Column(children: _compras),
        Divider(),
        TextosCustom("Abaixo do mínimo na despensa", 20, Colors.black87),
        Row(
          children: [
            Expanded(flex: 3, child: TextosCustom("Ingrediente", 16, Colors.black)),
            Expanded(flex: 2, child: TextosCustom("Tem / mínimo", 16, Colors.black)),
          ],
        ),
        Divider(),
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
      _compras.add(Row(
        children: [
          Expanded(flex: 3, child: TextosCustom(list[index]['nome'], 16, Colors.black87)),
          Expanded(
              flex: 2,
              child: TextosCustom(
                  Ingrediente.formatar(list[index]['comprar']) + " " + list[index]['unidade'],
                  16, Colors.black87)),
        ],
      ));
      index++;
    });
    if (list.length == 0) {
      _compras.add(TextosCustom("Nada a comprar para o cardápio.", 16, Colors.grey));
    }

    var controlIngrediente = new ControlIngrediente();
    List<Map<String, dynamic>> baixos = await controlIngrediente.queryEstoqueBaixo();
    _baixos = [];
    index = 0;
    baixos.forEach((element) {
      _baixos.add(Row(
        children: [
          Expanded(flex: 3, child: TextosCustom(baixos[index]['nome'], 16, Colors.red)),
          Expanded(
              flex: 2,
              child: TextosCustom(
                  Ingrediente.formatar(baixos[index]['quantidade']) + " / " +
                      Ingrediente.formatar(baixos[index]['minimo']) + " " +
                      baixos[index]['unidade'],
                  16, Colors.red)),
        ],
      ));
      index++;
    });
    if (baixos.length == 0) {
      _baixos.add(TextosCustom("Nenhum item abaixo do mínimo.", 16, Colors.grey));
    }
    setState(() {});
  }
}
