class Cardapio {
  final String diaSemana;
  final String refeicao;
  final String nomePrato;

  Cardapio({
    required this.diaSemana,
    required this.refeicao,
    required this.nomePrato,
  });

  @override
  String toString() {
    return "Cardapio{diaSemana: $diaSemana, refeicao: $refeicao, nomePrato: $nomePrato}";
  }

  Map<String, dynamic> toMap() {
    return {
      'dia_semana': diaSemana,
      'refeicao': refeicao,
      'nome_prato': nomePrato,
    };
  }

  static List<String> dias = [
    "segunda", "terca", "quarta", "quinta", "sexta", "sabado", "domingo"
  ];

  static List<String> diasTela = [
    "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"
  ];

  // aceita "seg", "segunda", "Segunda-feira", "terça"... e devolve "segunda", "terca"...
  // devolve "" se nao reconhecer
  static String normalizarDia(String texto) {
    String t = texto.trim().toLowerCase()
        .replaceAll("ç", "c")
        .replaceAll("á", "a");
    if (t.length < 3) {
      return "";
    }
    String inicio = t.substring(0, 3);
    String resultado = "";
    dias.forEach((dia) {
      if (dia.substring(0, 3) == inicio) {
        resultado = dia;
      }
    });
    return resultado;
  }

  // aceita "almoço", "almoco", "jantar"; devolve "" se nao reconhecer
  static String normalizarRefeicao(String texto) {
    String t = texto.trim().toLowerCase();
    if (t.startsWith("alm")) {
      return "almoco";
    }
    if (t.startsWith("jan")) {
      return "jantar";
    }
    return "";
  }
}
