// Testes da API. Precisam do servidor a correr (npm start) e da base de dados populada.
// Executar:  npm test      (variável API_URL para outro endereço)
const test = require('node:test');
const assert = require('node:assert/strict');

const BASE = process.env.API_URL || 'http://localhost:3000';
const SENHA = 'EsStock2026!';

async function pedir(metodo, caminho, { token, corpo } = {}) {
  const resposta = await fetch(BASE + caminho, {
    method: metodo,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: corpo ? JSON.stringify(corpo) : undefined,
  });
  const texto = await resposta.text();
  return { status: resposta.status, dados: texto ? JSON.parse(texto) : null };
}

async function entrar(email) {
  const r = await pedir('POST', '/auth/login', { corpo: { email, password: SENHA } });
  assert.equal(r.status, 200);
  return r.dados.token;
}

test('login com credenciais erradas devolve 401', async () => {
  const r = await pedir('POST', '/auth/login', {
    corpo: { email: 'dorivaldo.domingos@electrosmart.example', password: 'errada' },
  });
  assert.equal(r.status, 401);
});

test('pedido sem token devolve 401', async () => {
  assert.equal((await pedir('GET', '/artigos')).status, 401);
});

test('gestor e operador entram com o perfil certo', async () => {
  const g = await pedir('POST', '/auth/login', {
    corpo: { email: 'dorivaldo.domingos@electrosmart.example', password: SENHA },
  });
  const o = await pedir('POST', '/auth/login', {
    corpo: { email: 'alcides.sequeira@electrosmart.example', password: SENHA },
  });
  assert.equal(g.dados.utilizador.perfil, 'gestor');
  assert.equal(o.dados.utilizador.perfil, 'operador');
});

test('lista de artigos e pesquisa', async () => {
  const token = await entrar('alcides.sequeira@electrosmart.example');
  const todos = await pedir('GET', '/artigos', { token });
  assert.equal(todos.status, 200);
  assert.ok(todos.dados.length >= 23);
  const redes = await pedir('GET', '/artigos?categoria=Redes&q=switch', { token });
  assert.equal(redes.dados.length, 1);
  assert.equal(redes.dados[0].codigo, 'ES-RED-0009');
});

test('o código lido no QR devolve a ficha do artigo', async () => {
  const token = await entrar('alcides.sequeira@electrosmart.example');
  const r = await pedir('GET', '/artigos/codigo/ES-CAB-0107', { token });
  assert.equal(r.status, 200);
  assert.equal(r.dados.nome, 'Cabo HDMI 2 m');
  assert.equal((await pedir('GET', '/artigos/codigo/XX-0000', { token })).status, 404);
});

test('alertas incluem os artigos sem stock', async () => {
  const token = await entrar('alcides.sequeira@electrosmart.example');
  const r = await pedir('GET', '/alertas', { token });
  assert.ok(r.dados.length >= 4);
  assert.ok(r.dados.some((a) => a.codigo === 'ES-CAB-0107' && a.estado === 'sem_stock'));
});

test('operador não pode criar artigos, gestor pode e o código é gerado', async () => {
  const op = await entrar('alcides.sequeira@electrosmart.example');
  const gestor = await entrar('dorivaldo.domingos@electrosmart.example');
  const corpo = { nome: 'Artigo de teste', categoriaId: 2, localizacaoId: 4, stockMinimo: 2 };
  assert.equal((await pedir('POST', '/artigos', { token: op, corpo })).status, 403);
  const criado = await pedir('POST', '/artigos', { token: gestor, corpo });
  assert.equal(criado.status, 201);
  assert.match(criado.dados.codigo, /^ES-AUT-\d{4}$/);
  assert.equal(criado.dados.stock, 0);
  // limpeza
  assert.equal((await pedir('DELETE', `/artigos/${criado.dados.id}`, { token: gestor })).status, 204);
});

