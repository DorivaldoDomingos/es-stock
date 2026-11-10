import '../models/artigo.dart';
import '../models/movimento.dart';
import '../services/api_service.dart';

// Movimentos: histórico com filtros, resumo do dia e registo de entradas e saídas.
class MovimentoController {
  static List<String> utilizadores = [];
  static List<Movimento> movimentos = [];
  static FiltroMovimentos filtro = const FiltroMovimentos();

  static int _hoje = 0;
  static int _saidas7 = 0;

  // utilizadores (para o filtro), resumo e histórico com o filtro atual
  static Future<void> carregarBase() async {
    final lista = await ApiService.get('/utilizadores') as List<dynamic>;
    utilizadores = lista.map((u) => u['nome'] as String).toList();

    final resumo =
        await ApiService.get('/movimentos/resumo') as Map<String, dynamic>;
    _hoje = resumo['movimentosHoje'] as int;
    _saidas7 = resumo['saidasUltimos7Dias'] as int;

    await carregar(filtro);
  }

  // pede ao servidor o histórico já filtrado
  static Future<void> carregar(FiltroMovimentos novo) async {
    filtro = novo;
    final query = <String, String>{
      if (novo.tipo != null) 'tipo': novo.tipo!.api,
      if (novo.maxDias < 100000) 'dias': '${novo.maxDias}',
      if (novo.utilizador != 'Todos') 'utilizador': novo.utilizador,
      if (novo.artigo.isNotEmpty) 'artigo': novo.artigo,
    };
    final lista = await ApiService.get('/movimentos', query: query) as List<dynamic>;
    movimentos = lista
        .map((e) => Movimento.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // últimos movimentos de um artigo (ficha do artigo)
  static Future<List<Movimento>> doArtigo(String codigo) async {
    final lista = await ApiService.get('/movimentos',
        query: {'codigo': codigo, 'limite': '4'}) as List<dynamic>;
    return lista
        .take(4)
        .map((e) => Movimento.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static int movimentosHoje() => _hoje;

  static int saidasUltimos7Dias() => _saidas7;

  // regista a entrada ou a saída no servidor; as regras (stock e destino) são validadas lá
  static Future<ResultadoMovimento> registar({
    required Artigo artigo,
    required TipoMovimento tipo,
    required int quantidade,
    required String destinoOrigem,
  }) async {
    final dados = await ApiService.post('/movimentos', {
      'codigo': artigo.codigo,
      'tipo': tipo.api,
      'quantidade': quantidade,
      'destinoOrigem': destinoOrigem,
    }) as Map<String, dynamic>;

    return ResultadoMovimento(
      artigo: artigo,
      tipo: tipo,
      quantidade: quantidade,
      destinoOrigem: destinoOrigem,
      stockDepois: dados['stockDepois'] as int,
    );
  }

  static String dataDe(int diasAtras) {
    final d = DateTime.now().subtract(Duration(days: diasAtras));
    final dia = d.day.toString().padLeft(2, '0');
    final mes = d.month.toString().padLeft(2, '0');
    return '$dia/$mes/${d.year}';
  }

  static String tituloDoDia(int diasAtras) {
    if (diasAtras == 0) return 'HOJE';
    if (diasAtras == 1) return 'ONTEM';
    return dataDe(diasAtras);
  }
}
