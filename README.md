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
- **Ser simples:** telas em português, sem cadastro de conta. Os dados ficam só no celular e o app funciona sem internet (só o cadastro por voz pode precisar de conexão, conforme o aparelho).

**Público:** pessoas e famílias que querem planejar as refeições e controlar o que têm em casa.

---

## Como usar

Siga esta ordem na primeira vez.

### 1. Cadastrar ingrediente
Informe o **nome**, a **quantidade**, a **unidade** (kg, g, l, un...) e o **estoque mínimo**. Se o ingrediente já existir, a quantidade nova é **somada** à anterior, já convertida para a unidade que estava na despensa (ex.: 5 kg + 500 g = 5,5 kg).

A quantidade e o estoque mínimo aceitam a unidade escrita junto (*500 g*, *0,5 kg*): o app converte para a unidade do ingrediente. Sem unidade, vale a do campo **Unidade**.

**Por voz:** toque em **"Falar ingrediente"** e diga, por exemplo, *"dois quilos e meio de arroz"*. O app preenche os campos (2,5 / kg / arroz), você confere e toca em **Registrar**.

> **O que é o "estoque mínimo (alerta)"?**
> É o quanto você quer ter **sempre** em casa. Quando o estoque fica abaixo desse valor, o app avisa **em vermelho com ⚠**.
> Exemplo: com mínimo de 1 kg de feijão, o aviso aparece quando sobrar menos de 1 kg. Para um ingrediente em kg, escrever *500 g* no mínimo equivale a 0,5 kg. Se o campo ficar em branco, não há aviso.

### 2. Despensa
Mostra tudo o que você tem em casa. Os itens **abaixo do estoque mínimo** aparecem em vermelho com ⚠.
- **Buscar:** digite parte do nome e toque em **Consultar**. Com o campo vazio, aparecem todos.
- **Editar ou excluir:** toque num item para preencher os campos, altere o que quiser e toque em **Atualizar** ou **Excluir**. Excluir pede confirmação (o botão vira **Confirmar**) e também tira o ingrediente dos pratos que o usavam.

### 3. Pratos
Cadastre as receitas e o que cada uma usa. Basta preencher o **nome do prato**, o **ingrediente** e a **quantidade** e tocar em **Adicionar ingrediente**. Se o prato ainda não existir, ele é cadastrado junto. Repita para cada ingrediente do prato.

- A quantidade pode levar a unidade: *500 g*, *0,5 kg*, *200 ml*... O app converte para a unidade da despensa (g ↔ kg, ml ↔ l).
- Sem unidade (ex.: *0,5*), vale a mesma unidade do ingrediente na despensa.

> O ingrediente precisa estar cadastrado na despensa antes.

### 4. Cardápio da semana
Monte a semana informando o **dia** (*segunda*, *seg*...), escolhendo a refeição nos botões **Almoço** ou **Jantar** (a escolhida fica com ✓) e digitando o **prato**. Depois toque em **Salvar no cardápio**. Tocar num dia da tabela preenche o campo Dia.

Depois de cozinhar, com o dia e a refeição escolhidos, toque em **Preparado**. Os ingredientes do prato são **descontados da despensa**, e o prato fica verde com ✓.
- Se faltar algum ingrediente na despensa, o app **não prepara** e mostra o que falta (ex.: *feijão: 0,05 kg*). Assim a despensa nunca fica com valores errados.
- Marcou por engano? Toque em **Desfazer**: os ingredientes voltam para a despensa.
- **Limpar semana** pede um segundo toque para confirmar.

### 5. Lista de compras
- **Para o cardápio da semana:** mostra o que falta comprar para os pratos ainda não preparados (o que o cardápio precisa menos o que já tem na despensa).
- **Abaixo do estoque mínimo:** mostra os itens que estão acabando, mesmo que não estejam no cardápio.

---

## Especificações do sistema

Organizadas conforme as etapas do documento **"Definições projeto final 2026-2"** da disciplina.

