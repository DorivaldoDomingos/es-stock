const MovimentoModel = require('../models/movimentoModel');
const ArtigoModel = require('../models/artigoModel');
const { ErroHttp } = require('../utils/erros');

const TIPOS = ['entrada', 'saida', 'ajuste'];

const MovimentoController = {
  async listar(req, res) {
    const { tipo, dias, utilizador, artigo, codigo, limite } = req.query;
    if (tipo && !TIPOS.includes(tipo)) throw new ErroHttp(400, 'Tipo de movimento inválido');
    if (dias !== undefined && (!Number.isInteger(Number(dias)) || Number(dias) < 1)) {
      throw new ErroHttp(400, 'O número de dias é inválido');
    }
    if (limite !== undefined && (!Number.isInteger(Number(limite)) || Number(limite) < 1)) {
      throw new ErroHttp(400, 'O limite é inválido');
    }
    res.json(await MovimentoModel.listar({
      tipo, dias, utilizador, artigo, codigo, limite: limite ? Number(limite) : undefined,
    }));
  },

  async resumo(req, res) {
    res.json(await MovimentoModel.resumo());
  },

  async registar(req, res) {
    const { codigo, tipo, quantidade, destinoOrigem } = req.body || {};
    if (!codigo) throw new ErroHttp(400, 'Indique o código do artigo');
    if (!TIPOS.includes(tipo)) throw new ErroHttp(400, 'Tipo de movimento inválido');
    const qtd = Number(quantidade);
    if (!Number.isInteger(qtd) || qtd < 0) throw new ErroHttp(400, 'Quantidade inválida');

    const artigo = await ArtigoModel.porCodigo(codigo);
    if (!artigo || !artigo.ativo) throw new ErroHttp(404, 'Artigo não encontrado');

    // as regras (stock insuficiente, destino obrigatório) são aplicadas no procedimento SQL
    const resultado = await MovimentoModel.registar({
      artigoId: artigo.id,
      tipo,
      quantidade: qtd,
      destino: destinoOrigem,
      utilizadorId: req.utilizador.id,
    });
    res.status(201).json({
      movimentoId: resultado.movimentoId,
      stockAntes: artigo.stock,
      stockDepois: resultado.stockDepois,
      stockMinimo: resultado.stockMinimo,
      emAlerta: resultado.stockDepois <= resultado.stockMinimo,
    });
  },
};

module.exports = MovimentoController;
