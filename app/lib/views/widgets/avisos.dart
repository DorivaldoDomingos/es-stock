import 'package:flutter/material.dart';
import '../../models/artigo.dart';
import '../tema/app_theme.dart';

class Selo extends StatelessWidget {
  final String texto;
  final Color fundo;
  final Color cor;

  const Selo({
    super.key,
    required this.texto,
    required this.fundo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cor),
      ),
    );
  }
}

class SeloEstado extends StatelessWidget {
  final Artigo artigo;
  final bool longo;

  const SeloEstado(this.artigo, {super.key, this.longo = false});

  @override
  Widget build(BuildContext context) {
    if (artigo.semStock) {
      return const Selo(
          texto: 'Sem stock', fundo: AppColors.redBg, cor: AppColors.red);
    }
    if (artigo.stockBaixo) {
      return Selo(
        texto: longo ? 'Abaixo do mínimo' : 'Stock baixo',
        fundo: AppColors.amberBg,
        cor: AppColors.amber,
      );
    }
    return const Selo(
        texto: 'Em stock', fundo: AppColors.greenBg, cor: AppColors.green);
  }
}

class Aviso extends StatelessWidget {
  final String texto;
  final bool informativo;

  const Aviso(this.texto, {super.key, this.informativo = false});

  @override
  Widget build(BuildContext context) {
    final fundo = informativo ? AppColors.infoBg : AppColors.amberSoft;
    final cor = informativo ? AppColors.info : AppColors.amber;
    final icone =
        informativo ? Icons.qr_code_2 : Icons.warning_amber_rounded;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icone, size: 18, color: cor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: cor)),
          ),
        ],
      ),
    );
  }
}

void mostrarMensagem(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}

void mostrarErro(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: AppColors.red,
      content: Text(texto, style: const TextStyle(color: Colors.white)),
    ));
}