### 1. Tema e segmento de mercado

| Item | Descrição |
|---|---|
| Tema | Cardápio semanal com controle de despensa e lista de compras |
| Segmento | Alimentação doméstica e organização pessoal |
| Público | Pessoas e famílias que planejam as refeições e querem evitar desperdício |

### 2. Requisitos funcionais

| Código | Requisito | Descrição | Onde está no app |
|---|---|---|---|
| RF01 | Cadastrar ingrediente | Nome, quantidade, unidade de medida e estoque mínimo | Cadastrar ingrediente |
| RF02 | Cadastrar ingrediente por voz | Preencher o cadastro pela fala (ex.: "dois quilos de arroz") | Cadastrar ingrediente → "Falar ingrediente" |
| RF03 | Manter despensa | Consultar, editar e excluir ingredientes | Despensa |
| RF04 | Cadastrar prato | Prato com os ingredientes e a quantidade de cada um | Pratos |
| RF05 | Montar cardápio da semana | Prato de cada refeição (almoço e jantar) de cada dia | Cardápio da semana |
| RF06 | Descontar ingredientes | Ao marcar o prato como preparado, desconta da despensa | Cardápio → "Preparado" / "Desfazer" |
| RF07 | Alertar estoque baixo | Destacar ingredientes abaixo do estoque mínimo | Despensa e Lista de compras |
| RF08 | Gerar lista de compras | Ingredientes que faltam para o cardápio da semana | Lista de compras |

### 3. Requisitos não funcionais

| Código | Categoria | Descrição |
|---|---|---|
| RNF01 | Usabilidade | Telas simples, em português, sem precisar de treinamento |
| RNF02 | Usabilidade | Na voz, o texto reconhecido aparece nos campos para conferir antes de salvar |
| RNF03 | Eficiência | Consultas e listagens em até 2 segundos |
| RNF04 | Confiabilidade | Dados gravados no cadastro e mantidos ao fechar o app |
| RNF05 | Proteção | Dados somente no aparelho; a fala é processada pelo serviço de reconhecimento do Android e não é gravada pelo app |
| RNF06 | Ambiental | Android; funciona sem internet, exceto o cadastro por voz, que pode exigir conexão conforme o aparelho |
| RNF07 | Desenvolvimento | Flutter (Dart), Android Studio, SQLite (`sqflite`) e voz (`speech_to_text`) |
| RNF08 | Desenvolvimento | Estrutura da aula: pastas `model`, `telas`, `control` e `widgets` (MVC) |
| RNF09 | Desenvolvimento | Somente os layouts Row, Column, Flex/Expanded e ListView |
| RNF10 | Desenvolvimento | Código no GitHub, com entregas semanais |

### 4. Arquitetura (padrão derivado do MVC, como ensinado em aula)

| Camada | Pasta | Responsabilidade |
|---|---|---|
| Model | `lib/model/` | Classes de dados: `Ingrediente`, `Prato`, `Cardapio` (campos `final`, construtor com `required`, `toString()` e `toMap()`) |
| View | `lib/telas/` e `lib/widgets/` | Telas (`StatefulWidget` + `_body()` com `ListView`) e componentes reutilizáveis |
| Control | `lib/control/` | Acesso ao banco SQLite, no molde da classe `ControlCliente` da aula (`startDatabase`, `_onCreate`, SQL com `rawInsert`/`rawQuery`) |

**Justificativa:** o MVC separa os dados, as telas e o acesso ao banco, o que facilita a manutenção e segue a estrutura exigida pela disciplina.

### 5. Banco de dados

| Item | Especificação |
|---|---|
| Opção escolhida | **SQLite local** (entre as três opções do professor: SQLite, Firebase ou Broker MQTT) |
| Pacote | `sqflite` |
| Arquivo | `cardapio.db`, criado no próprio aparelho na primeira execução (`_onCreate`) |
| Por que SQLite | Os dados são pessoais e usados só no aparelho; funciona sem internet e não precisa de servidor nem de conta. Firebase exigiria internet e cadastro; MQTT é voltado para troca de mensagens entre dispositivos (IoT), não para guardar dados |

