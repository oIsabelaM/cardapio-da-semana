import 'package:flutter/material.dart';

import '../widgets/widget_button.dart';
import '../widgets/widget_text_custom.dart';
import 'tela_Ingrediente.dart';
import 'tela_cardapio.dart';
import 'tela_compras.dart';
import 'tela_despensa.dart';
import 'tela_prato.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cardápio da Semana"),
      ),
      body: _body(context),
    );
  }

  _body(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextosCustom("O que vamos fazer hoje?", 22, Colors.black87),
          Buttons("Cadastrar ingrediente", onPressed: () {
            _abreTelas(ctx, TelaIngrediente());
          }),
          Buttons("Despensa", onPressed: () {
            _abreTelas(ctx, TelaDespensa());
          }),
          Buttons("Pratos", onPressed: () {
            _abreTelas(ctx, TelaPrato());
          }),
          Buttons("Cardápio da semana", onPressed: () {
            _abreTelas(ctx, TelaCardapio());
          }),
          Buttons("Lista de compras", onPressed: () {
            _abreTelas(ctx, TelaCompras());
          }),
        ],
      ),
    );
  }

  _abreTelas(ctx, page) {
    Navigator.push(ctx, MaterialPageRoute(builder: (BuildContext context) {
      return page;
    }));
  }
}
