import 'package:flutter/material.dart';

import '../control/control_cardapio.dart';
import '../model/cardapio.dart';
import '../model/ingrediente.dart';
import '../widgets/widget_button.dart';
import '../widgets/widget_input.dart';
import '../widgets/widget_text_custom.dart';

// RF05 - montar cardapio da semana / RF06 - descontar ingredientes
class TelaCardapio extends StatefulWidget {
  @override
  State<TelaCardapio> createState() => _TelaCardapioState();
}

class _TelaCardapioState extends State<TelaCardapio> {
  final _dia = TextEditingController();
  final _refeicao = TextEditingController();
  final _prato = TextEditingController();

  List<Widget> _linhas = [];
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
        title: Text("Cardápio da semana"),
      ),
      body: _body(),
    );
  }

  _body() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: InputTextos("Dia", "Ex.: segunda", controller: _dia),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: InputTextos("Refeição", "almoço ou jantar", controller: _refeicao),
            ),
          ],
        ),
        InputTextos("Prato", "Ex.: arroz com feijão", controller: _prato),
        Buttons("Salvar no cardápio", onPressed: _salvar),
        Buttons("Marcar como preparado", onPressed: _preparar),
        TextosCustom(_mensagem, 16, Colors.black87),
        Divider(),
        Row(
          children: [
            Expanded(flex: 2, child: TextosCustom("Dia", 16, Colors.black)),
            Expanded(flex: 3, child: TextosCustom("Almoço", 16, Colors.black)),
            Expanded(flex: 3, child: TextosCustom("Jantar", 16, Colors.black)),
          ],
        ),
        Divider(),
        Column(children: _linhas),
        TextosCustom("✓ = já preparado", 14, Colors.grey),
        Buttons("Limpar semana", onPressed: _limpar),
      ],
    );
  }

  _salvar() async {
    String dia = Cardapio.normalizarDia(_dia.text);
    String refeicao = Cardapio.normalizarRefeicao(_refeicao.text);
    String prato = Ingrediente.limpar(_prato.text);
    if (dia == "" || refeicao == "" || prato == "") {
      setState(() {
        _mensagem = "Informe um dia (seg a dom), almoço ou jantar e o prato.";
      });
      return;
    }
    var control = new ControlCardapio();
    int resultado = await control.insertDatabase(
        Cardapio(diaSemana: dia, refeicao: refeicao, nomePrato: prato));
    _mensagem = resultado == -1
        ? "O prato \"$prato\" não está cadastrado."
        : "Cardápio salvo!";
    _prato.text = "";
    _consultar();
  }

  _preparar() async {
    String dia = Cardapio.normalizarDia(_dia.text);
    String refeicao = Cardapio.normalizarRefeicao(_refeicao.text);
    if (dia == "" || refeicao == "") {
      setState(() {
        _mensagem = "Informe o dia e a refeição que foi preparada.";
      });
      return;
    }
    var control = new ControlCardapio();
    int resultado = await control.marcarPreparado(dia, refeicao);
    if (resultado == -1) {
      _mensagem = "Não há prato nesse dia e refeição.";
    } else if (resultado == -2) {
      _mensagem = "Esse prato já foi marcado como preparado.";
    } else {
      _mensagem = "Preparado! Os ingredientes foram descontados da despensa.";
    }
    _consultar();
  }

  _limpar() async {
    var control = new ControlCardapio();
    await control.limparSemana();
    _mensagem = "Cardápio da semana apagado.";
    _consultar();
  }

  _consultar() async {
    var control = new ControlCardapio();
    List<Map<String, dynamic>> list = await control.queryFind();

    // cada dia guarda o texto do almoco e do jantar
    Map<String, String> almoco = {};
    Map<String, String> jantar = {};
    int index = 0;
    list.forEach((element) {
      String texto = list[index]['prato'];
      if (list[index]['preparado'] == 1) {
        texto = texto + " ✓";
      }
      if (list[index]['refeicao'] == "almoco") {
        almoco[list[index]['dia_semana']] = texto;
      } else {
        jantar[list[index]['dia_semana']] = texto;
      }
      index++;
    });

    _linhas = [];
    int i = 0;
    Cardapio.dias.forEach((dia) {
      _linhas.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: TextosCustom(Cardapio.diasTela[i], 16, Colors.teal)),
          Expanded(flex: 3, child: TextosCustom(almoco[dia] ?? "-", 16, Colors.black87)),
          Expanded(flex: 3, child: TextosCustom(jantar[dia] ?? "-", 16, Colors.black87)),
        ],
      ));
      _linhas.add(SizedBox(height: 8));
      i++;
    });
    setState(() {});
  }
}
