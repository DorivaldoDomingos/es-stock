// Erro com código HTTP, para os controllers e o middleware responderem de forma uniforme.
class ErroHttp extends Error {
  constructor(status, mensagem) {
    super(mensagem);
    this.status = status;
  }
}

// Aceita um controller async e passa os erros ao middleware de erros.
const assincrono = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

module.exports = { ErroHttp, assincrono };
