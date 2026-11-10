# BD Report · ES Stock

## 1. Objetivo
A base de dados guarda os artigos do armazém da ElectroSmart Solutions (empresa fictícia), o stock de cada um, todos os movimentos de entrada, saída e ajuste, e os alertas de stock baixo. É relacional, em MySQL, e só é acedida pelo servidor Node.js.

## 2. Modelo
O modelo entidade-relação e o diagrama de classes estão em [diagrama-de-classes.md](diagrama-de-classes.md); cada tabela e coluna está descrita em [dicionario-de-dados.md](dicionario-de-dados.md).

Seis tabelas: `utilizador`, `categoria`, `localizacao`, `artigo`, `movimento` e `alerta`. Um artigo pertence a uma categoria e a uma localização; cada movimento refere um artigo e o utilizador que o registou; cada alerta refere o artigo e, quando existe, o movimento que o provocou.

## 3. Decisões
- **O stock fica no artigo** (`stock_atual`) e cada movimento guarda o `stock_depois`. Assim lê-se o stock sem somar o histórico e, mesmo assim, o histórico permite auditar.
- **Os movimentos nunca se apagam.** Um artigo deixado de usar fica `ativo = 0`.
- **`sp_registar_movimento`** concentra a regra de negócio na base de dados: dentro de uma transação bloqueia a linha do artigo (`FOR UPDATE`), impede saídas acima do stock e saídas sem destino, grava o movimento e cria ou fecha o alerta. Dois operadores a retirar o mesmo artigo ao mesmo tempo não conseguem deixar o stock negativo.
- **Alerta** quando `stock_atual <= stock_minimo`. Só existe um alerta aberto por artigo.
- **Palavras-passe** guardadas com hash bcrypt.
- **Estatísticas:** a vista `v_consumo_semanal` agrega as saídas por semana; o servidor calcula a média e o desvio padrão e aplica uma simulação de Monte Carlo para sugerir o stock mínimo.

## 4. Ficheiros
| Ficheiro | Conteúdo |
|---|---|
| `database/create.sql` | Base de dados, 6 tabelas, 3 vistas e o procedimento |
| `database/populate.sql` | 7 utilizadores, 6 categorias, 7 localizações, 23 artigos, 76 movimentos e 4 alertas |
| `database/queries.sql` | 14 pesquisas: alertas, pesquisa por QR, totais por categoria, histórico, consumo por utilizador e por destino, média e desvio padrão semanais, artigos parados, função de janela |

## 5. Como criar
```bash
mysql -u root -p < database/create.sql
mysql -u root -p es_stock < database/populate.sql
mysql -u root -p es_stock < database/queries.sql   # opcional: corre as pesquisas
```
