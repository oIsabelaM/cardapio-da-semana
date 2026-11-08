class Prato {
  final String nome;

  Prato({
    required this.nome,
  });

  @override
  String toString() {
    return "Prato{nome: $nome}";
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
    };
  }
}
