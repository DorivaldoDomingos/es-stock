const db = require('../config/db');

// transforma a linha da vista v_artigo no formato que a app espera
function paraJson(l) {
  return {
    id: l.id,
    codigo: l.codigo_qr,
    nome: l.nome,
    categoria: l.categoria,
    localizacao: l.localizacao,
    fornecedor: l.fornecedor,
    unidade: l.unidade,
    stock: l.stock_atual,
    stockMinimo: l.stock_minimo,
    estado: l.estado,
    ativo: l.ativo === 1,
  };
}

const ArtigoModel = {
  paraJson,

  async listar({ q = '', categoria = '' } = {}) {
    const filtros = ['ativo = 1'];
    const valores = [];
    if (q) {
      filtros.push('(nome LIKE ? OR codigo_qr LIKE ?)');
      valores.push(`%${q}%`, `%${q}%`);
    }
    if (categoria && categoria !== 'Todos') {
      filtros.push('categoria = ?');
      valores.push(categoria);
    }
    const [linhas] = await db.query(
      `SELECT * FROM v_artigo WHERE ${filtros.join(' AND ')} ORDER BY nome`,
      valores
    );
    return linhas.map(paraJson);
  },

  async porId(id) {
    const [linhas] = await db.query('SELECT * FROM v_artigo WHERE id = ?', [id]);
    return linhas[0] ? paraJson(linhas[0]) : null;
  },

  async porCodigo(codigo) {
    const [linhas] = await db.query('SELECT * FROM v_artigo WHERE codigo_qr = ?', [codigo]);
    return linhas[0] ? paraJson(linhas[0]) : null;
  },

  async alertas() {
    const [linhas] = await db.query(
      `SELECT * FROM v_artigo
       WHERE ativo = 1 AND stock_atual <= stock_minimo
       ORDER BY (stock_minimo - stock_atual) DESC, nome`
    );
    return linhas.map(paraJson);
  },

  // gera o próximo código livre de uma categoria, por exemplo ES-AUT-0011
  async proximoCodigo(categoriaId, ligacao = db) {
    const [cat] = await ligacao.query('SELECT prefixo FROM categoria WHERE id = ?', [categoriaId]);
    if (!cat[0]) return null;
    const prefixo = cat[0].prefixo;
    const [linhas] = await ligacao.query(
      `SELECT MAX(CAST(SUBSTRING_INDEX(codigo_qr, '-', -1) AS UNSIGNED)) AS maior
       FROM artigo WHERE codigo_qr LIKE ?`,
      [`ES-${prefixo}-%`]
    );
    const proximo = (linhas[0].maior || 0) + 1;
    return `ES-${prefixo}-${String(proximo).padStart(4, '0')}`;
  },

  async criar({ nome, categoriaId, localizacaoId, fornecedor, unidade, stockMinimo }) {
    const ligacao = await db.getConnection();
    try {
      await ligacao.beginTransaction();
      // bloqueia a categoria para dois pedidos em simultâneo não gerarem o mesmo código
      await ligacao.query('SELECT id FROM categoria WHERE id = ? FOR UPDATE', [categoriaId]);
      const codigo = await this.proximoCodigo(categoriaId, ligacao);
      if (!codigo) {
        await ligacao.rollback();
        return null;
      }
      const [res] = await ligacao.query(
        `INSERT INTO artigo (codigo_qr, nome, fornecedor, unidade, stock_atual, stock_minimo, categoria_id, localizacao_id)
         VALUES (?, ?, ?, ?, 0, ?, ?, ?)`,
        [codigo, nome, fornecedor || '', unidade || 'un', stockMinimo, categoriaId, localizacaoId]
      );
      await ligacao.commit();
      return res.insertId;
    } catch (e) {
      await ligacao.rollback();
      throw e;
    } finally {
      ligacao.release();
    }
  },

  async atualizar(id, campos) {
    const mapa = {
      nome: 'nome',
      fornecedor: 'fornecedor',
      unidade: 'unidade',
      stockMinimo: 'stock_minimo',
      categoriaId: 'categoria_id',
      localizacaoId: 'localizacao_id',
    };
    const sets = [];
    const valores = [];
    for (const [chave, coluna] of Object.entries(mapa)) {
      if (campos[chave] !== undefined) {
        sets.push(`${coluna} = ?`);
        valores.push(campos[chave]);
      }
    }
    if (sets.length === 0) return 0;
    valores.push(id);
    const [res] = await db.query(`UPDATE artigo SET ${sets.join(', ')} WHERE id = ?`, valores);
    return res.affectedRows;
  },

  async desativar(id) {
    const [res] = await db.query('UPDATE artigo SET ativo = 0 WHERE id = ?', [id]);
    return res.affectedRows;
  },
};

module.exports = ArtigoModel;