test('saída: valida destino e stock, atualiza o stock e cria alerta', async () => {
  const token = await entrar('alcides.sequeira@electrosmart.example');
  const codigo = 'ES-SEN-0023'; // stock 4, mínimo 2

  const semDestino = await pedir('POST', '/movimentos', { token, corpo: { codigo, tipo: 'saida', quantidade: 1 } });
  assert.equal(semDestino.status, 400);

  const demais = await pedir('POST', '/movimentos', {
    token, corpo: { codigo, tipo: 'saida', quantidade: 999, destinoOrigem: 'Teste' },
  });
  assert.equal(demais.status, 400);
  assert.match(demais.dados.erro, /insuficiente/i);

  const antes = (await pedir('GET', `/artigos/codigo/${codigo}`, { token })).dados.stock;
  const ok = await pedir('POST', '/movimentos', {
    token, corpo: { codigo, tipo: 'saida', quantidade: 3, destinoOrigem: 'Hotel Sol Algarve' },
  });
  assert.equal(ok.status, 201);
  assert.equal(ok.dados.stockAntes, antes);
  assert.equal(ok.dados.stockDepois, antes - 3);
  assert.equal(ok.dados.emAlerta, true);

  const alertas = (await pedir('GET', '/alertas', { token })).dados;
  assert.ok(alertas.some((a) => a.codigo === codigo));

  // a entrada seguinte repõe o stock e o artigo sai dos alertas
  const entrada = await pedir('POST', '/movimentos', {
    token, corpo: { codigo, tipo: 'entrada', quantidade: 3, destinoOrigem: 'Fornecedor SecureTech' },
  });
  assert.equal(entrada.dados.stockDepois, antes);
  assert.equal(entrada.dados.emAlerta, false);
});

test('histórico filtra por tipo e período', async () => {
  const token = await entrar('alcides.sequeira@electrosmart.example');
  const r = await pedir('GET', '/movimentos?tipo=entrada&dias=30', { token });
  assert.equal(r.status, 200);
  assert.ok(r.dados.length > 0);
  assert.ok(r.dados.every((m) => m.tipo === 'entrada'));
  assert.equal((await pedir('GET', '/movimentos?tipo=roubo', { token })).status, 400);
});

test('estatísticas só para o gestor, com sugestão de Monte Carlo', async () => {
  const op = await entrar('alcides.sequeira@electrosmart.example');
  const gestor = await entrar('dorivaldo.domingos@electrosmart.example');
  assert.equal((await pedir('GET', '/estatisticas', { token: op })).status, 403);
  const r = await pedir('GET', '/estatisticas', { token: gestor });
  assert.equal(r.status, 200);
  assert.ok(r.dados.length > 0);
  const hdmi = r.dados.find((e) => e.codigo === 'ES-CAB-0107');
  assert.ok(hdmi.sugerido >= hdmi.mediaSemanal);
  // mesma sugestão em dois pedidos seguidos (a semente é fixa)
  const r2 = await pedir('GET', '/estatisticas', { token: gestor });
  assert.equal(r2.dados.find((e) => e.codigo === 'ES-CAB-0107').sugerido, hdmi.sugerido);
});

test('criar conta: valida os dados, cria operador e permite entrar', async () => {
  const email = `teste${Date.now()}@electrosmart.example`;
  const mau = await pedir('POST', '/auth/registar', { corpo: { nome: 'Teste', email, password: '123' } });
  assert.equal(mau.status, 400);
  const semEmail = await pedir('POST', '/auth/registar', { corpo: { nome: 'Teste', email: 'sem-arroba', password: 'palavra123' } });
  assert.equal(semEmail.status, 400);

  const criada = await pedir('POST', '/auth/registar', {
    corpo: { nome: 'Conta de Teste', email, password: 'palavra123' },
  });
  assert.equal(criada.status, 201);
  assert.equal(criada.dados.utilizador.perfil, 'operador');
  assert.ok(criada.dados.token);

  const repetida = await pedir('POST', '/auth/registar', {
    corpo: { nome: 'Conta de Teste', email, password: 'palavra123' },
  });
  assert.equal(repetida.status, 409);

  const entrar = await pedir('POST', '/auth/login', { corpo: { email, password: 'palavra123' } });
  assert.equal(entrar.status, 200);
  // uma conta nova não é gestor
  const est = await pedir('GET', '/estatisticas', { token: entrar.dados.token });
  assert.equal(est.status, 403);
});
