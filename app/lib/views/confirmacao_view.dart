import 'package:flutter/material.dart';
import '../controllers/movimento_controller.dart';
import '../controllers/utilizador_controller.dart';
import '../models/movimento.dart';
import '../routes.dart';
import 'tema/app_theme.dart';
import 'widgets/avisos.dart';
import 'widgets/botoes.dart';
import 'widgets/cartoes.dart';
class ConfirmacaoView extends StatelessWidget {
  final ResultadoMovimento dados;

  const ConfirmacaoView({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    final saida = dados.tipo == TipoMovimento.saida;
    final a = dados.artigo;
    final plural = dados.quantidade != 1;
    final unidades = plural ? 'unidades' : 'unidade';
    final frase = saida
        ? '${dados.quantidade} $unidades de ${a.nome} ${plural ? 'saíram' : 'saiu'} do armazém.'
        : '${dados.quantidade} $unidades de ${a.nome} ${plural ? 'entraram' : 'entrou'} no armazém.';
    final abaixo = dados.stockDepois <= a.stockMinimo;
    final data = MovimentoController.dataDe(0);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 24),
                    const Center(
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.greenBg,
                        child: Icon(Icons.check,
                            size: 36, color: AppColors.green),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(saida ? 'Saída registada' : 'Entrada registada',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(frase,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted)),
                    const SizedBox(height: 20),
                    CartaoBranco(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      child: Column(
                        children: [
                          LinhaInfo(
                              etiqueta: 'Artigo', valor: a.codigo, mono: true),
                          LinhaInfo(
                              etiqueta: 'Quantidade',
                              valor: saida
                                  ? '-${dados.quantidade}'
                                  : '+${dados.quantidade}'),
                          if (dados.destinoOrigem.isNotEmpty)
                            LinhaInfo(
                                etiqueta: saida ? 'Destino' : 'Origem',
                                valor: dados.destinoOrigem),
                          LinhaInfo(
                              etiqueta: 'Stock atual',
                              valor: '${dados.stockDepois} unidades'),
                          LinhaInfo(
                              etiqueta: 'Registado por',
                              valor: '${UtilizadorController.nome} · $data'),
                        ],
                      ),
                    ),
                    if (abaixo) ...[
                      const SizedBox(height: 12),
                      Aviso(
                          'O stock continua abaixo do mínimo (${a.stockMinimo}).'),
                    ],
                  ],
                ),
              ),
              BotaoEscuro(
                texto: 'Ver ficha do artigo',
                onPressed: () {
                  Navigator.popUntil(
                      context, (route) => route.settings.name == Rotas.home);
                  Navigator.pushNamed(context, Rotas.artigo, arguments: a);
                },
              ),
              const SizedBox(height: 10),
              BotaoSecundario(
                texto: 'Voltar ao início',
                onPressed: () => Navigator.popUntil(
                    context, (route) => route.settings.name == Rotas.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
