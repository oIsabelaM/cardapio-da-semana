import 'package:flutter/material.dart';

class TextosCustom extends StatelessWidget {
  String texto;
  double tamanho;
  Color cor;
  //atributos da classe

  TextosCustom(this.texto, this.tamanho, this.cor);
  //construtor da classe

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: tamanho,
        color: cor,
      ),
    );
  }
}
