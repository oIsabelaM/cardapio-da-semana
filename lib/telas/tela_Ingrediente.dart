import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../control/control_ingrediente.dart';
import '../model/ingrediente.dart';
import '../widgets/cores.dart';
import '../widgets/widget_button.dart';
import '../widgets/widget_cartao.dart';
import '../widgets/widget_input.dart';
import '../widgets/widget_text_custom.dart';

// RF01 - cadastrar ingrediente / RF02 - cadastrar por voz
class TelaIngrediente extends StatefulWidget {
  @override
  State<TelaIngrediente> createState() => _TelaIngredienteState();
}

class _TelaIngredienteState extends State<TelaIngrediente> {
  final _nome = TextEditingController();
  final _quantidade = TextEditingController();
  final _unidade = TextEditingController();
  final _minimo = TextEditingController();

  final SpeechToText _fala = SpeechToText();
  bool _vozDisponivel = false;
  bool _ouvindo = false;
  String _textoFalado = "";
  String _mensagem = "";

  @override
  void initState() {
    super.initState();
    _iniciarVoz();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar ingrediente"),
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
            TextosCustom("Cadastro por voz", 18, Cores.texto, negrito: true),
            SizedBox(height: 4),
            TextosCustom("Toque no botão e fale, por exemplo: \"dois quilos e meio de arroz\"",
                14, Cores.textoSuave),
            SizedBox(height: 12),
            Buttons(_ouvindo ? "Ouvindo... toque para parar" : "Falar ingrediente",
                onPressed: _ouvir),
            SizedBox(height: 10),
            TextosCustom(_textoFalado == "" ? "" : "Entendido: \"$_textoFalado\"", 15,
                Cores.secundaria, centralizado: true),
          ],
        )),
        Cartao(Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextosCustom("Dados do ingrediente", 18, Cores.texto, negrito: true),
            SizedBox(height: 12),
            InputTextos("Nome", "Ex.: arroz", controller: _nome),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InputTextos("Quantidade", "Ex.: 2,5", controller: _quantidade),
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
                "Pode escrever a unidade (ex.: 500 g ou 0,5 kg); sem unidade, vale a do ingrediente. "
                "Deixe em branco para não receber aviso.",
                13, Cores.textoSuave),
            SizedBox(height: 14),
            Buttons("Registrar", onPressed: _registrar),
          ],
        )),
        TextosCustom(_mensagem, 16, Cores.secundaria, negrito: true, centralizado: true),
      ],
    );
  }

  _iniciarVoz() async {
    _vozDisponivel = await _fala.initialize();
    setState(() {});
  }

  _ouvir() async {
    if (!_vozDisponivel) {
      setState(() {
        _mensagem = "Reconhecimento de voz indisponível neste aparelho.";
      });
      return;
    }
    if (_ouvindo) {
      await _fala.stop();
      setState(() {
        _ouvindo = false;
      });
      return;
    }
    setState(() {
      _ouvindo = true;
      _mensagem = "";
    });
    await _fala.listen(
      localeId: "pt_BR",
      onResult: (resultado) {
        setState(() {
          _textoFalado = resultado.recognizedWords;
        });
        if (resultado.finalResult) {
          _interpretar(resultado.recognizedWords);
          setState(() {
            _ouvindo = false;
          });
        }
      },
    );
  }

  // transforma "dois quilos e meio de arroz" em 2,5 / kg / arroz
  // e mostra nos campos para conferir antes de registrar (RNF02)
  _interpretar(String frase) {
    String texto = frase.toLowerCase().trim();
    String parteQuantidade = texto;
    String nome = "";

    int posicao = texto.indexOf(" de ");
    if (posicao > 0) {
      parteQuantidade = texto.substring(0, posicao);
      nome = texto.substring(posicao + 4);
    }

    double quantidade = 0;
    String unidade = "";
    List<String> resto = [];

    parteQuantidade.split(" ").forEach((palavra) {
      if (palavra == "" || palavra == "e") {
        return;
      }
      double numero = _numero(palavra);
      String un = _unidadeFalada(palavra);
      if (numero > 0) {
        quantidade += numero;
        if (un == "") {
          un = _unidadeFalada(palavra.replaceAll(RegExp(r'[0-9.,]'), ""));
        }
      }
      if (un != "") {
        unidade = un;
      }
      if (numero <= 0 && un == "") {
        resto.add(palavra);
      }
    });

    if (nome == "") {
      nome = resto.join(" ");
    }
    if (quantidade == 0) {
      quantidade = 1;
    }
    if (unidade == "") {
      unidade = "un";
    }

    _nome.text = nome;
    _quantidade.text = Ingrediente.formatar(quantidade);
    _unidade.text = unidade;
    setState(() {
      _mensagem = "Confira os campos e toque em Registrar.";
    });
  }

  double _numero(String palavra) {
    Map<String, double> numeros = {
      "um": 1, "uma": 1, "dois": 2, "duas": 2, "três": 3, "tres": 3,
      "quatro": 4, "cinco": 5, "seis": 6, "sete": 7, "oito": 8, "nove": 9,
      "dez": 10, "onze": 11, "doze": 12, "treze": 13, "quatorze": 14,
      "catorze": 14, "quinze": 15, "dezesseis": 16, "dezessete": 17,
      "dezoito": 18, "dezenove": 19, "vinte": 20, "trinta": 30,
      "quarenta": 40, "cinquenta": 50, "cem": 100, "duzentos": 200,
      "duzentas": 200, "trezentos": 300, "trezentas": 300,
      "quinhentos": 500, "quinhentas": 500, "mil": 1000,
      "meio": 0.5, "meia": 0.5,
    };
    if (numeros.containsKey(palavra)) {
      return numeros[palavra]!;
    }
    // o reconhecedor as vezes ja devolve numero: "2", "2,5" ou "2kg"
    String soNumero = palavra.replaceAll(RegExp(r'[^0-9.,]'), "");
    if (soNumero == "") {
      return 0;
    }
    double valor = Ingrediente.lerNumero(soNumero);
    return valor > 0 ? valor : 0;
  }

  String _unidadeFalada(String palavra) {
    if (palavra == "") return "";
    if (palavra.startsWith("quilo") || palavra == "kg") return "kg";
    if (palavra.startsWith("grama") || palavra == "g") return "g";
    if (palavra.startsWith("mililitro") || palavra == "ml") return "ml";
    if (palavra.startsWith("litro") || palavra == "l") return "l";
    if (palavra.startsWith("unidade") || palavra == "un") return "un";
    if (palavra.startsWith("pacote")) return "pct";
    if (palavra.startsWith("dúzia") || palavra.startsWith("duzia")) return "dz";
    if (palavra.startsWith("caixa")) return "cx";
    if (palavra.startsWith("lata")) return "lata";
    return "";
  }

  _registrar() async {
    String nome = Ingrediente.limpar(_nome.text);
    // unidade: a do campo Unidade; se estiver vazio, a escrita na quantidade ("2kg"); senao "un"
    String unidade = Ingrediente.normalizarUnidade(Ingrediente.limpar(_unidade.text));
    if (unidade == "") {
      unidade = Ingrediente.unidadeDoTexto(_quantidade.text);
    }
    if (unidade == "") {
      unidade = "un";
    }
    // quantidade e minimo aceitam unidade ("500 g") e sao convertidos para a unidade do ingrediente
    double quantidade = Ingrediente.lerComUnidade(_quantidade.text, unidade);
    double minimo =
        _minimo.text.trim() == "" ? 0 : Ingrediente.lerComUnidade(_minimo.text, unidade);

    if (nome == "" || quantidade == -1 || minimo == -1) {
      setState(() {
        _mensagem = "Preencha nome, quantidade e mínimo com números válidos.";
      });
      return;
    }
    if (quantidade == -2 || minimo == -2) {
      setState(() {
        _mensagem = "A unidade da quantidade ou do mínimo não combina com \"$unidade\". "
            "Use a mesma unidade (ou g/kg, ml/l).";
      });
      return;
    }

    var control = new ControlIngrediente();
    int resultado = await control.insertDatabase(Ingrediente(
      nome: nome,
      quantidade: quantidade,
      unidade: unidade,
      minimo: minimo,
    ));
    if (resultado == -2) {
      setState(() {
        _mensagem = "\"$nome\" já está na despensa em outra unidade, que não dá para converter. "
            "Use a mesma unidade (ou g/kg, ml/l).";
      });
      return;
    }

    _nome.text = "";
    _quantidade.text = "";
    _unidade.text = "";
    _minimo.text = "";
    setState(() {
      _textoFalado = "";
      _mensagem = "Ingrediente \"$nome\" registrado!";
    });
  }
}
