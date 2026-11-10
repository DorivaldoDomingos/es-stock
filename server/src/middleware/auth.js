// Verifica o token JWT e o perfil do utilizador.
require('dotenv').config();
const jwt = require('jsonwebtoken');
const { ErroHttp } = require('../utils/erros');

const segredo = () => process.env.JWT_SECRET || 'segredo-de-desenvolvimento';

function autenticar(req, res, next) {
  const cabecalho = req.headers.authorization || '';
  const token = cabecalho.startsWith('Bearer ') ? cabecalho.slice(7) : null;
  if (!token) return next(new ErroHttp(401, 'Token em falta'));
  try {
    req.utilizador = jwt.verify(token, segredo());
    next();
  } catch (e) {
    next(new ErroHttp(401, 'Token inválido ou expirado'));
  }
}

function apenasGestor(req, res, next) {
  if (req.utilizador && req.utilizador.perfil === 'gestor') return next();
  next(new ErroHttp(403, 'Só o gestor pode fazer esta operação'));
}

function criarToken(utilizador) {
  return jwt.sign(
    { id: utilizador.id, nome: utilizador.nome, perfil: utilizador.perfil },
    segredo(),
    { expiresIn: process.env.JWT_EXPIRA || '8h' }
  );
}

module.exports = { autenticar, apenasGestor, criarToken };
