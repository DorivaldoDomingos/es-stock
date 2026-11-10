import '../models/estatistica.dart';
import '../services/api_service.dart';
import 'artigo_controller.dart';

// Estatísticas de consumo e sugestão de stock mínimo (simulação de Monte Carlo no servidor).
class EstatisticaController {
  static List<Estatistica> lista = [];

  static Future<void> carregar() async {
    final dados = await ApiService.get('/estatisticas') as List<dynamic>;
    lista = dados
        .map((e) => Estatistica.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // grava a sugestão como novo stock mínimo do artigo
  static Future<void> aplicarSugestao(Estatistica e) async {
    final artigo = await ArtigoController.procurarPorCodigo(e.codigo);
    await ArtigoController.alterarStockMinimo(artigo, e.sugerido);
  }
}
