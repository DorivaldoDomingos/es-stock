const express = require('express');
const cors = require('cors');
const rotas = require('./routes');
const { naoEncontrado, tratarErros } = require('./middleware/erros');

const app = express();
app.use(cors());
app.use(express.json());
app.use('/', rotas);
app.use(naoEncontrado);
app.use(tratarErros);

module.exports = app;
