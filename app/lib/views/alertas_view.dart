import 'package:flutter/material.dart';
import '../controllers/artigo_controller.dart';
import '../models/artigo.dart';
import '../routes.dart';
import 'tema/app_theme.dart';
import 'widgets/cartoes.dart';
import 'widgets/avisos.dart';
import 'widgets/dados.dart';
class AlertasView extends StatelessWidget {
  const AlertasView({super.key});

  @override
  Widget build(BuildContext context) {
    return OuveDados(builder: _corpo);
  }

  Widget _corpo(BuildContext context) {
    final alertas = ArtigoController.alertas();

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: alertas.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Aviso(
                  '${alertas.length} artigos estão abaixo do stock mínimo'),
            );
          }
          return _AlertaCard(artigo: alertas[i - 1]);
        },
      ),
    );
  }
}

class _AlertaCard extends StatelessWidget {
  final Artigo artigo;

  const _AlertaCard({required this.artigo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pushNamed(context, Rotas.artigo,
                arguments: artigo),
            child: Row(
              children: [
                const IconeCaixa(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(artigo.nome,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      Text(artigo.codigo,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                              fontFamily: 'monospace')),
                    ],
                  ),
                ),
                SeloEstado(artigo),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Stock ${artigo.stock} · mínimo ${artigo.stockMinimo}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.muted)),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.pushNamed(context, Rotas.entrada,
                    arguments: artigo),
                child: const Text('Registar entrada ›',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blue)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
