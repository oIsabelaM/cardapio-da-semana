import 'package:flutter/material.dart';

import 'cores.dart';

// caixa branca com borda arredondada para agrupar os elementos da tela
class Cartao extends StatelessWidget {
  Widget conteudo;
  Color cor;

  Cartao(this.conteudo, {this.cor = Cores.cartao});
  //construtor

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Cores.borda),
      ),
      child: conteudo,
    );
  }
}