**Tabelas**

| Tabela | Campos | Função |
|---|---|---|
| `ingrediente` | id INTEGER (PK), nome TEXT, quantidade REAL, unidade TEXT, minimo REAL | A despensa |
| `prato` | id INTEGER (PK), nome TEXT | As receitas |
| `prato_ingrediente` | id INTEGER (PK), id_prato INTEGER, id_ingrediente INTEGER, quantidade REAL | O que cada prato usa (liga prato a ingrediente) |
| `cardapio` | id INTEGER (PK), dia_semana TEXT, refeicao TEXT, id_prato INTEGER, preparado INTEGER (0/1) | O prato de cada refeição da semana |

**Relacionamentos:** um prato tem vários ingredientes e um ingrediente pode estar em vários pratos (ligação pela tabela `prato_ingrediente`). Cada linha do `cardapio` aponta para um prato.

### 6. Layouts utilizados

Somente os permitidos na disciplina:
- **Row:** linhas das tabelas e campos lado a lado
- **Column:** grupos de campos e o menu
- **Expanded (flex):** colunas proporcionais nas tabelas (ex.: flex 2/3/3 no cardápio)
- **ListView:** o corpo de todas as telas

### 7. Tecnologias e versões

| Item | Versão / detalhe |
|---|---|
| Linguagem | Dart |
| Framework | Flutter (SDK ≥ 3.44) |
| IDE | Android Studio |
| Plataforma | Android (testado no Samsung Galaxy A23) |
| Banco | `sqflite` 2.4.5 |
| Voz | `speech_to_text` 7.5.0 |
| Permissões | `RECORD_AUDIO` (microfone) e `INTERNET` (reconhecimento de voz) |

### 8. Estrutura de pastas

```
lib/
  main.dart                     inicia o app (MaterialApp) e abre o Menu
  model/
    ingrediente.dart            classe Ingrediente + conversão de unidades (g/kg, ml/l)
    prato.dart                  classe Prato
    cardapio.dart               classe Cardapio + leitura do dia e da refeição
  control/
    control_ingrediente.dart    cadastrar, consultar, editar, excluir, estoque baixo
    control_prato.dart          cadastrar prato e ligar ingredientes
    control_cardapio.dart       montar semana, preparar/desfazer, lista de compras
  telas/
    menu.dart                   menu principal
    tela_Ingrediente.dart       RF01, RF02
    tela_despensa.dart          RF03, RF07
    tela_prato.dart             RF04
    tela_cardapio.dart          RF05, RF06
    tela_compras.dart           RF07, RF08
  widgets/
    widget_button.dart          Buttons (da aula)
    widget_input.dart           InputTextos (da aula)
    widget_text_custom.dart     TextosCustom
    widget_cartao.dart          Cartao (caixa arredondada que agrupa os elementos)
    cores.dart                  paleta de cores do app
```

### 9. Entregas no GitHub

| Versão (tag) | Conteúdo | Data |
|---|---|---|
| `v0.1.0` | Telas iniciais | 08/11/2026 |
| `v0.2.0` | Visual novo e README | 12/11/2026 |
| `v0.3.0` | Correções de unidades e de pratos | 16/11/2026 |
| `v0.4.0` | Melhorias de usabilidade | 19/11/2026 |
| `v1.0.0` | Versão da apresentação | até 24/11/2026 |

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
2. **Pratos:** "arroz com feijão", com arroz 500 g e feijão 250 g (o app converte para 0,5 e 0,25 kg).
3. **Cardápio:** segunda, almoço, arroz com feijão → Salvar.
4. **Lista de compras:** o feijão aparece para comprar.
5. **Cardápio:** segunda + botão Almoço → **Preparado** (com feijão suficiente na despensa).
6. **Despensa:** o arroz passa para 1,5 kg, e o feijão aparece em vermelho com ⚠.
