// Último middleware: transforma qualquer erro numa resposta JSON.
function naoEncontrado(req, res) {
  res.status(404).json({ erro: 'Rota não encontrada' });
}

function tratarErros(err, req, res, next) { // eslint-disable-line no-unused-vars
  // erros lançados pelo procedimento sp_registar_movimento (SIGNAL 45000)
  if (err.sqlState === '45000') {
    return res.status(400).json({ erro: err.sqlMessage });
  }
  if (err.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({ erro: 'Já existe um registo com esses dados' });
  }
  const status = err.status || 500;
  if (status === 500) console.error(err);
  res.status(status).json({ erro: status === 500 ? 'Erro interno do servidor' : err.message });
}

module.exports = { naoEncontrado, tratarErros };
