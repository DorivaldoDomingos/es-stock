const EstatisticaModel = require('../models/estatisticaModel');

const EstatisticaController = {
  async listar(req, res) {
    res.json(await EstatisticaModel.porArtigo());
  },
};

module.exports = EstatisticaController;
