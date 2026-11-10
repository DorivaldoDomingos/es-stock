const db = require('../config/db');

const UtilizadorModel = {
  async porEmail(email) {
    const [linhas] = await db.query(
      'SELECT id, nome, email, password_hash, perfil, ativo FROM utilizador WHERE email = ?',
      [email]
    );
    return linhas[0] || null;
  },

  // cria uma conta nova; as contas criadas na app são sempre de operador
  async criar({ nome, email, passwordHash }) {
    const [res] = await db.query(
      "INSERT INTO utilizador (nome, email, password_hash, perfil) VALUES (?, ?, ?, 'operador')",
      [nome, email, passwordHash]
    );
    return res.insertId;
  },

  async listar() {
    const [linhas] = await db.query(
      'SELECT id, nome, perfil FROM utilizador WHERE ativo = 1 ORDER BY nome'
    );
    return linhas;
  },
};

module.exports = UtilizadorModel;
