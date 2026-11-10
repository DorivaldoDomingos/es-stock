const db = require('../config/db');

// Gerador pseudo-aleatório com semente: o mesmo artigo dá sempre a mesma sugestão.
function gerador(semente) {
  let s = semente >>> 0 || 1;
  return () => {
    s = (Math.imul(s, 1664525) + 1013904223) >>> 0;
    return s / 4294967296;
  };
}

// Número aleatório com distribuição normal (método de Box-Muller).
function normal(rnd, media, desvio) {
  const u1 = Math.max(rnd(), 1e-12);
  const u2 = rnd();
  return media + desvio * Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);
}

// Simulação de Monte Carlo: simula muitas semanas de consumo e devolve o valor
// que cobre 95% dos casos. Esse valor é a sugestão de stock mínimo.
function monteCarlo(media, desvio, semente, iteracoes = 5000, nivel = 0.95) {
  const rnd = gerador(semente);
  const amostras = [];
  for (let i = 0; i < iteracoes; i++) {
    amostras.push(Math.max(0, Math.round(normal(rnd, media, desvio))));
  }
  amostras.sort((a, b) => a - b);
  return amostras[Math.min(amostras.length - 1, Math.floor(nivel * amostras.length))];
}

const EstatisticaModel = {
  monteCarlo,

  async porArtigo(minimoSemanas = 4) {
    const [linhas] = await db.query(
      `SELECT a.id, a.codigo_qr, a.nome, a.stock_minimo,
              COUNT(*) AS semanas,
              AVG(cs.total_saidas) AS media,
              STDDEV_POP(cs.total_saidas) AS desvio
       FROM v_consumo_semanal cs
       JOIN artigo a ON a.id = cs.artigo_id
       WHERE a.ativo = 1
       GROUP BY a.id, a.codigo_qr, a.nome, a.stock_minimo
       HAVING semanas >= ?
       ORDER BY media DESC`,
      [minimoSemanas]
    );
    return linhas.map((l) => {
      const media = Number(l.media);
      const desvio = Number(l.desvio);
      return {
        codigo: l.codigo_qr,
        nome: l.nome,
        minimoAtual: l.stock_minimo,
        mediaSemanal: Math.round(media * 10) / 10,
        desvioPadrao: Math.round(desvio * 100) / 100,
        semanas: Number(l.semanas),
        sugerido: monteCarlo(media, desvio, l.id * 7919),
      };
    });
  },
};

module.exports = EstatisticaModel;
