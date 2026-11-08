class Ingrediente {
  final String nome;
  final double quantidade;
  final String unidade;
  final double minimo;

  Ingrediente({
    required this.nome,
    required this.quantidade,
    required this.unidade,
    required this.minimo,
  });

  @override
  String toString() {
    return "Ingrediente{nome: $nome, quantidade: $quantidade, unidade: $unidade, minimo: $minimo}";
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'unidade': unidade,
      'minimo': minimo,
    };
  }

  // deixa o nome em minusculas e tira o apostrofo (quebraria o SQL)
  static String limpar(String texto) {
    return texto.trim().toLowerCase().replaceAll("'", "");
  }

  // aceita "2,5" ou "2.5"; devolve -1 se nao for numero
  static double lerNumero(String texto) {
    double? numero = double.tryParse(texto.trim().replaceAll(",", "."));
    if (numero == null) {
      return -1;
    }
    return numero;
  }

  // mostra 2.0 como "2" e 2.5 como "2,5"
  static String formatar(dynamic valor) {
    double numero = (double.parse(valor.toString()) * 100).round() / 100;
    if (numero == numero.roundToDouble()) {
      return numero.toInt().toString();
    }
    return numero.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll('.', ',');
  }
}
