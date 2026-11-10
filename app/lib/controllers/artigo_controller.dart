import '../models/artigo.dart';
import '../services/api_service.dart';

// Artigos: guarda a lista descarregada da API e trata das pesquisas e do registo de novos artigos.
class ArtigoController {
  static List<Artigo> artigos = [];
  static List<String> categorias = [];
  static List<String> localizacoes = [];

  // nome -> id, para enviar à API o que o utilizador escolheu
  static final Map<String, int> _categoriaIds = {};
  static final Map<String, int> _localizacaoIds = {};

  static Future<void> carregar() async {
    final listaArtigos = await ApiService.get('/artigos') as List<dynamic>;
    final listaCategorias = await ApiService.get('/categorias') as List<dynamic>;
    final listaLocalizacoes =
        await ApiService.get('/localizacoes') as List<dynamic>;

    artigos = listaArtigos
        .map((e) => Artigo.fromJson(e as Map<String, dynamic>))
        .toList();

    _categoriaIds.clear();
    for (final c in listaCategorias) {
      _categoriaIds[c['nome'] as String] = c['id'] as int;
    }
    categorias = _categoriaIds.keys.toList();

    _localizacaoIds.clear();
    for (final l in listaLocalizacoes) {
      _localizacaoIds[l['nome'] as String] = l['id'] as int;
    }
    localizacoes = _localizacaoIds.keys.toList();
  }

  // artigos sem stock ou abaixo do mínimo
  static List<Artigo> alertas() {
    return artigos.where((a) => a.emAlerta).toList();
  }

  static List<Artigo> pesquisar(String texto, String categoria) {
    final t = texto.toLowerCase();
    return artigos.where((a) {
      final categoriaOk = categoria == 'Todos' || a.categoria == categoria;
      final textoOk =
          a.nome.toLowerCase().contains(t) || a.codigo.toLowerCase().contains(t);
      return categoriaOk && textoOk;
    }).toList();
  }

  // o QR Code contém o código do artigo; a API devolve a ficha atualizada
  static Future<Artigo> procurarPorCodigo(String codigo) async {
    final dados = await ApiService.get(
        '/artigos/codigo/${Uri.encodeComponent(codigo.trim())}');
    return Artigo.fromJson(dados as Map<String, dynamic>);
  }

  // próximo código livre de uma categoria, por exemplo ES-AUT-0011
  static Future<String> proximoCodigo(String categoria) async {
    final dados = await ApiService.get('/artigos/proximo-codigo',
        query: {'categoriaId': '${_categoriaIds[categoria]}'});
    return (dados as Map<String, dynamic>)['codigo'] as String;
  }

  // cria o artigo (só o gestor pode) e, se houver stock inicial, regista a entrada
  static Future<Artigo> criar({
    required String nome,
    required String categoria,
    required String? localizacao,
    required String fornecedor,
    required String unidade,
    required int stockMinimo,
    required int stockInicial,
  }) async {
    final localizacaoId = _localizacaoIds[localizacao] ?? _localizacaoIds.values.first;
    final dados = await ApiService.post('/artigos', {
      'nome': nome,
      'categoriaId': _categoriaIds[categoria],
      'localizacaoId': localizacaoId,
      'fornecedor': fornecedor,
      'unidade': unidade,
      'stockMinimo': stockMinimo,
    }) as Map<String, dynamic>;
    var artigo = Artigo.fromJson(dados);

    if (stockInicial > 0) {
      await ApiService.post('/movimentos', {
        'codigo': artigo.codigo,
        'tipo': 'entrada',
        'quantidade': stockInicial,
        'destinoOrigem': 'Stock inicial',
      });
      artigo = await procurarPorCodigo(artigo.codigo);
    }
    return artigo;
  }

  static Future<void> alterarStockMinimo(Artigo artigo, int novoMinimo) async {
    await ApiService.put('/artigos/${artigo.id}', {'stockMinimo': novoMinimo});
  }
}
