-- ES Stock · queries.sql
-- Pesquisas mais relevantes para a aplicação. Cada uma pode ser executada à parte.
SET NAMES utf8mb4;
USE es_stock;

-- 1. Artigos em alerta (sem stock ou no mínimo), do mais crítico para o menos crítico
SELECT codigo_qr, nome, categoria, localizacao, stock_atual, stock_minimo,
       stock_minimo - stock_atual AS em_falta
FROM v_artigo
WHERE ativo = 1 AND stock_atual <= stock_minimo
ORDER BY em_falta DESC, nome;

-- 2. Ficha de um artigo a partir do código lido no QR Code
SELECT * FROM v_artigo WHERE codigo_qr = 'ES-CAB-0107';

-- 3. Pesquisa de artigos por texto e categoria (ecrã Artigos)
SELECT codigo_qr, nome, categoria, stock_atual
FROM v_artigo
WHERE ativo = 1 AND categoria = 'Redes'
  AND (nome LIKE '%switch%' OR codigo_qr LIKE '%switch%');

-- 4. Número de artigos e stock total por categoria
SELECT c.nome AS categoria, COUNT(a.id) AS artigos, SUM(a.stock_atual) AS unidades_em_stock
FROM categoria c
LEFT JOIN artigo a ON a.categoria_id = c.id AND a.ativo = 1
GROUP BY c.id, c.nome
ORDER BY unidades_em_stock DESC;

-- 5. Histórico dos últimos 7 dias, mais recente primeiro (ecrã Histórico)
SELECT data_hora, tipo, quantidade, artigo, utilizador, destino_origem
FROM v_movimento
WHERE data_hora >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY data_hora DESC;

-- 6. Quem levantou mais material nos últimos 30 dias
SELECT u.nome, COUNT(*) AS saidas, SUM(m.quantidade) AS unidades
FROM movimento m
JOIN utilizador u ON u.id = m.utilizador_id
WHERE m.tipo = 'saida' AND m.data_hora >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY u.id, u.nome
ORDER BY unidades DESC;

-- 7. Para onde foi o material: unidades enviadas por destino
SELECT destino_origem AS destino, COUNT(*) AS saidas, SUM(quantidade) AS unidades
FROM movimento
WHERE tipo = 'saida'
GROUP BY destino_origem
ORDER BY unidades DESC;

-- 8. Consumo semanal por artigo (base do cálculo do stock mínimo)
SELECT a.codigo_qr, a.nome, cs.semana, cs.total_saidas
FROM v_consumo_semanal cs
JOIN artigo a ON a.id = cs.artigo_id
WHERE a.codigo_qr = 'ES-CAB-0107'
ORDER BY cs.semana;

-- 9. Média e desvio padrão do consumo semanal por artigo (estatísticas descritivas)
SELECT a.codigo_qr, a.nome,
       COUNT(*) AS semanas_com_saidas,
       ROUND(AVG(cs.total_saidas), 2) AS media_semanal,
       ROUND(STDDEV_POP(cs.total_saidas), 2) AS desvio_padrao,
       a.stock_minimo
FROM v_consumo_semanal cs
JOIN artigo a ON a.id = cs.artigo_id
GROUP BY a.id, a.codigo_qr, a.nome, a.stock_minimo
HAVING semanas_com_saidas >= 4
ORDER BY media_semanal DESC;

-- 10. Artigos cujo stock mínimo está abaixo do consumo médio semanal (mínimo possivelmente curto)
SELECT a.codigo_qr, a.nome, a.stock_minimo, ROUND(m.media, 2) AS media_semanal
FROM artigo a
JOIN (SELECT artigo_id, AVG(total_saidas) AS media
      FROM v_consumo_semanal GROUP BY artigo_id) m ON m.artigo_id = a.id
WHERE a.stock_minimo < m.media
ORDER BY m.media - a.stock_minimo DESC;

-- 11. Artigos sem qualquer movimento nos últimos 30 dias (stock parado)
SELECT a.codigo_qr, a.nome, a.stock_atual
FROM artigo a
WHERE a.ativo = 1
  AND NOT EXISTS (SELECT 1 FROM movimento m
                  WHERE m.artigo_id = a.id
                    AND m.data_hora >= DATE_SUB(NOW(), INTERVAL 30 DAY))
ORDER BY a.stock_atual DESC;

-- 12. Alertas abertos com o movimento que os provocou e quem o fez
SELECT al.data_hora AS alerta_em, a.codigo_qr, a.nome, a.stock_atual, a.stock_minimo,
       u.nome AS ultimo_responsavel
FROM alerta al
JOIN artigo a ON a.id = al.artigo_id
LEFT JOIN movimento m ON m.id = al.movimento_id
LEFT JOIN utilizador u ON u.id = m.utilizador_id
WHERE al.resolvido = 0
ORDER BY al.data_hora DESC;

-- 13. Registar uma saída através do procedimento (atualiza o stock, grava o movimento e cria o alerta)
-- CALL sp_registar_movimento(
--   (SELECT id FROM artigo WHERE codigo_qr = 'ES-SEN-0023'), 'saida', 3, 'Hotel Sol Algarve',
--   (SELECT id FROM utilizador WHERE email = 'alcides.sequeira@electrosmart.example'));

-- 14. Evolução do stock de um artigo depois de cada movimento (funções de janela)
SELECT data_hora, tipo, quantidade, stock_depois,
       SUM(CASE WHEN tipo = 'saida' THEN quantidade ELSE 0 END)
         OVER (ORDER BY data_hora) AS saidas_acumuladas
FROM movimento
WHERE artigo_id = (SELECT id FROM artigo WHERE codigo_qr = 'ES-CAB-0107')
ORDER BY data_hora;
