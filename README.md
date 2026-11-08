# Cardápio da Semana

Aplicativo mobile em Flutter para montar o cardápio semanal com controle de despensa. Os ingredientes cadastrados são descontados quando o prato é preparado. O cadastro de ingredientes também pode ser feito por voz.

Projeto final da disciplina de Flutter/Dart (Prof. Danilo Ruy Gomes). Curso de Análise e Desenvolvimento de Sistemas da Fatec Itapetininga, 2026.

**Autoras:** Isabela e Veronica

## Funcionalidades

| Requisito | Tela |
|---|---|
| RF01 Cadastrar ingrediente | Cadastrar ingrediente |
| RF02 Cadastrar ingrediente por voz | Cadastrar ingrediente ("Falar ingrediente") |
| RF03 Manter despensa | Despensa |
| RF04 Cadastrar prato | Pratos |
| RF05 Montar cardápio da semana | Cardápio da semana |
| RF06 Descontar ingredientes | Cardápio da semana ("Marcar como preparado") |
| RF07 Alertar estoque baixo | Despensa e Lista de compras |
| RF08 Gerar lista de compras | Lista de compras |

## Tecnologias

- Flutter (Dart) e Android Studio
- SQLite local (`sqflite`)
- Reconhecimento de voz (`speech_to_text`)

## Estrutura (MVC da aula)

```
lib/
  main.dart
  model/      ingrediente.dart, prato.dart, cardapio.dart
  control/    control_ingrediente.dart, control_prato.dart, control_cardapio.dart
  telas/      menu.dart, tela_Ingrediente.dart, tela_despensa.dart,
              tela_prato.dart, tela_cardapio.dart, tela_compras.dart
  widgets/    widget_button.dart, widget_input.dart, widget_text_custom.dart
```

Layouts usados: Row, Column, Expanded (flex) e ListView.

## Banco de dados (cardapio.db)

- `ingrediente (id, nome, quantidade, unidade, minimo)`
- `prato (id, nome)`
- `prato_ingrediente (id, id_prato, id_ingrediente, quantidade)`
- `cardapio (id, dia_semana, refeicao, id_prato, preparado)`

## Como rodar

1. `flutter pub get`
2. Permissões em `android/app/src/main/AndroidManifest.xml`:
   - acima de `<application`:
     ```xml
     <uses-permission android:name="android.permission.RECORD_AUDIO"/>
     <uses-permission android:name="android.permission.INTERNET"/>
     ```
   - dentro de `<queries>`:
     ```xml
     <intent>
         <action android:name="android.speech.RecognitionService" />
     </intent>
     ```
3. Rodar em um celular Android. No emulador, o microfone costuma falhar.

## Ordem para testar

Cadastrar ingrediente → Pratos (cadastrar e adicionar ingredientes) → Cardápio (salvar) → Lista de compras → Cardápio (marcar como preparado) → Despensa (ver o desconto).
