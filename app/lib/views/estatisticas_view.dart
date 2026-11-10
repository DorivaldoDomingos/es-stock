import 'package:flutter/material.dart';
import '../controllers/dados_controller.dart';
import '../controllers/estatistica_controller.dart';
import '../services/api_service.dart';
import 'tema/app_theme.dart';
import 'widgets/botoes.dart';
import 'widgets/cartoes.dart';
import 'widgets/avisos.dart';
class EstatisticasView extends StatefulWidget {
  const EstatisticasView({super.key});

  @override
  State<EstatisticasView> createState() => _EstatisticasViewState();
}

class _EstatisticasViewState extends State<EstatisticasView> {
  bool _aCarregar = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _aCarregar = true;
      _erro = null;
    });
    try {
      await EstatisticaController.carregar();
    } on ApiErro catch (e) {
      _erro = e.mensagem;
    }
    if (mounted) setState(() => _aCarregar = false);
  }

  Future<void> _aplicar(int i) async {
    final e = EstatisticaController.lista[i];
    try {
      await EstatisticaController.aplicarSugestao(e);
      await DadosController.carregarTudo();
      await EstatisticaController.carregar();
      if (!mounted) return;
      setState(() {});
      mostrarMensagem(context,
          'Stock mínimo de ${e.nome} alterado para ${e.sugerido}.');
    } on ApiErro catch (erro) {
      if (mounted) mostrarErro(context, erro.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_aCarregar) {
      return Scaffold(
        appBar: AppBar(title: const Text('Estatísticas e stock mínimo')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_erro != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Estatísticas e stock mínimo')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_erro!, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas e stock mínimo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Consumo médio semanal e stock mínimo sugerido pela simulação de Monte Carlo, calculados com o consumo registado.',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          ...EstatisticaController.lista.asMap().entries.map((entrada) {
            final e = entrada.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CartaoBranco(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.nome,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(e.codigo,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                            fontFamily: 'monospace')),
                    const SizedBox(height: 6),
                    LinhaInfo(
                        etiqueta: 'Consumo médio por semana',
                        valor: '${e.mediaSemanal} un'),
                    LinhaInfo(
                        etiqueta: 'Desvio padrão semanal',
                        valor: '${e.desvioPadrao}'),
                    LinhaInfo(
                        etiqueta: 'Stock mínimo atual',
                        valor: '${e.minimoAtual}'),
                    LinhaInfo(
                        etiqueta: 'Mínimo sugerido',
                        valor: '${e.sugerido}'),
                    const SizedBox(height: 6),
                    BotaoSecundario(
                      texto: 'Aplicar sugestão',
                      onPressed: e.sugerido == e.minimoAtual
                          ? null
                          : () => _aplicar(entrada.key),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
