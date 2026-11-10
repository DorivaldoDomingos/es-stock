-- ES Stock · create.sql
-- Cria a base de dados, as tabelas, as vistas e o procedimento de movimentos.
-- Testado em MySQL 8 (compatível com MariaDB 10.x).
-- Executar:  mysql -u root -p < database/create.sql

SET NAMES utf8mb4;
DROP DATABASE IF EXISTS es_stock;
CREATE DATABASE es_stock CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE es_stock;

-- ---------------------------------------------------------------
-- Tabelas
-- ---------------------------------------------------------------

CREATE TABLE utilizador (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome          VARCHAR(100) NOT NULL,
  email         VARCHAR(120) NOT NULL,
  password_hash VARCHAR(100) NOT NULL,            -- bcrypt, nunca texto simples
  perfil        ENUM('operador','gestor') NOT NULL DEFAULT 'operador',
  ativo         TINYINT(1) NOT NULL DEFAULT 1,
  criado_em     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_utilizador_email (email)
) ENGINE=InnoDB;

CREATE TABLE categoria (
  id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome    VARCHAR(60) NOT NULL,
  prefixo CHAR(3) NOT NULL,                       -- usado no código do artigo: ES-CAB-0001
  PRIMARY KEY (id),
  UNIQUE KEY uq_categoria_nome (nome),
  UNIQUE KEY uq_categoria_prefixo (prefixo)
) ENGINE=InnoDB;

CREATE TABLE localizacao (
  id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  zona       VARCHAR(40) NOT NULL,                -- por exemplo: Armazém A
  prateleira VARCHAR(40) NOT NULL,                -- por exemplo: Prat. 1
  PRIMARY KEY (id),
  UNIQUE KEY uq_localizacao (zona, prateleira)
) ENGINE=InnoDB;

CREATE TABLE artigo (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo_qr       VARCHAR(20) NOT NULL,           -- conteúdo do QR Code, por exemplo ES-CAB-0107
  nome            VARCHAR(120) NOT NULL,
  fornecedor      VARCHAR(80) NOT NULL DEFAULT '',
  unidade         VARCHAR(10) NOT NULL DEFAULT 'un',
  stock_atual     INT NOT NULL DEFAULT 0,
  stock_minimo    INT NOT NULL DEFAULT 0,
  ativo           TINYINT(1) NOT NULL DEFAULT 1,
  categoria_id    INT UNSIGNED NOT NULL,
  localizacao_id  INT UNSIGNED NOT NULL,
  criado_em       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_artigo_codigo (codigo_qr),
  KEY ix_artigo_categoria (categoria_id),
  KEY ix_artigo_localizacao (localizacao_id),
  CONSTRAINT ck_artigo_stock CHECK (stock_atual >= 0 AND stock_minimo >= 0),
  CONSTRAINT fk_artigo_categoria FOREIGN KEY (categoria_id) REFERENCES categoria (id),
  CONSTRAINT fk_artigo_localizacao FOREIGN KEY (localizacao_id) REFERENCES localizacao (id)
) ENGINE=InnoDB;

CREATE TABLE movimento (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo           ENUM('entrada','saida','ajuste') NOT NULL,
  quantidade     INT UNSIGNED NOT NULL,           -- no ajuste guarda a diferença em valor absoluto
  stock_depois   INT NULL,                        -- stock do artigo logo após o movimento
  destino_origem VARCHAR(120) NOT NULL DEFAULT '',-- cliente (saída) ou fornecedor (entrada)
  data_hora      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  artigo_id      INT UNSIGNED NOT NULL,
  utilizador_id  INT UNSIGNED NOT NULL,
  PRIMARY KEY (id),
  KEY ix_movimento_data (data_hora),
  KEY ix_movimento_artigo (artigo_id, data_hora),
  KEY ix_movimento_utilizador (utilizador_id),
  CONSTRAINT ck_movimento_qtd CHECK (quantidade > 0 OR tipo = 'ajuste'),
  CONSTRAINT fk_movimento_artigo FOREIGN KEY (artigo_id) REFERENCES artigo (id),
  CONSTRAINT fk_movimento_utilizador FOREIGN KEY (utilizador_id) REFERENCES utilizador (id)
) ENGINE=InnoDB;

