# ES Stock — Gestão de Inventário com Código QR

Aplicação móvel para controlar o inventário do armazém da **ElectroSmart Solutions** (empresa fictícia de segurança eletrónica, redes e automação de edifícios).

Projeto Mobile · Licenciatura em Engenharia Informática · Universidade Europeia, IADE · 3.º semestre de 2026-27 · **Grupo 07**

![Estado](https://img.shields.io/badge/estado-1.%C2%AA%20entrega-blue)
![Flutter](https://img.shields.io/badge/app-Flutter%20%2F%20Dart-02569B)
![Node.js](https://img.shields.io/badge/API-Node.js%20%2B%20Express-339933)
![MySQL](https://img.shields.io/badge/BD-MySQL-4479A1)

---

## Índice

1. [O projeto](#o-projeto)
2. [Estado atual](#estado-atual)
3. [Funcionalidades](#funcionalidades)
4. [Arquitetura](#arquitetura)
5. [Estrutura do repositório](#estrutura-do-repositório)
6. [Como executar](#como-executar)
7. [API REST](#api-rest)
8. [Base de dados](#base-de-dados)
9. [Design e mockups](#design-e-mockups)
10. [Planeamento e entregas](#planeamento-e-entregas)
11. [Equipa](#equipa)
12. [Fluxo de trabalho no Git](#fluxo-de-trabalho-no-git)
13. [Dados e RGPD](#dados-e-rgpd)

---

## O projeto

O armazém da ElectroSmart guarda câmaras, routers, sensores e cabos que são levantados para instalações em clientes. Hoje o controlo é feito em papel ou folhas de cálculo, o que leva a três problemas:

- **Stock incorreto:** o stock registado não coincide com o real.
- **Falta descoberta tarde:** só se percebe que falta material quando ele é preciso.
- **Falta de rastreabilidade:** não é fácil saber quem levantou o quê, quando e para onde.

No **ES Stock**, cada artigo tem um **QR Code** próprio. O operador lê o código com a câmara do telemóvel, indica a quantidade e confirma. O stock atualiza-se de imediato, a app avisa quando um artigo fica abaixo do mínimo e todos os movimentos ficam guardados num histórico com filtros.

> **Pergunta de partida:** como pode uma aplicação móvel simples, baseada em QR Code, tornar o controlo do stock de um armazém mais rápido, fiável e rastreável?

## Estado atual

| Componente | Estado |
|---|---|
| Proposta inicial e planeamento | Concluído (1.ª entrega) |
| Mockups no Figma (14 ecrãs) | Concluído |
| Base de dados MySQL | A desenvolver (2.ª entrega) |
| API REST (Node.js) | A desenvolver (2.ª entrega) |
| App Flutter | A desenvolver (2.ª e 3.ª entregas) |

As instruções de execução abaixo descrevem o resultado previsto e serão confirmadas à medida que o código for entregue.

## Funcionalidades

**Obrigatórias (MVP)**

- Autenticação com perfis de operador e de gestor
- Criar, consultar, editar e desativar artigos
- QR Code único por artigo, pronto para imprimir em etiqueta
- Ler o QR Code com a câmara e abrir a ficha do artigo
- Registar entradas, saídas e ajustes, com atualização automática do stock
- Stock mínimo por artigo e lista de alertas de stock baixo

**Importantes**

- Histórico de movimentos com pesquisa e filtros (artigo, data, tipo, utilizador)
- Gestão de categorias e localizações

**Extras, se houver tempo**

- Estatísticas de consumo (média e desvio padrão)
- Notificação local de stock baixo
- Simulação de Monte Carlo para sugerir o stock mínimo

**Requisitos não funcionais:** Android testado num telemóvel real (iOS se possível), movimento registado em menos de 30 segundos, palavras-passe com *hash* (bcrypt) e comunicação autenticada por token, código em módulos segundo o padrão MVC.

## Arquitetura

```
┌──────────────────┐   HTTP + JSON    ┌───────────────────────┐   SQL    ┌─────────┐
│  App móvel       │ ───────────────► │  Servidor REST        │ ───────► │  MySQL  │
│  Flutter / Dart  │ ◄─────────────── │  Node.js + Express    │ ◄─────── │         │
└──────────────────┘     (JWT)        └───────────────────────┘          └─────────┘
```

A app **nunca acede diretamente** à base de dados. O servidor valida os pedidos, aplica as regras de negócio (por exemplo, impedir uma saída maior do que o stock) e guarda a informação.

**Padrão MVC**

- App Flutter: `models/`, `services/` (chamadas à API), `screens/` e `widgets/` (vista), `providers/` (estado)
- Servidor Node.js: `routes/`, `controllers/`, `models/` e acesso a dados

| Área | Tecnologia |
|---|---|
| App móvel | Flutter e Dart, editor VS Code |
| QR Code | `mobile_scanner` (leitura) e `qr_flutter` (geração) |
| Servidor | Node.js com Express |
| Base de dados | MySQL (MySQL Workbench) |
| Autenticação | JWT e bcrypt |
| Mockups | Figma |
| Gestão do projeto | Git, GitHub e GitHub Projects |
| Testes da API | Postman ou REST Client do VS Code |

## Estrutura do repositório

```
es-stock/
├── README.md
├── docs/                 # Relatórios e documentação
│   ├── g07-proposta-v1.pdf
│   └── imagens/          # Imagens img_NN.jpg do arquivo da entrega
├── app/                  # App Flutter (MVC)
│   └── lib/
│       ├── models/
│       ├── services/
│       ├── providers/
│       ├── screens/
│       └── widgets/
├── server/               # API REST em Node.js
│   └── src/
│       ├── routes/
│       ├── controllers/
│       ├── models/
│       └── config/
├── database/             # Scripts MySQL
│   ├── create.sql
│   ├── populate.sql
│   └── queries.sql
└── design/               # Exportações do Figma
```

Algumas pastas só aparecem nas entregas seguintes.

## Como executar

### Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) e VS Code com as extensões Flutter e Dart
- [Node.js](https://nodejs.org) (versão LTS)
- [MySQL](https://dev.mysql.com/doc/) e MySQL Workbench
- Um telemóvel Android com depuração USB, ou um emulador

### 1. Base de dados

```bash
mysql -u root -p < database/create.sql
mysql -u root -p es_stock < database/populate.sql
```

### 2. Servidor

```bash
cd server
npm install
cp .env.example .env      # preencher ligação à BD e segredo JWT
npm start
```

Variáveis previstas no `.env`: `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `JWT_SECRET`, `PORT`.

### 3. App

```bash
cd app
flutter pub get
flutter run
```

No telemóvel, o endereço do servidor tem de ser o IP do computador na rede local, não `localhost`.

## API REST

Esboço dos endpoints principais (pode ser ajustado). A documentação completa seguirá o formato indicado no briefing.

| Método | Rota | Descrição |
|---|---|---|
| POST | `/auth/login` | Autenticar utilizador |
| GET | `/artigos` | Listar artigos (com filtros) |
| GET | `/artigos/:id` | Obter artigo (também pelo código QR) |
| POST | `/artigos` | Criar artigo |
| PUT | `/artigos/:id` | Editar artigo |
| POST | `/movimentos` | Registar entrada, saída ou ajuste |
| GET | `/movimentos` | Consultar histórico com filtros |
| GET | `/alertas` | Listar alertas de stock baixo |

## Base de dados

Seis entidades chegam para o essencial:

| Entidade | Atributos principais |
|---|---|
| **Utilizador** | nome, email, palavra-passe (hash), perfil |
| **Categoria** | nome |
| **Localização** | zona, prateleira |
| **Artigo** | nome, código QR, stock atual, stock mínimo, categoria, localização |
| **Movimento** | tipo, quantidade, data e hora, destino, artigo, utilizador |
| **Alerta** | data e hora, resolvido, artigo |

Relações: uma categoria classifica muitos artigos, uma localização armazena muitos artigos, um artigo sofre muitos movimentos e gera muitos alertas, e um utilizador regista muitos movimentos. Os diagramas de domínio e entidade-relação estão no Anexo B da proposta.

## Design e mockups

14 ecrãs de 390 × 844 px, protótipo navegável, guia de estilo e componentes no Figma:

**[Abrir no Figma](https://www.figma.com/design/iTl0La3VYJ54sVbYtJSMl0)**

Identidade visual: azul-marinho como cor principal e verde-lima para a ação principal, com a tipografia Inter. Os botões têm 52 px de altura e a ação principal fica sempre em baixo, para uso com uma mão.

| Guião | Ator | Ecrãs | Objetivo |
|---|---|---|---|
| 1. Registar a saída de material | Operador | 01 a 06 | Ler o QR, indicar a quantidade e confirmar; o alerta aparece se o stock ficar abaixo do mínimo |
| 2. Criar um artigo e registar a entrada | Gestor | 07 a 11 | Criar o artigo, gerar o QR para a etiqueta e registar a entrada inicial |
| 3. Consultar alertas e histórico | Gestor | 02, 12, 13 e 14 | Ver o que repor e filtrar movimentos por tipo, período e utilizador |

## Planeamento e entregas

| Entrega | Data | Conteúdo |
|---|---|---|
| 1.ª | 02/10/2026 | Proposta inicial, planeamento e mockups |
| 2.ª | 06/11/2026 | Protótipo alfa: API, base de dados e app a ler QR e a consumir a API |
| 3.ª | 11/12/2026 | App completa num telemóvel real, com movimentos, alertas e histórico; documentação, poster e vídeo |

As tarefas, responsáveis e prazos estão no separador **Projects** deste repositório.

**Riscos:** inexperiência em Flutter e atrasos na integração app–API. **Mitigação:** entregar primeiro um MVP, ciclos curtos e revisões semanais.

## Equipa

| Elemento | N.º de estudante | Áreas principais |
|---|---|---|
| Alcides Sequeira | 20252127 | App Flutter (ecrãs e navegação), mockups, usabilidade e testes |
| Dorivaldo Domingos | 20252018 | Base de dados, documentação, GitHub e apresentações |
| Vladmir Benoliel | 20251897 | Servidor REST, QR Code e integração com a API |

Todos participam em todas as áreas, com um responsável por tarefa. **Docente:** Fábio Guilherme.

**Unidades curriculares envolvidas:** Programação de Dispositivos Móveis, Bases de Dados, Redes e Comunicação de Dados, Interfaces e Usabilidade, Matemática Discreta e Projeto Mobile.

## Fluxo de trabalho no Git

- `main`: versão estável, pronta para entregar
- `feature/<nome-curto>`: uma funcionalidade por ramo (por exemplo, `feature/leitura-qr`)
- Cada tarefa do GitHub Project corresponde a uma *issue*; os *pull requests* referem-na com `Closes #n`
- Pelo menos um colega revê cada *pull request* antes de entrar em `main`
- Mensagens de *commit* curtas e no imperativo, por exemplo: `Adiciona ecrã de login`

## Dados e RGPD

Todos os dados usados no projeto (artigos, utilizadores, movimentos e a própria empresa) são **fictícios**. Não há dados pessoais reais no repositório. Nunca se guardam palavras-passe em texto simples nem se publica o ficheiro `.env`.

---

*Universidade Europeia · IADE · Projeto Mobile · 2026-27*
