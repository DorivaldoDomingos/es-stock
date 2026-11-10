const bcrypt = require('bcryptjs');
const UtilizadorModel = require('../models/utilizadorModel');
const { criarToken } = require('../middleware/auth');
const { ErroHttp } = require('../utils/erros');

const AuthController = {
  async login(req, res) {
    const { email, password } = req.body || {};
    if (!email || !password) throw new ErroHttp(400, 'Indique o email e a palavra-passe');

    const utilizador = await UtilizadorModel.porEmail(String(email).trim().toLowerCase());
    // a mesma mensagem para email errado e palavra-passe errada
    if (!utilizador || !utilizador.ativo) throw new ErroHttp(401, 'Credenciais inválidas');
    const certa = await bcrypt.compare(String(password), utilizador.password_hash);
    if (!certa) throw new ErroHttp(401, 'Credenciais inválidas');

    res.json({
      token: criarToken(utilizador),
      utilizador: { id: utilizador.id, nome: utilizador.nome, perfil: utilizador.perfil },
    });
  },

  // criar conta: fica sempre como operador (o gestor é criado pelo grupo na base de dados)
  async registar(req, res) {
    const { nome, email, password } = req.body || {};
    const nomeLimpo = String(nome || '').trim();
    const emailLimpo = String(email || '').trim().toLowerCase();

    if (nomeLimpo.length < 2) throw new ErroHttp(400, 'Indique o nome completo');
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailLimpo)) throw new ErroHttp(400, 'Email inválido');
    if (String(password || '').length < 8) {
      throw new ErroHttp(400, 'A palavra-passe precisa de pelo menos 8 caracteres');
    }
    if (await UtilizadorModel.porEmail(emailLimpo)) {
      throw new ErroHttp(409, 'Já existe uma conta com esse email');
    }

    const passwordHash = await bcrypt.hash(String(password), 10);
    const id = await UtilizadorModel.criar({ nome: nomeLimpo, email: emailLimpo, passwordHash });
    const utilizador = { id, nome: nomeLimpo, perfil: 'operador' };
    res.status(201).json({ token: criarToken(utilizador), utilizador });
  },

  async utilizadores(req, res) {
    res.json(await UtilizadorModel.listar());
  },
};

module.exports = AuthController;
