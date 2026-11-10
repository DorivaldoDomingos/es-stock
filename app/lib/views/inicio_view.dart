import 'package:flutter/material.dart';
import '../controllers/artigo_controller.dart';
import '../controllers/movimento_controller.dart';
import '../controllers/utilizador_controller.dart';
import '../routes.dart';
import 'tema/app_theme.dart';
import 'widgets/cartoes.dart';
import 'widgets/avisos.dart';
import 'widgets/dados.dart';
class InicioView extends StatelessWidget {
  final ValueChanged<int> onIrPara;

  const InicioView({super.key, required this.onIrPara});

  @override
  Widget build(BuildContext context) {
    return OuveDados(builder: _corpo);
  }

  Widget _corpo(BuildContext context) {
    final alertas = ArtigoController.alertas();
    final hoje = MovimentoController.movimentosHoje();
    final saidas7 = MovimentoController.saidasUltimos7Dias();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Olá, ${UtilizadorController.primeiroNome}',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      Text('Armazém central · ${UtilizadorController.papel}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Conta',
                  onSelected: (_) {
                    UtilizadorController.sair();
                    Navigator.pushNamedAndRemoveUntil(
                        context, Rotas.login, (route) => false);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'sair', child: Text('Terminar sessão')),
                  ],
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.blue,
                    child: Text(UtilizadorController.iniciais,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Numero(
                    valor: '${ArtigoController.artigos.length}',
                    texto: 'Artigos',
                    fundo: Colors.white,
                    cor: AppColors.text,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Numero(
                    valor: '${alertas.length}',
                    texto: 'Stock baixo',
                    fundo: AppColors.amberBg,
                    cor: AppColors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Atalho(
                    texto: 'Registar saída',
                    icone: Icons.north_east,
                    fundo: AppColors.lime,
                    onTap: () => Navigator.pushNamed(context, Rotas.lerQr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Atalho(
                    texto: 'Registar entrada',
                    icone: Icons.south_west,
                    fundo: Colors.white,
                    onTap: () {
                      onIrPara(1);
                      mostrarMensagem(context,
                          'Escolha o artigo e toque em «Registar entrada».');
                    },
                  ),
                ),
              ],
            ),
            TituloSecao('Alertas de stock',
                acaoTexto: 'Ver todos', onAcao: () => onIrPara(2)),
            ...alertas.take(3).map((a) => ArtigoCard(
                  artigo: a,
                  seloLongo: true,
                  onTap: () =>
                      Navigator.pushNamed(context, Rotas.artigo, arguments: a),
                )),
            const SizedBox(height: 4),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pushNamed(context, Rotas.estatisticas),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.show_chart, color: AppColors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estatísticas e stock mínimo',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          Text('Consumo semanal e simulação de Monte Carlo',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.muted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                '$hoje movimentos hoje · $saidas7 unidades saíram nos últimos 7 dias',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  final String valor;
  final String texto;
  final Color fundo;
  final Color cor;

  const _Numero({
    required this.valor,
    required this.texto,
    required this.fundo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(valor,
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w800, color: cor)),
          Text(texto, style: TextStyle(fontSize: 12, color: cor)),
        ],
      ),
    );
  }
}

class _Atalho extends StatelessWidget {
  final String texto;
  final IconData icone;
  final Color fundo;
  final VoidCallback onTap;

  const _Atalho({
    required this.texto,
    required this.icone,
    required this.fundo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        height: 84,
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icone, size: 18, color: AppColors.navy),
            Text(texto,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
