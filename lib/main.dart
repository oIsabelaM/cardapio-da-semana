import 'package:flutter/material.dart';

import 'telas/menu.dart';
import 'widgets/cores.dart';

void main() {
  runApp(MaterialApp(
    title: "Cardápio da Semana",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Cores.primaria),
      scaffoldBackgroundColor: Cores.fundo,
      appBarTheme: AppBarTheme(
        backgroundColor: Cores.primaria,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Cores.fundo,
        labelStyle: TextStyle(color: Cores.textoSuave),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Cores.borda),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Cores.borda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Cores.primaria, width: 2),
        ),
      ),
    ),
    home: Menu(),
  ));
}
