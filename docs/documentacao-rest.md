# Documentação da API REST · ES Stock

Primeira versão, no formato sugerido em [Documenting your API](https://bocoup.com/blog/documenting-your-api).

- **URL base (desenvolvimento):** `http://localhost:3000`
- **Formato:** JSON (UTF-8), cabeçalho `Content-Type: application/json`
- **Autenticação:** token JWT no cabeçalho `Authorization: Bearer <token>`. Só `/saude` e `/auth/login` são públicos.
- **Perfis:** `operador` consulta e regista movimentos; `gestor` faz o mesmo e ainda cria e edita artigos e vê as estatísticas.
- **Erros:** resposta `{ "erro": "mensagem" }` com o código HTTP adequado (400, 401, 403, 404, 409, 500).

Os exemplos usam os dados de `database/populate.sql`.

---

## Autenticação

### POST /auth/login
Autentica o utilizador e devolve o token.

* **Parâmetros de URL:** nenhum
* **Corpo (JSON):** `email` (texto, obrigatório), `password` (texto, obrigatório)
* **Resposta de sucesso:** `200`
  ```json
  { "token": "eyJhbGciOi...", "utilizador": { "id": 1, "nome": "Dorivaldo Domingos", "perfil": "gestor" } }
  ```
* **Respostas de erro:** `400` (campos em falta), `401` (credenciais inválidas)
* **Exemplo:**
  ```bash
  curl -X POST http://localhost:3000/auth/login -H "Content-Type: application/json" \
       -d '{"email":"dorivaldo.domingos@electrosmart.example","password":"EsStock2026!"}'
  ```

### POST /auth/registar
Cria uma conta nova. A conta fica sempre com o perfil `operador`; o gestor é criado pelo grupo na base de dados. Devolve o token, por isso a sessão fica iniciada.

* **Corpo (JSON):** `nome` (mínimo 2 caracteres), `email` (válido e único), `password` (mínimo 8 caracteres)
* **Resposta de sucesso:** `201`
  ```json
  { "token": "eyJhbGciOi...", "utilizador": { "id": 8, "nome": "Maria Santos", "perfil": "operador" } }
  ```
* **Respostas de erro:** `400` (dados inválidos), `409` (já existe uma conta com esse email)
* **Exemplo:**
  ```bash
  curl -X POST http://localhost:3000/auth/registar -H "Content-Type: application/json" \
       -d '{"nome":"Maria Santos","email":"maria.santos@electrosmart.example","password":"palavra123"}'
  ```

### GET /utilizadores
Lista os utilizadores ativos (usado no filtro do histórico).

* **Resposta de sucesso:** `200` `[ { "id": 1, "nome": "Dorivaldo Domingos", "perfil": "gestor" }, ... ]`
* **Respostas de erro:** `401`

---

## Artigos

### GET /artigos
Lista os artigos ativos, por ordem de nome.

* **Parâmetros de URL (opcionais):** `q` (texto no nome ou no código), `categoria` (nome da categoria)
* **Resposta de sucesso:** `200`
  ```json
  [ { "id": 15, "codigo": "ES-RED-0009", "nome": "Switch PoE 8 portas", "categoria": "Redes",
      "localizacao": "Armazém A · Prat. 2", "fornecedor": "NetPro", "unidade": "un",
      "stock": 7, "stockMinimo": 3, "estado": "ok", "ativo": true } ]
  ```
  `estado` é `ok`, `baixo` (stock ≤ mínimo) ou `sem_stock` (stock = 0).
* **Respostas de erro:** `401`
* **Exemplo:** `curl "http://localhost:3000/artigos?categoria=Redes&q=switch" -H "Authorization: Bearer $TOKEN"`

### GET /artigos/codigo/:codigo
Devolve o artigo a partir do código lido no QR Code.

* **Parâmetros de URL:** `codigo` (por exemplo `ES-CAB-0107`)
* **Resposta de sucesso:** `200`, um artigo como no exemplo acima
* **Respostas de erro:** `401`, `404` (`Nenhum artigo com esse código`)

### GET /artigos/:id
Devolve um artigo pelo identificador.

* **Parâmetros de URL:** `id` (inteiro)
* **Resposta de sucesso:** `200`
* **Respostas de erro:** `400` (id inválido), `401`, `404`

### GET /artigos/proximo-codigo
Devolve o próximo código livre de uma categoria.

* **Parâmetros de URL:** `categoriaId` (inteiro, obrigatório)
* **Resposta de sucesso:** `200` `{ "codigo": "ES-AUT-0011" }`
* **Respostas de erro:** `400`, `401`, `404` (categoria inexistente)

### POST /artigos
Cria um artigo com stock 0 e gera o código QR. **Só o gestor.**

* **Corpo (JSON):** `nome` (obrigatório), `categoriaId` (obrigatório), `localizacaoId` (obrigatório), `fornecedor`, `unidade` (por omissão `un`), `stockMinimo` (inteiro ≥ 0)
* **Resposta de sucesso:** `201`, o artigo criado, por exemplo com `"codigo": "ES-AUT-0011"`
* **Respostas de erro:** `400` (dados inválidos), `401`, `403` (não é gestor), `404` (categoria inexistente)
* **Exemplo:**
  ```bash
  curl -X POST http://localhost:3000/artigos -H "Authorization: Bearer $TOKEN" \
       -H "Content-Type: application/json" \
       -d '{"nome":"Sensor de movimento PIR","categoriaId":6,"localizacaoId":5,"stockMinimo":4}'
  ```

### PUT /artigos/:id
Atualiza campos do artigo. **Só o gestor.**

* **Corpo (JSON), todos opcionais:** `nome`, `fornecedor`, `unidade`, `stockMinimo`, `categoriaId`, `localizacaoId`
* **Resposta de sucesso:** `200`, o artigo atualizado
* **Respostas de erro:** `400`, `401`, `403`, `404`

### DELETE /artigos/:id
Desativa o artigo (não apaga, para manter o histórico). **Só o gestor.**

* **Resposta de sucesso:** `204` sem corpo
* **Respostas de erro:** `400`, `401`, `403`, `404`

### GET /categorias e GET /localizacoes
Listas usadas nos formulários.

* **Resposta de sucesso:** `200`
  `[ { "id": 3, "nome": "Cabos", "prefixo": "CAB" } ]` e `[ { "id": 1, "zona": "Armazém A", "prateleira": "Prat. 1", "nome": "Armazém A · Prat. 1" } ]`

---

## Movimentos

### POST /movimentos
Regista uma entrada, saída ou ajuste. A operação corre numa transação (procedimento `sp_registar_movimento`): valida, atualiza o stock, grava o movimento e cria ou fecha o alerta.

* **Corpo (JSON):** `codigo` (obrigatório), `tipo` (`entrada`, `saida` ou `ajuste`), `quantidade` (inteiro; no ajuste é o stock contado), `destinoOrigem` (obrigatório na saída)
* **Resposta de sucesso:** `201`
  ```json
  { "movimentoId": 77, "stockAntes": 7, "stockDepois": 2, "stockMinimo": 3, "emAlerta": true }
  ```
* **Respostas de erro:** `400` (`A saída precisa de um destino`, `Stock insuficiente para esta saída`, tipo ou quantidade inválidos), `401`, `404` (artigo inexistente)
* **Exemplo:**
  ```bash
  curl -X POST http://localhost:3000/movimentos -H "Authorization: Bearer $TOKEN" \
       -H "Content-Type: application/json" \
       -d '{"codigo":"ES-RED-0009","tipo":"saida","quantidade":5,"destinoOrigem":"Hotel Sol Algarve"}'
  ```

### GET /movimentos
Histórico, do mais recente para o mais antigo.

* **Parâmetros de URL (opcionais):** `tipo`, `dias` (1 = só hoje, 7, 30...), `utilizador` (nome), `artigo` (texto no nome ou código), `codigo` (código exato), `limite` (máximo 500, por omissão 200)
* **Resposta de sucesso:** `200`
  ```json
  [ { "id": 77, "codigo": "ES-RED-0009", "artigo": "Switch PoE 8 portas", "tipo": "saida",
      "quantidade": 5, "stockDepois": 2, "utilizador": "Dorivaldo Domingos",
      "dataHora": "2026-11-07 15:55:16", "destinoOrigem": "Hotel Sol Algarve" } ]
  ```
* **Respostas de erro:** `400` (filtro inválido), `401`

### GET /movimentos/resumo
Números do ecrã Início.

* **Resposta de sucesso:** `200` `{ "movimentosHoje": 3, "saidasUltimos7Dias": 45 }`

---

## Alertas e estatísticas

### GET /alertas
Artigos com stock igual ou abaixo do mínimo, do mais crítico para o menos crítico.

* **Resposta de sucesso:** `200`, lista de artigos (formato de `GET /artigos`)

### GET /estatisticas
Consumo semanal e stock mínimo sugerido. **Só o gestor.** Inclui só artigos com pelo menos 4 semanas de saídas.

* **Resposta de sucesso:** `200`
  ```json
  [ { "codigo": "ES-CAB-0107", "nome": "Cabo HDMI 2 m", "minimoAtual": 10,
      "mediaSemanal": 8.2, "desvioPadrao": 3.28, "semanas": 10, "sugerido": 14 } ]
  ```
  `sugerido` vem de uma simulação de Monte Carlo: 5000 semanas de consumo simuladas com distribuição normal (média e desvio do histórico); o valor devolvido cobre 95% das semanas.
* **Respostas de erro:** `401`, `403`

### GET /saude
Verifica se o servidor está a correr. Público. Resposta `200` `{ "estado": "ok" }`.
