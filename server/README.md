# server/
API REST do ES Stock em Node.js + Express, ligada a MySQL, no padrão MVC.

```
src/
├── server.js          # arranca o servidor
├── app.js             # Express, rotas e tratamento de erros
├── config/db.js       # pool de ligações MySQL
├── routes/index.js    # liga cada endpoint ao seu controller
├── controllers/       # validam o pedido e respondem (auth, artigo, movimento, estatística)
├── models/            # SQL: utilizador, artigo, catálogo, movimento, estatística (Monte Carlo)
├── middleware/        # auth.js (JWT e perfil) e erros.js
└── utils/erros.js     # ErroHttp e wrapper para controllers async
test/api.test.js       # 11 testes (node:test), precisam do servidor a correr
```

## Executar

```bash
npm install
cp .env.example .env     # preencher DB_USER, DB_PASSWORD e JWT_SECRET
npm start                # http://localhost:3000
npm test                 # noutro terminal, com a BD populada (11 testes)
```

A base de dados tem de existir antes (`database/create.sql` e `database/populate.sql`). Documentação dos endpoints em [`../docs/documentacao-rest.md`](../docs/documentacao-rest.md).

## Notas

- Palavras-passe com bcrypt; sessão com token JWT (8 horas por omissão).
- As regras de stock (saída acima do stock, destino obrigatório) são aplicadas no procedimento `sp_registar_movimento`, não só no servidor.
- O stock mínimo sugerido usa 5000 simulações de Monte Carlo por artigo, com semente fixa: o mesmo histórico dá sempre a mesma sugestão.
