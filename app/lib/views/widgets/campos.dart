import 'package:flutter/material.dart';
import '../tema/app_theme.dart';

class EtiquetaCampo extends StatelessWidget {
  final String texto;

  const EtiquetaCampo(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(texto,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
    );
  }
}

class CampoTexto extends StatelessWidget {
  final String etiqueta;
  final String? dica;
  final IconData? icone;
  final TextEditingController? controller;
  final bool password;
  final TextInputType? teclado;
  final bool ativo;

  const CampoTexto({
    super.key,
    required this.etiqueta,
    this.dica,
    this.icone,
    this.controller,
    this.password = false,
    this.teclado,
    this.ativo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EtiquetaCampo(etiqueta),
          TextField(
            controller: controller,
            obscureText: password,
            keyboardType: teclado,
            enabled: ativo,
            decoration: InputDecoration(
              hintText: dica,
              prefixIcon: icone == null
                  ? null
                  : Icon(icone, size: 20, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class CampoSelecao extends StatelessWidget {
  final String etiqueta;
  final String dica;
  final String? valor;
  final List<String> opcoes;
  final IconData? icone;
  final ValueChanged<String> onChanged;

  const CampoSelecao({
    super.key,
    required this.etiqueta,
    required this.dica,
    required this.valor,
    required this.opcoes,
    required this.onChanged,
    this.icone,
  });

  void _abrir(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: opcoes.map((o) {
              return ListTile(
                title: Text(o),
                trailing: o == valor
                    ? const Icon(Icons.check, color: AppColors.blue)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  onChanged(o);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vazio = valor == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EtiquetaCampo(etiqueta),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _abrir(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  if (icone != null) ...[
                    Icon(icone, size: 20, color: AppColors.muted),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      vazio ? dica : valor!,
                      style: TextStyle(
                        fontSize: 14,
                        color: vazio
                            ? const Color(0xFF8795A9)
                            : AppColors.text,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SeletorQuantidade extends StatelessWidget {
  final int valor;
  final int minimo;
  final int? maximo;
  final ValueChanged<int> onChanged;

  const SeletorQuantidade({
    super.key,
    required this.valor,
    required this.onChanged,
    this.minimo = 1,
    this.maximo,
  });

  @override
  Widget build(BuildContext context) {
    final podeDiminuir = valor > minimo;
    final podeAumentar = maximo == null || valor < maximo!;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _Botao(
            icone: Icons.remove,
            escuro: false,
            onTap: podeDiminuir ? () => onChanged(valor - 1) : null,
          ),
          Expanded(
            child: Text('$valor',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700)),
          ),
          _Botao(
            icone: Icons.add,
            escuro: true,
            onTap: podeAumentar ? () => onChanged(valor + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _Botao extends StatelessWidget {
  final IconData icone;
  final bool escuro;
  final VoidCallback? onTap;

  const _Botao({required this.icone, required this.escuro, this.onTap});

  @override
  Widget build(BuildContext context) {
    final ativo = onTap != null;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 40,
        decoration: BoxDecoration(
          color: escuro && ativo ? AppColors.blue : AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icone,
            color: escuro && ativo
                ? Colors.white
                : (ativo ? AppColors.text : AppColors.muted)),
      ),
    );
  }
}
