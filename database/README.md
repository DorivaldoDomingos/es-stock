# database/
Base de dados MySQL do ES Stock.

| Ficheiro | Conteúdo |
|---|---|
| `create.sql` | Cria a base `es_stock`, as 6 tabelas, as vistas `v_artigo`, `v_movimento` e `v_consumo_semanal` e o procedimento `sp_registar_movimento` |
| `populate.sql` | Dados fictícios: 7 utilizadores, 6 categorias, 7 localizações, 23 artigos, 76 movimentos e 4 alertas (palavra-passe de teste `EsStock2026!`) |
| `queries.sql` | 14 pesquisas relevantes (alertas, pesquisa por código, totais, histórico, média e desvio padrão do consumo, artigos parados, função de janela) |

```bash
mysql -u root -p < create.sql
mysql -u root -p es_stock < populate.sql
mysql -u root -p es_stock < queries.sql
```

O `create.sql` apaga e recria a base `es_stock`. Modelo ER e dicionário de dados em [`../docs`](../docs). Testado em MySQL 8 e MariaDB 10.
