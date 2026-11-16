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

  // "g", "gr", "gramas" -> "g"; "kg", "quilos" -> "kg"; "ml" -> "ml"; "l", "litros" -> "l"
  // outras unidades (un, pct, dz...) ficam como foram digitadas
  static String normalizarUnidade(String texto) {
    String t = texto.trim().toLowerCase();
    if (t == "") {
      return "";
    }
    if (t == "kg" || t.startsWith("quilo") || t.startsWith("kilo")) {
      return "kg";
    }
    if (t == "g" || t == "gr" || t.startsWith("grama")) {
      return "g";
    }
    if (t == "ml" || t.startsWith("mililitro")) {
      return "ml";
    }
    if (t == "l" || t.startsWith("litro")) {
      return "l";
    }
    return t;
  }

  // converte entre g e kg, ml e l; devolve -1 se nao der para converter
  static double converter(double valor, String de, String para) {
    if (de == para) {
      return valor;
    }
    if (de == "g" && para == "kg") {
      return valor / 1000;
    }
    if (de == "kg" && para == "g") {
      return valor * 1000;
    }
    if (de == "ml" && para == "l") {
      return valor / 1000;
    }
    if (de == "l" && para == "ml") {
      return valor * 1000;
    }
    return -1;
  }

  // pega so a unidade escrita junto do numero: "500gr" -> "g", "2" -> ""
  static String unidadeDoTexto(String texto) {
    return normalizarUnidade(texto.toLowerCase().replaceAll(RegExp(r'[0-9.,\s]'), ""));
  }

  // le "500 g", "0,5kg" ou "500" e devolve o valor na unidadeDestino
  // (sem unidade escrita, vale a propria unidadeDestino)
  // devolve -1 se nao for numero e -2 se a unidade nao combinar
  static double lerComUnidade(String texto, String unidadeDestino) {
    double numero = lerNumero(texto.replaceAll(RegExp(r'[^0-9.,]'), ""));
    if (numero < 0) {
      return -1;
    }
    String unidade = unidadeDoTexto(texto);
    if (unidade == "" || unidade == unidadeDestino) {
      return numero;
    }
    double convertido = converter(numero, unidade, unidadeDestino);
    if (convertido < 0) {
      return -2;
    }
    return convertido;
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
