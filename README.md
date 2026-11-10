# ES Stock — Gestão de Inventário com Código QR

Aplicação móvel para controlar o inventário do armazém da **ElectroSmart Solutions** (empresa fictícia de segurança eletrónica, redes e automação de edifícios).

Projeto Mobile · Licenciatura em Engenharia Informática · Universidade Europeia, IADE · 3.º semestre de 2026-27 · **Grupo 07**

![Estado](https://img.shields.io/badge/estado-2.%C2%AA%20entrega-orange)
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
| Base de dados MySQL (`create.sql`, `populate.sql`, `queries.sql`) | Versão alfa feita (2.ª entrega) |
| API REST (Node.js + Express, MVC) | Versão alfa feita, com 11 testes automáticos (2.ª entrega) |
| App Flutter (models, controllers, views) | Versão alfa a consumir a API: criar conta e login, lista e pesquisa de artigos, leitura de QR, entradas e saídas, alertas, histórico com filtros, estatísticas e novo artigo (2.ª entrega) |
| Documentação REST, dicionário de dados e diagramas | Primeira versão em `docs/` |
| Notificação local, edição completa de artigos, impressão de etiquetas | Previsto para a 3.ª entrega |

A app corre no browser (Chrome) e em Android; o teste num telemóvel real fica para a 3.ª entrega.

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

- App Flutter: `lib/models/`, `lib/controllers/`, `lib/views/` (ecrãs e widgets) e `lib/services/` (chamadas HTTP à API)
- Servidor Node.js: `src/routes/`, `src/controllers/`, `src/models/` (acesso à base de dados) e `src/middleware/`

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
├── LINKS.md              # Figma, apresentação e repositório
├── docs/                 # Relatórios e documentação
│   ├── g07-proposta-v1.pdf / .docx
│   ├── documentacao-rest.md      # API REST (2.ª entrega)
│   ├── guia-teste-no-telemovel.md # APK e API no computador, na rede Wi-Fi
│   ├── dicionario-de-dados.md    # Dicionário de dados e guia de dados
│   ├── diagrama-de-classes.md    # Diagrama de classes e modelo ER
│   ├── bd-report.md              # BD Report
│   └── imagens/          # Diagramas e figuras da proposta
├── Entrega_1/            # Arquivo da 1.ª entrega (PDF + pasta ES_Stock/ 00 a 07)
├── scripts/              # criar_github_project.sh
├── app/                  # App Flutter (MVC): lib/models, lib/controllers, lib/views, lib/services
├── server/               # API REST em Node.js: src/routes, controllers, models, middleware, config
├── database/             # create.sql, populate.sql, queries.sql
└── design/               # Exportações do Figma
```

## Como executar

### Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) e VS Code com as extensões Flutter e Dart
- [Node.js](https://nodejs.org) (versão LTS)
- [MySQL](https://dev.mysql.com/doc/) e MySQL Workbench
- Chrome, um emulador Android ou um telemóvel Android com depuração USB

### 1. Base de dados

```bash
mysql -u root -p < database/create.sql
mysql -u root -p es_stock < database/populate.sql
```

### 2. Servidor

```bash
cd server
npm install
cp .env.example .env      # Windows: copy .env.example .env  (preencher DB_PASSWORD e JWT_SECRET)
npm start                 # http://localhost:3000
npm test                  # com o servidor a correr, corre os 11 testes da API
```

Variáveis do `.env`: `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `JWT_SECRET`, `JWT_EXPIRA` e `PORT`.

### 3. App

```bash
cd 
flutter create .                       # só da primeira vez: gera android/, web/, etc.
dart run tool/configurar_android.dart  # só para Android: permissões de internet e câmara
flutter pub get
flutter run -d chrome                  # ou o emulador / telemóvel
```

Endereço do servidor: no Chrome é `http://localhost:3000`; no emulador Android é `http://10.0.2.2:3000` (já é o valor por omissão); num telemóvel real é o IP do computador na rede local. Pode alterar-se no ecrã de login (rodapé) ou com `flutter run --dart-define=API_URL=http://192.168.1.20:3000`.

**Telemóvel:** o computador serve a API na rede Wi-Fi e a app instala-se por APK. Passo a passo em [docs/guia-teste-no-telemovel.md](docs/guia-teste-no-telemovel.md) (`scripts/preparar_rede_local.ps1` abre a firewall e mostra o IP).

**Criar conta:** no login, «Criar conta». As contas novas são de operador; o gestor é criado na base de dados.

**Utilizadores de teste** (palavra-passe `EsStock2026!`):

| Utilizador | Email | Perfil |
|---|---|---|
| Dorivaldo Domingos | dorivaldo.domingos@electrosmart.example | Gestor |
| Alcides Sequeira | alcides.sequeira@electrosmart.example | Operador |
| Vladmir Benoliel | vladmir.benoliel@electrosmart.example | Operador |

No Chrome a câmara não é usada: o código do artigo (por exemplo `ES-CAB-0107`) introduz-se à mão. Nos telemóveis a leitura é feita pela câmara.

## API REST

Documentação completa, com parâmetros, respostas e exemplos: [docs/documentacao-rest.md](docs/documentacao-rest.md).

| Método | Rota | Descrição | Perfil |
|---|---|---|---|
| POST | `/auth/login` | Autenticar utilizador (devolve token JWT) | público |
| POST | `/auth/registar` | Criar conta de operador | público |
| GET | `/artigos` | Listar artigos, com `q` e `categoria` | todos |
| GET | `/artigos/codigo/:codigo` | Obter artigo pelo código lido no QR | todos |
| GET | `/artigos/:id` | Obter artigo | todos |
| POST | `/artigos` | Criar artigo (gera o código) | gestor |
| PUT | `/artigos/:id` | Editar artigo | gestor |
| DELETE | `/artigos/:id` | Desativar artigo | gestor |
| POST | `/movimentos` | Registar entrada, saída ou ajuste | todos |
| GET | `/movimentos` | Consultar histórico com filtros | todos |
| GET | `/alertas` | Listar alertas de stock baixo | todos |
| GET | `/estatisticas` | Consumo semanal e stock mínimo sugerido (Monte Carlo) | gestor |

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

Relações: uma categoria classifica muitos artigos, uma localização armazena muitos artigos, um artigo sofre muitos movimentos e gera muitos alertas, e um utilizador regista muitos movimentos. Os diagramas de domínio e entidade-relação estão no Anexo B da proposta; a versão da 2.ª entrega (colunas, chaves e restrições) está em [docs/dicionario-de-dados.md](docs/dicionario-de-dados.md) e [docs/diagrama-de-classes.md](docs/diagrama-de-classes.md). O registo de movimentos é feito pelo procedimento `sp_registar_movimento`, numa transação.

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
