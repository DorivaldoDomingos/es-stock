import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/artigo.dart';
import '../routes.dart';
import 'tema/app_theme.dart';
import 'widgets/botoes.dart';
import 'widgets/avisos.dart';

class QrArtigoView extends StatelessWidget {
  final Artigo artigo;

  const QrArtigoView({super.key, required this.artigo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code do artigo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: artigo.codigo,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(artigo.codigo,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace')),
                  Text(artigo.nome,
                      style: const TextStyle(color: AppColors.muted)),
                ],
              ),
            ),
            const Spacer(),
            BotaoSecundario(
              texto: 'Imprimir etiqueta',
              icone: Icons.print_outlined,
              onPressed: () => mostrarMensagem(
                  context, 'Impressão: ainda não está disponível nesta versão.'),
            ),
            const SizedBox(height: 10),
            BotaoPrincipal(
              texto: 'Registar entrada',
              onPressed: () => Navigator.pushNamed(context, Rotas.entrada,
                  arguments: artigo),
            ),
          ],
        ),
      ),
    );
  }
}
