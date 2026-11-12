import 'package:flutter/material.dart';

import 'cores.dart';

class InputTextos extends StatelessWidget {
  String rotulo; //Podera atribuir um rotulo
  String label; //Podera atribuir um "hint"
  TextEditingController controller;
  //Para pegar o texto digitado

  InputTextos(this.rotulo, this.label, {required this.controller});
  //Construtor

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: Cores.texto,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: rotulo,
        hintText: label,
      ),
    );
  }
}
