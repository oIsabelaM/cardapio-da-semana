import 'package:flutter/material.dart';

class TextosCustom extends StatelessWidget {
  String texto;
  double tamanho;
  Color cor;
  bool negrito;
  bool centralizado;
  //atributos da classe

  TextosCustom(this.texto, this.tamanho, this.cor,
      {this.negrito = false, this.centralizado = false});
  //construtor da classe

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: centralizado ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontSize: tamanho,
        color: cor,
        fontWeight: negrito ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
