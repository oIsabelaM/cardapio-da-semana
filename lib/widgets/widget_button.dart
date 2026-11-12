import 'package:flutter/material.dart';

import 'cores.dart';

class Buttons extends StatelessWidget {
  final String texto; //texto que ira aparecer no botao
  final void Function() onPressed; //funcao chamada no clique
  Buttons(this.texto, {required this.onPressed});
  //construtor

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Cores.primaria,
        minimumSize: Size(88, 48),
        padding: EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onPressed: onPressed,
    );
  }
}
