# Dicionário de dados · ES Stock

Base de dados MySQL `es_stock` (script `database/create.sql`). PK = chave primária, FK = chave estrangeira.

## utilizador
Pessoas que usam a app.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| id | INT UNSIGNED | PK, auto incremento | Identificador |
| nome | VARCHAR(100) | obrigatório | Nome completo |
| email | VARCHAR(120) | obrigatório, único | Utilizado no login |
| password_hash | VARCHAR(100) | obrigatório | Hash bcrypt da palavra-passe |
| perfil | ENUM('operador','gestor') | obrigatório, por omissão `operador` | Define o que pode fazer na app |
| ativo | TINYINT(1) | por omissão 1 | 0 impede o login |
| criado_em | TIMESTAMP | por omissão agora | Data de criação |

## categoria
| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| id | INT UNSIGNED | PK | Identificador |
| nome | VARCHAR(60) | obrigatório, único | Por exemplo Cabos |
| prefixo | CHAR(3) | obrigatório, único | Entra no código do artigo (CAB) |

## localizacao
| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| id | INT UNSIGNED | PK | Identificador |
| zona | VARCHAR(40) | obrigatório | Por exemplo Armazém A |
| prateleira | VARCHAR(40) | obrigatório | Por exemplo Prat. 1 (a combinação zona + prateleira é única) |

## artigo
| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| id | INT UNSIGNED | PK | Identificador |
| codigo_qr | VARCHAR(20) | obrigatório, único | Conteúdo do QR Code, formato `ES-CAB-0107` |
| nome | VARCHAR(120) | obrigatório | Nome do artigo |
| fornecedor | VARCHAR(80) | por omissão vazio | Fornecedor habitual |
| unidade | VARCHAR(10) | por omissão `un` | Unidade de medida |
| stock_atual | INT | ≥ 0 | Unidades em armazém |
| stock_minimo | INT | ≥ 0 | Abaixo ou igual a este valor gera alerta |
| ativo | TINYINT(1) | por omissão 1 | 0 = desativado (não se apaga, para manter o histórico) |
| categoria_id | INT UNSIGNED | FK → categoria.id | Categoria |
| localizacao_id | INT UNSIGNED | FK → localizacao.id | Onde está arrumado |
| criado_em | TIMESTAMP | por omissão agora | Data de criação |

## movimento
Cada entrada, saída ou ajuste de stock.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| id | INT UNSIGNED | PK | Identificador |
| tipo | ENUM('entrada','saida','ajuste') | obrigatório | Tipo de movimento |
| quantidade | INT UNSIGNED | > 0 (exceto ajuste) | Unidades movimentadas; no ajuste, a diferença em valor absoluto |
| stock_depois | INT | pode ser nulo | Stock do artigo logo a seguir (nulo nos dados históricos de exemplo) |
| destino_origem | VARCHAR(120) | por omissão vazio | Cliente de destino (saída) ou fornecedor (entrada) |
| data_hora | DATETIME | por omissão agora | Quando aconteceu |
| artigo_id | INT UNSIGNED | FK → artigo.id | Artigo movimentado |
| utilizador_id | INT UNSIGNED | FK → utilizador.id | Quem registou |

## alerta
| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| id | INT UNSIGNED | PK | Identificador |
| data_hora | DATETIME | por omissão agora | Quando o alerta foi criado |
| resolvido | TINYINT(1) | por omissão 0 | 1 quando o stock volta acima do mínimo |
| artigo_id | INT UNSIGNED | FK → artigo.id | Artigo em alerta |
| movimento_id | INT UNSIGNED | FK → movimento.id, pode ser nulo | Movimento que o provocou |

## Vistas e procedimento

| Objeto | Para que serve |
|---|---|
| `v_artigo` | Artigo com categoria, localização e `estado` (`ok`, `baixo`, `sem_stock`) |
| `v_movimento` | Movimento com o nome do artigo e do utilizador |
| `v_consumo_semanal` | Total de saídas por artigo e por semana, base das estatísticas |
| `sp_registar_movimento` | Valida e regista um movimento numa transação: bloqueia o artigo, atualiza o stock, grava o movimento e cria ou fecha o alerta |

## Guia de dados (dados de exemplo)

| Tabela | Registos | Observações |
|---|---|---|
| utilizador | 7 | 1 gestor (Dorivaldo Domingos) e 6 operadores; palavra-passe de teste `EsStock2026!` |
| categoria | 6 | Alarmes, Automação, Cabos, Câmaras, Redes, Sensores |
| localizacao | 7 | Armazéns A, B e C, com 2 ou 3 prateleiras |
| artigo | 23 | 4 em alerta: ES-CAB-0107 (sem stock), ES-AUT-0010, ES-RED-0013 e ES-ALM-0003 |
| movimento | 76 | 14 recentes e cerca de 60 saídas semanais nas últimas 9 semanas para as estatísticas; datas relativas ao dia da execução |
| alerta | 4 | Um por artigo em alerta |

Todos os dados são fictícios.
