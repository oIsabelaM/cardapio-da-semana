import 'package:flutter/material.dart';

import '../control/control_cardapio.dart';
import '../model/cardapio.dart';
import '../model/ingrediente.dart';
import '../widgets/cores.dart';
import '../widgets/widget_button.dart';
import '../widgets/widget_cartao.dart';
import '../widgets/widget_input.dart';
import '../widgets/widget_text_custom.dart';

// RF05 - montar cardapio da semana / RF06 - descontar ingredientes
class TelaCardapio extends StatefulWidget {
  @override
  State<TelaCardapio> createState() => _TelaCardapioState();
}

class _TelaCardapioState extends State<TelaCardapio> {
  final _dia = TextEditingController();
  final _prato = TextEditingController();
  String _refeicao = "almoco"; // escolhida pelos botoes Almoço / Jantar
  bool _confirmarLimpar = false; // pede um segundo toque antes de apagar a semana

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
        Cartao(Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextosCustom("Montar a semana", 18, Cores.texto, negrito: true),
            SizedBox(height: 12),
            InputTextos("Dia", "Ex.: segunda (ou toque no dia na tabela)", controller: _dia),
            SizedBox(height: 12),
            TextosCustom("Refeição", 14, Cores.textoSuave),
            SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Buttons(_refeicao == "almoco" ? "✓ Almoço" : "Almoço", onPressed: () {
                    setState(() {
                      _refeicao = "almoco";
                    });
                  }),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Buttons(_refeicao == "jantar" ? "✓ Jantar" : "Jantar", onPressed: () {
                    setState(() {
                      _refeicao = "jantar";
                    });
                  }),
                ),
              ],
            ),
            SizedBox(height: 12),
            InputTextos("Prato", "Ex.: arroz com feijão", controller: _prato),
            SizedBox(height: 14),
            Buttons("Salvar no cardápio", onPressed: _salvar),
          ],
        )),
        Cartao(Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextosCustom("Depois de cozinhar", 18, Cores.texto, negrito: true),
            SizedBox(height: 4),
            TextosCustom(
                "Use o dia e a refeição escolhidos acima. Ao marcar como preparado, os "
                "ingredientes saem da despensa. Errou? Toque em Desfazer e eles voltam.",
                13, Cores.textoSuave),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Buttons("Preparado", onPressed: _preparar)),
                SizedBox(width: 10),
                Expanded(child: Buttons("Desfazer", onPressed: _desfazer)),
              ],
            ),
          ],
        )),
        TextosCustom(_mensagem, 16, Cores.secundaria, negrito: true, centralizado: true),
        SizedBox(height: 12),
        TextosCustom("Semana", 18, Cores.texto, negrito: true),
        TextosCustom("Em verde com ✓: já preparado. Toque em um dia para preenchê-lo.", 13,
            Cores.textoSuave),
        SizedBox(height: 10),
        Cartao(
          Row(
            children: [
              Expanded(flex: 2, child: TextosCustom("Dia", 14, Cores.texto, negrito: true)),
              Expanded(flex: 3, child: TextosCustom("Almoço", 14, Cores.texto, negrito: true)),
              Expanded(flex: 3, child: TextosCustom("Jantar", 14, Cores.texto, negrito: true)),
            ],
          ),
          cor: Cores.cabecalho,
        ),
        Column(children: _linhas),
        SizedBox(height: 8),
        Buttons(_confirmarLimpar ? "Toque de novo para apagar a semana" : "Limpar semana",
            onPressed: _limpar),
      ],
    );
  }

  String _nomeRefeicao() {
    return _refeicao == "almoco" ? "almoço" : "jantar";
  }

  _salvar() async {
    String dia = Cardapio.normalizarDia(_dia.text);
    String prato = Ingrediente.limpar(_prato.text);
    _confirmarLimpar = false;
    if (dia == "" || prato == "") {
      setState(() {
        _mensagem = "Informe um dia (seg a dom) e o prato.";
      });
      return;
    }
    var control = new ControlCardapio();
    int resultado = await control.insertDatabase(
        Cardapio(diaSemana: dia, refeicao: _refeicao, nomePrato: prato));
    _mensagem = resultado == -1
        ? "O prato \"$prato\" não está cadastrado. Cadastre em Pratos."
        : "Salvo: $prato no ${_nomeRefeicao()} de $dia.";
    _prato.text = "";
    _consultar();
  }

  _preparar() async {
    String dia = Cardapio.normalizarDia(_dia.text);
    _confirmarLimpar = false;
    if (dia == "") {
      setState(() {
        _mensagem = "Informe o dia (seg a dom) e escolha a refeição.";
      });
      return;
    }
    var control = new ControlCardapio();

    // so prepara se a despensa tiver tudo (assim o Desfazer devolve o valor certo)
    List<Map<String, dynamic>> falta = await control.queryFaltaParaPreparar(dia, _refeicao);
    if (falta.length > 0) {
      String itens = "";
      int index = 0;
      falta.forEach((element) {
        itens = itens + "\n• " + falta[index]['nome'] + ": " +
            Ingrediente.formatar(falta[index]['falta']) + " " + falta[index]['unidade'];
        index++;
      });
      setState(() {
        _mensagem = "Não dá para preparar: falta na despensa$itens\n"
            "Atualize a despensa e tente de novo.";
      });
      return;
    }

    int resultado = await control.marcarPreparado(dia, _refeicao);
    if (resultado == -1) {
      _mensagem = "Não há prato no ${_nomeRefeicao()} de $dia.";
    } else if (resultado == -2) {
      _mensagem = "Esse prato já foi marcado como preparado.";
    } else {
      _mensagem = "Preparado! Os ingredientes foram descontados da despensa.";
    }
    _consultar();
  }

  _desfazer() async {
    String dia = Cardapio.normalizarDia(_dia.text);
    _confirmarLimpar = false;
    if (dia == "") {
      setState(() {
        _mensagem = "Informe o dia (seg a dom) e escolha a refeição.";
      });
      return;
    }
    var control = new ControlCardapio();
    int resultado = await control.desfazerPreparado(dia, _refeicao);
    if (resultado == -1) {
      _mensagem = "Não há prato no ${_nomeRefeicao()} de $dia.";
    } else if (resultado == -2) {
      _mensagem = "Esse prato ainda não foi marcado como preparado.";
    } else {
      _mensagem = "Desfeito! Os ingredientes voltaram para a despensa.";
    }
    _consultar();
  }

  _limpar() async {
    // primeiro toque so pede confirmacao
    if (!_confirmarLimpar) {
      setState(() {
        _confirmarLimpar = true;
        _mensagem = "Isso apaga o cardápio da semana inteira. Toque de novo para confirmar.";
      });
      return;
    }
    var control = new ControlCardapio();
    await control.limparSemana();
    _confirmarLimpar = false;
    _mensagem = "Cardápio da semana apagado.";
    _consultar();
  }

  _consultar() async {
    var control = new ControlCardapio();
    List<Map<String, dynamic>> list = await control.queryFind();

    // cada dia guarda o texto do almoco e do jantar
    Map<String, String> almoco = {};
    Map<String, String> jantar = {};
    Map<String, bool> almocoFeito = {};
    Map<String, bool> jantarFeito = {};
    int index = 0;
    list.forEach((element) {
      String texto = list[index]['prato'];
      bool feito = list[index]['preparado'] == 1;
      if (feito) {
        texto = texto + " ✓";
      }
      if (list[index]['refeicao'] == "almoco") {
        almoco[list[index]['dia_semana']] = texto;
        almocoFeito[list[index]['dia_semana']] = feito;
      } else {
        jantar[list[index]['dia_semana']] = texto;
        jantarFeito[list[index]['dia_semana']] = feito;
      }
      index++;
    });

    _linhas = [];
    int i = 0;
    Cardapio.dias.forEach((dia) {
      String nomeDia = Cardapio.diasTela[i];
      _linhas.add(InkWell(
        onTap: () {
          _dia.text = dia;
        },
        child: Cartao(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: TextosCustom(nomeDia, 15, Cores.primaria, negrito: true)),
            Expanded(
                flex: 3,
                child: TextosCustom(almoco[dia] ?? "-", 15,
                    (almocoFeito[dia] ?? false) ? Cores.secundaria : Cores.texto)),
            Expanded(
                flex: 3,
                child: TextosCustom(jantar[dia] ?? "-", 15,
                    (jantarFeito[dia] ?? false) ? Cores.secundaria : Cores.texto)),
          ],
        )),
      ));
      i++;
    });
    setState(() {});
  }
}
