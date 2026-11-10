const db = require('../config/db');

// categorias e localizações (listas usadas nos formulários)
const CatalogoModel = {
  async categorias() {
    const [linhas] = await db.query('SELECT id, nome, prefixo FROM categoria ORDER BY nome');
    return linhas;
  },

  async localizacoes() {
    const [linhas] = await db.query(
      "SELECT id, zona, prateleira, CONCAT(zona, ' · ', prateleira) AS nome FROM localizacao ORDER BY zona, prateleira"
    );
    return linhas;
  },
};

module.exports = CatalogoModel;