CREATE TABLE alerta (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  data_hora    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolvido    TINYINT(1) NOT NULL DEFAULT 0,
  artigo_id    INT UNSIGNED NOT NULL,
  movimento_id INT UNSIGNED NULL,                 -- movimento que provocou o alerta
  PRIMARY KEY (id),
  KEY ix_alerta_artigo (artigo_id, resolvido),
  CONSTRAINT fk_alerta_artigo FOREIGN KEY (artigo_id) REFERENCES artigo (id),
  CONSTRAINT fk_alerta_movimento FOREIGN KEY (movimento_id) REFERENCES movimento (id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------
-- Vistas
-- ---------------------------------------------------------------

-- Artigos com os nomes da categoria e da localização e o estado do stock
CREATE VIEW v_artigo AS
SELECT a.id, a.codigo_qr, a.nome, a.fornecedor, a.unidade,
       a.stock_atual, a.stock_minimo, a.ativo,
       c.id AS categoria_id, c.nome AS categoria, c.prefixo,
       l.id AS localizacao_id, CONCAT(l.zona, ' · ', l.prateleira) AS localizacao,
       CASE WHEN a.stock_atual <= 0 THEN 'sem_stock'
            WHEN a.stock_atual <= a.stock_minimo THEN 'baixo'
            ELSE 'ok' END AS estado
FROM artigo a
JOIN categoria c   ON c.id = a.categoria_id
JOIN localizacao l ON l.id = a.localizacao_id;

-- Movimentos com os nomes do artigo e do utilizador
CREATE VIEW v_movimento AS
SELECT m.id, m.tipo, m.quantidade, m.stock_depois, m.destino_origem, m.data_hora,
       a.id AS artigo_id, a.codigo_qr, a.nome AS artigo,
       u.id AS utilizador_id, u.nome AS utilizador
FROM movimento m
JOIN artigo a     ON a.id = m.artigo_id
JOIN utilizador u ON u.id = m.utilizador_id;

-- Total de saídas por artigo e por semana (base das estatísticas)
CREATE VIEW v_consumo_semanal AS
SELECT artigo_id,
       YEARWEEK(data_hora, 3) AS semana,
       SUM(quantidade) AS total_saidas
FROM movimento
WHERE tipo = 'saida'
GROUP BY artigo_id, YEARWEEK(data_hora, 3);

-- ---------------------------------------------------------------
-- Procedimento: registar entrada, saída ou ajuste de forma atómica
-- ---------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE sp_registar_movimento (
  IN p_artigo_id     INT UNSIGNED,
  IN p_tipo          VARCHAR(10),
  IN p_quantidade    INT,
  IN p_destino       VARCHAR(120),
  IN p_utilizador_id INT UNSIGNED
)
BEGIN
  DECLARE v_stock  INT;
  DECLARE v_minimo INT;
  DECLARE v_ativo  TINYINT;
  DECLARE v_novo   INT;
  DECLARE v_dif    INT;
  DECLARE v_mov_id INT UNSIGNED;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  IF p_tipo NOT IN ('entrada','saida','ajuste') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de movimento inválido';
  END IF;
  IF p_quantidade IS NULL OR p_quantidade < 0 OR (p_quantidade = 0 AND p_tipo <> 'ajuste') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantidade inválida';
  END IF;
  IF p_tipo = 'saida' AND (p_destino IS NULL OR TRIM(p_destino) = '') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A saída precisa de um destino';
  END IF;

  START TRANSACTION;

  -- bloqueia a linha do artigo até ao fim da transação
  SELECT stock_atual, stock_minimo, ativo INTO v_stock, v_minimo, v_ativo
  FROM artigo WHERE id = p_artigo_id FOR UPDATE;

  IF v_stock IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Artigo inexistente';
  END IF;
  IF v_ativo = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Artigo desativado';
  END IF;

  IF p_tipo = 'entrada' THEN
    SET v_novo = v_stock + p_quantidade;
    SET v_dif = p_quantidade;
  ELSEIF p_tipo = 'saida' THEN
    IF p_quantidade > v_stock THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para esta saída';
    END IF;
    SET v_novo = v_stock - p_quantidade;
    SET v_dif = p_quantidade;
  ELSE
    -- ajuste: a quantidade é o stock contado no armazém
    SET v_novo = p_quantidade;
    SET v_dif = ABS(p_quantidade - v_stock);
  END IF;

  UPDATE artigo SET stock_atual = v_novo WHERE id = p_artigo_id;

  INSERT INTO movimento (tipo, quantidade, stock_depois, destino_origem, data_hora, artigo_id, utilizador_id)
  VALUES (p_tipo, v_dif, v_novo, IFNULL(TRIM(p_destino), ''), NOW(), p_artigo_id, p_utilizador_id);
  SET v_mov_id = LAST_INSERT_ID();

  IF v_novo <= v_minimo THEN
    IF NOT EXISTS (SELECT 1 FROM alerta WHERE artigo_id = p_artigo_id AND resolvido = 0) THEN
      INSERT INTO alerta (data_hora, resolvido, artigo_id, movimento_id)
      VALUES (NOW(), 0, p_artigo_id, v_mov_id);
    END IF;
  ELSE
    UPDATE alerta SET resolvido = 1 WHERE artigo_id = p_artigo_id AND resolvido = 0;
  END IF;

  COMMIT;

  SELECT v_mov_id AS movimento_id, v_novo AS stock_depois, v_minimo AS stock_minimo;
END$$

DELIMITER ;
