const express = require('express');
const { assincrono } = require('../utils/erros');
const { autenticar, apenasGestor } = require('../middleware/auth');
const Auth = require('../controllers/authController');
const Artigo = require('../controllers/artigoController');
const Movimento = require('../controllers/movimentoController');
const Estatistica = require('../controllers/estatisticaController');

const router = express.Router();

// público
router.get('/saude', (req, res) => res.json({ estado: 'ok' }));
router.post('/auth/login', assincrono(Auth.login));
router.post('/auth/registar', assincrono(Auth.registar));

// a partir daqui é preciso token
router.use(autenticar);

router.get('/utilizadores', assincrono(Auth.utilizadores));
router.get('/categorias', assincrono(Artigo.categorias));
router.get('/localizacoes', assincrono(Artigo.localizacoes));

router.get('/artigos', assincrono(Artigo.listar));
router.get('/artigos/proximo-codigo', assincrono(Artigo.proximoCodigo));
router.get('/artigos/codigo/:codigo', assincrono(Artigo.obterPorCodigo));
router.get('/artigos/:id', assincrono(Artigo.obter));
router.post('/artigos', apenasGestor, assincrono(Artigo.criar));
router.put('/artigos/:id', apenasGestor, assincrono(Artigo.atualizar));
router.delete('/artigos/:id', apenasGestor, assincrono(Artigo.desativar));

router.get('/movimentos', assincrono(Movimento.listar));
router.get('/movimentos/resumo', assincrono(Movimento.resumo));
router.post('/movimentos', assincrono(Movimento.registar));

router.get('/alertas', assincrono(Artigo.alertas));
router.get('/estatisticas', apenasGestor, assincrono(Estatistica.listar));

module.exports = router;
