# Diagrama de classes e modelo ER · ES Stock

## Diagrama de classes (conceptual)

```mermaid
classDiagram
  class Utilizador {
    +int id
    +String nome
    +String email
    +String perfil
    +login()
  }
  class Categoria {
    +int id
    +String nome
    +String prefixo
  }
  class Localizacao {
    +int id
    +String zona
    +String prateleira
  }
  class Artigo {
    +int id
    +String codigoQr
    +String nome
    +int stockAtual
    +int stockMinimo
    +emAlerta() bool
  }
  class Movimento {
    +int id
    +String tipo
    +int quantidade
    +DateTime dataHora
    +String destinoOrigem
  }
  class Alerta {
    +int id
    +DateTime dataHora
    +bool resolvido
  }
  Categoria "1" --> "*" Artigo : classifica
  Localizacao "1" --> "*" Artigo : armazena
  Artigo "1" --> "*" Movimento : sofre
  Utilizador "1" --> "*" Movimento : regista
  Artigo "1" --> "*" Alerta : gera
  Movimento "0..1" --> "*" Alerta : provoca
```

## Modelo entidade-relação

```mermaid
erDiagram
  CATEGORIA ||--o{ ARTIGO : classifica
  LOCALIZACAO ||--o{ ARTIGO : armazena
  ARTIGO ||--o{ MOVIMENTO : sofre
  UTILIZADOR ||--o{ MOVIMENTO : regista
  ARTIGO ||--o{ ALERTA : gera
  MOVIMENTO |o--o{ ALERTA : provoca
  UTILIZADOR {
    int id PK
    string nome
    string email UK
    string password_hash
    enum perfil
    bool ativo
  }
  CATEGORIA {
    int id PK
    string nome UK
    char prefixo UK
  }
  LOCALIZACAO {
    int id PK
    string zona
    string prateleira
  }
  ARTIGO {
    int id PK
    string codigo_qr UK
    string nome
    string fornecedor
    string unidade
    int stock_atual
    int stock_minimo
    bool ativo
    int categoria_id FK
    int localizacao_id FK
  }
  MOVIMENTO {
    int id PK
    enum tipo
    int quantidade
    int stock_depois
    string destino_origem
    datetime data_hora
    int artigo_id FK
    int utilizador_id FK
  }
  ALERTA {
    int id PK
    datetime data_hora
    bool resolvido
    int artigo_id FK
    int movimento_id FK
  }
```

## Organização do código (MVC)

| Camada | Servidor (Node.js) | App (Flutter) |
|---|---|---|
| Model | `src/models/` (acesso à BD) | `lib/models/` (classes Artigo, Movimento, Estatistica) |
| Controller | `src/controllers/` (regras e respostas HTTP) | `lib/controllers/` (dados em memória e chamadas à API) |
| View / rotas | `src/routes/` (endpoints JSON) | `lib/views/` (ecrãs e widgets) |
| Serviços | `src/middleware/` (token, erros) | `lib/services/api_service.dart` (pedidos HTTP) |
