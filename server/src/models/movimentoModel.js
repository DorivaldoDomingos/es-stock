const db = require('../config/db');

function paraJson(l) {
  return {
    id: l.id,
    codigo: l.codigo_qr,
    artigo: l.artigo,
    tipo: l.tipo,
    quantidade: l.quantidade,
    stockDepois: l.stock_depois,
    utilizador: l.utilizador,
    dataHora: l.data_hora, // "AAAA-MM-DD HH:MM:SS"
    destinoOrigem: l.destino_origem,
  };
}

const MovimentoModel = {
  async listar({ tipo, dias, utilizador, artigo, codigo, limite } = {}) {
    const filtros = ['1 = 1'];
    const valores = [];
    if (tipo) {
      filtros.push('tipo = ?');
      valores.push(tipo);
    }
    if (dias) {
      filtros.push('data_hora >= DATE_SUB(CURDATE(), INTERVAL ? DAY)');
      valores.push(Number(dias) - 1); // "1 dia" = só hoje
    }
    if (utilizador) {
      filtros.push('utilizador = ?');
      valores.push(utilizador);
    }
    if (artigo) {
      filtros.push('(artigo LIKE ? OR codigo_qr LIKE ?)');
      valores.push(`%${artigo}%`, `%${artigo}%`);
    }
    if (codigo) {
      filtros.push('codigo_qr = ?');
      valores.push(codigo);
    }
    valores.push(Math.min(Number(limite || 200), 500));
    const [linhas] = await db.query(
      `SELECT * FROM v_movimento WHERE ${filtros.join(' AND ')}
       ORDER BY data_hora DESC, id DESC LIMIT ?`,
      valores
    );
    return linhas.map(paraJson);
  },

  // chama o procedimento que faz tudo numa transação
  async registar({ artigoId, tipo, quantidade, destino, utilizadorId }) {
    const [resultado] = await db.query('CALL sp_registar_movimento(?, ?, ?, ?, ?)', [
      artigoId, tipo, quantidade, destino || '', utilizadorId,
    ]);
    const linha = resultado[0][0];
    return {
      movimentoId: linha.movimento_id,
      stockDepois: linha.stock_depois,
      stockMinimo: linha.stock_minimo,
    };
  },

  async resumo() {
    const [linhas] = await db.query(
      `SELECT
         (SELECT COUNT(*) FROM movimento WHERE DATE(data_hora) = CURDATE()) AS hoje,
         (SELECT COALESCE(SUM(quantidade), 0) FROM movimento
           WHERE tipo = 'saida' AND data_hora >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)) AS saidas7`
    );
    return { movimentosHoje: Number(linhas[0].hoje), saidasUltimos7Dias: Number(linhas[0].saidas7) };
  },
};

module.exports = MovimentoModel;
