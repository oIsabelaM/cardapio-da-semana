# Cardápio da Semana

Aplicativo Android para **planejar as refeições da semana** e **controlar a despensa** de casa. Os ingredientes são descontados quando um prato é preparado, e o app gera sozinho a **lista de compras**.

> Projeto final da disciplina de Flutter/Dart (Prof. Danilo Ruy Gomes), curso de Análise e Desenvolvimento de Sistemas da **Fatec Itapetininga**, 2026.
> **Autoras:** Isabela e Veronica

---

## A ideia

Muita gente vai ao mercado sem saber o que já tem em casa, compra coisas repetidas, esquece ingredientes e acaba desperdiçando comida.

O **Cardápio da Semana** junta três coisas num lugar só:

1. **O que tem em casa:** a despensa, com a quantidade de cada ingrediente.
2. **O que vai cozinhar:** o cardápio da semana, com almoço e jantar de cada dia.
3. **O que falta comprar:** calculado automaticamente a partir dos dois itens anteriores.

## Propósito

- **Evitar desperdício:** você sabe exatamente o que tem e o que vai usar.
- **Economizar:** compra só o que falta, sem repetir.
- **Organizar a rotina:** a semana fica planejada, sem a dúvida diária de "o que vamos comer hoje?".
- **Ser simples:** telas em português, sem cadastro de conta e sem internet. Os dados ficam só no celular.

**Público:** pessoas e famílias que querem planejar as refeições e controlar o que têm em casa.

---

## Como usar

Siga esta ordem na primeira vez.

### 1. Cadastrar ingrediente
Informe o **nome**, a **quantidade**, a **unidade** (kg, g, l, un...) e o **estoque mínimo**. Se o ingrediente já existir, a quantidade nova é **somada** à anterior.

**Por voz:** toque em **"Falar ingrediente"** e diga, por exemplo, *"dois quilos e meio de arroz"*. O app preenche os campos (2,5 / kg / arroz), você confere e toca em **Registrar**.

> **O que é o "estoque mínimo (alerta)"?**
> É o quanto você quer ter **sempre** em casa. Quando o estoque fica abaixo desse valor, o app avisa **em vermelho com ⚠**.
> Exemplo: com mínimo de 1 kg de feijão, o aviso aparece quando sobrar menos de 1 kg. Se o campo ficar em branco, não há aviso.

### 2. Despensa
Mostra tudo o que você tem em casa. Os itens **abaixo do estoque mínimo** aparecem em vermelho com ⚠.
- **Buscar:** digite parte do nome e toque em **Consultar**. Com o campo vazio, aparecem todos.
- **Editar ou excluir:** toque num item para preencher os campos, altere o que quiser e toque em **Atualizar** ou **Excluir**.

### 3. Pratos
Cadastre as receitas e o que cada uma usa.
1. Digite o nome do prato (ex.: *arroz com feijão*) e toque em **Cadastrar**.
2. Adicione os ingredientes um a um, com a quantidade usada (ex.: arroz 0,5; feijão 0,25), tocando em **Adicionar ingrediente**.

> O ingrediente precisa estar cadastrado na despensa antes.

### 4. Cardápio da semana
Monte a semana informando o **dia** (*segunda*, *seg*...), a **refeição** (*almoço* ou *jantar*) e o **prato**. Depois toque em **Salvar no cardápio**.

Depois de cozinhar, informe o dia e a refeição e toque em **Marcar como preparado**. Os ingredientes do prato são **descontados da despensa** automaticamente, e o prato fica verde com ✓.

### 5. Lista de compras
- **Para o cardápio da semana:** mostra o que falta comprar para os pratos ainda não preparados (o que o cardápio precisa menos o que já tem na despensa).
- **Abaixo do estoque mínimo:** mostra os itens que estão acabando, mesmo que não estejam no cardápio.

---

## Requisitos atendidos

| Requisito | Onde |
|---|---|
| RF01 Cadastrar ingrediente | Cadastrar ingrediente |
| RF02 Cadastrar ingrediente por voz | Cadastrar ingrediente → "Falar ingrediente" |
| RF03 Manter despensa (consultar, editar, excluir) | Despensa |
| RF04 Cadastrar prato com ingredientes | Pratos |
| RF05 Montar cardápio da semana | Cardápio da semana |
| RF06 Descontar ingredientes ao preparar | Cardápio → "Marcar como preparado" |
| RF07 Alertar estoque baixo | Despensa e Lista de compras (⚠ vermelho) |
| RF08 Gerar lista de compras | Lista de compras |

---

## Tecnologias

- **Flutter (Dart)** e **Android Studio**
- **SQLite** local, com o pacote [`sqflite`](https://pub.dev/packages/sqflite)
- **Reconhecimento de voz**, com o pacote [`speech_to_text`](https://pub.dev/packages/speech_to_text)

## Estrutura do projeto (MVC, como ensinado em aula)

```
lib/
  main.dart          → inicia o app e abre o Menu
  model/             → classes de dados: Ingrediente, Prato, Cardapio
  control/           → acesso ao banco SQLite (uma classe por assunto)
  telas/             → menu e as 5 telas do app
  widgets/           → Buttons, InputTextos, TextosCustom, Cartao e a paleta de Cores
```

- **Layouts usados:** Row, Column, Expanded (flex) e ListView.
- **Visual:** paleta suave (terracota, verde-sálvia e creme), com cada grupo de informações em um cartão.

### Banco de dados (`cardapio.db`)

| Tabela | Campos |
|---|---|
| `ingrediente` | id, nome, quantidade, unidade, minimo |
| `prato` | id, nome |
| `prato_ingrediente` | id, id_prato, id_ingrediente, quantidade |
| `cardapio` | id, dia_semana, refeicao, id_prato, preparado |

---

## Como rodar

1. Clone o repositório no Android Studio: **File → New → Project from Version Control**.
2. Abra o `pubspec.yaml` e clique em **Pub get**.
3. Rode num **celular Android** ou num **emulador**.

> O app **não funciona no Chrome nem no Windows**, porque o banco SQLite (`sqflite`) só roda em Android ou iOS.
> A voz funciona melhor no celular. No emulador o microfone costuma falhar, e dependendo do aparelho pode ser preciso ter internet.

As permissões já estão no `android/app/src/main/AndroidManifest.xml`:
- `RECORD_AUDIO` (microfone) e `INTERNET`
- `android.speech.RecognitionService` dentro de `<queries>`

## Roteiro de teste rápido

1. **Cadastrar ingrediente:** arroz, 2, kg, mínimo 1. Depois feijão, 0,3, kg, mínimo 1.
2. **Pratos:** "arroz com feijão", com arroz 0,5 e feijão 0,25.
3. **Cardápio:** segunda, almoço, arroz com feijão → Salvar.
4. **Lista de compras:** o feijão aparece para comprar.
5. **Cardápio:** segunda, almoço → Marcar como preparado.
6. **Despensa:** o arroz passa para 1,5 kg, e o feijão aparece em vermelho com ⚠.
