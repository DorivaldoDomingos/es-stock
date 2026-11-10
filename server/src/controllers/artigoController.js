const ArtigoModel = require('../models/artigoModel');
const CatalogoModel = require('../models/catalogoModel');
const { ErroHttp } = require('../utils/erros');

function validarId(valor) {
  const id = Number(valor);
  if (!Number.isInteger(id) || id <= 0) throw new ErroHttp(400, 'Identificador inválido');
  return id;
}

const ArtigoController = {
  async listar(req, res) {
    res.json(await ArtigoModel.listar({ q: req.query.q, categoria: req.query.categoria }));
  },

  async obter(req, res) {
    const artigo = await ArtigoModel.porId(validarId(req.params.id));
    if (!artigo) throw new ErroHttp(404, 'Artigo não encontrado');
    res.json(artigo);
  },

  // o QR Code contém o código do artigo, por exemplo ES-CAB-0107
  async obterPorCodigo(req, res) {
    const artigo = await ArtigoModel.porCodigo(req.params.codigo);
    if (!artigo || !artigo.ativo) throw new ErroHttp(404, 'Nenhum artigo com esse código');
    res.json(artigo);
  },

  async proximoCodigo(req, res) {
    const codigo = await ArtigoModel.proximoCodigo(validarId(req.query.categoriaId));
    if (!codigo) throw new ErroHttp(404, 'Categoria não encontrada');
    res.json({ codigo });
  },

  async criar(req, res) {
    const { nome, categoriaId, localizacaoId, fornecedor, unidade, stockMinimo } = req.body || {};
    if (!nome || !String(nome).trim()) throw new ErroHttp(400, 'O nome é obrigatório');
    if (!categoriaId || !localizacaoId) throw new ErroHttp(400, 'Escolha a categoria e a localização');
    const minimo = Number(stockMinimo ?? 0);
    if (!Number.isInteger(minimo) || minimo < 0) throw new ErroHttp(400, 'Stock mínimo inválido');

    const id = await ArtigoModel.criar({
      nome: String(nome).trim(), categoriaId, localizacaoId, fornecedor, unidade, stockMinimo: minimo,
    });
    if (!id) throw new ErroHttp(404, 'Categoria não encontrada');
    res.status(201).json(await ArtigoModel.porId(id));
  },

  async atualizar(req, res) {
    const id = validarId(req.params.id);
    const { stockMinimo } = req.body || {};
    if (stockMinimo !== undefined && (!Number.isInteger(Number(stockMinimo)) || Number(stockMinimo) < 0)) {
      throw new ErroHttp(400, 'Stock mínimo inválido');
    }
    if (!(await ArtigoModel.porId(id))) throw new ErroHttp(404, 'Artigo não encontrado');
    await ArtigoModel.atualizar(id, req.body || {});
    res.json(await ArtigoModel.porId(id));
  },

  async desativar(req, res) {
    const id = validarId(req.params.id);
    const alterados = await ArtigoModel.desativar(id);
    if (!alterados) throw new ErroHttp(404, 'Artigo não encontrado');
    res.status(204).end();
  },

  async categorias(req, res) {
    res.json(await CatalogoModel.categorias());
  },

  async localizacoes(req, res) {
    res.json(await CatalogoModel.localizacoes());
  },

  async alertas(req, res) {
    res.json(await ArtigoModel.alertas());
  },
};

module.exports = ArtigoController;
