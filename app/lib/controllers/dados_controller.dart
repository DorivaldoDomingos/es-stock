import 'package:flutter/foundation.dart';
import 'artigo_controller.dart';
import 'movimento_controller.dart';

// Carrega os dados da API para a memória e avisa os ecrãs quando mudam.
class DadosController {
  // sobe um número sempre que os dados são recarregados; os ecrãs ouvem este valor
  static final ValueNotifier<int> versao = ValueNotifier<int>(0);

  static Future<void> carregarTudo() async {
    await Future.wait([
      ArtigoController.carregar(),
      MovimentoController.carregarBase(),
    ]);
    versao.value++;
  }
}
