import 'package:flutter/material.dart';
import '../tema/app_theme.dart';
class BotaoPrincipal extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final VoidCallback? onPressed;

  const BotaoPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return _BotaoBase(
      texto: texto,
      icone: icone,
      onPressed: onPressed,
      fundo: AppColors.lime,
      cor: AppColors.navy,
    );
  }
}
class BotaoEscuro extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final VoidCallback? onPressed;

  const BotaoEscuro({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return _BotaoBase(
      texto: texto,
      icone: icone,
      onPressed: onPressed,
      fundo: AppColors.blue,
      cor: Colors.white,
    );
  }
}
class BotaoSecundario extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final VoidCallback? onPressed;

  const BotaoSecundario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return _BotaoBase(
      texto: texto,
      icone: icone,
      onPressed: onPressed,
      fundo: Colors.white,
      cor: AppColors.blue,
      contorno: AppColors.border,
    );
  }
}

class _BotaoBase extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final VoidCallback? onPressed;
  final Color fundo;
  final Color cor;
  final Color? contorno;

  const _BotaoBase({
    required this.texto,
    required this.onPressed,
    required this.fundo,
    required this.cor,
    this.icone,
    this.contorno,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = FilledButton.styleFrom(
      backgroundColor: fundo,
      foregroundColor: cor,
      disabledBackgroundColor: AppColors.border,
      minimumSize: const Size.fromHeight(50),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: contorno == null
            ? BorderSide.none
            : BorderSide(color: contorno!),
      ),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
    );
    if (icone == null) {
      return FilledButton(
          onPressed: onPressed, style: estilo, child: Text(texto));
    }
    return FilledButton.icon(
      onPressed: onPressed,
      style: estilo,
      icon: Icon(icone, size: 20),
      label: Text(texto),
    );
  }
}
