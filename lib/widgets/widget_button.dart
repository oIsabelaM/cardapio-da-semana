import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  final String texto; //texto que ira aparecer no botao
  final void Function() onPressed; //funcao chamada no clique
  Buttons(this.texto, {required this.onPressed});
  //construtor

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.grey[300],
        backgroundColor: Colors.redAccent,
        minimumSize: Size(88, 36),
        padding: EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: Text(texto),
      onPressed: onPressed,
    );
  }
}
