import 'package:flutter/material.dart';
import '../../models/movimento.dart';
import '../../models/artigo.dart';
import '../tema/app_theme.dart';
import 'avisos.dart';

class IconeCaixa extends StatelessWidget {
  const IconeCaixa({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.inventory_2_outlined,
          size: 20, color: AppColors.blue),
    );
  }
}

class ArtigoCard extends StatelessWidget {
  final Artigo artigo;
  final VoidCallback onTap;
  final bool seloLongo;

  const ArtigoCard({
    super.key,
    required this.artigo,
    required this.onTap,
    this.seloLongo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                    const SizedBox(height: 2),
                    Text(artigo.codigo,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                            fontFamily: 'monospace')),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${artigo.stock}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  SeloEstado(artigo, longo: seloLongo),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovimentoCard extends StatelessWidget {
  final Movimento movimento;
  final bool mostrarUtilizador;

  const MovimentoCard({
    super.key,
    required this.movimento,
    this.mostrarUtilizador = true,
  });

  @override
  Widget build(BuildContext context) {
    final entrada = movimento.tipo == TipoMovimento.entrada;
    final cor = entrada ? AppColors.green : AppColors.amber;
    final fundo = entrada ? AppColors.greenBg : AppColors.amberBg;
    final icone = entrada ? Icons.south_west : Icons.north_east;
    final detalhe = mostrarUtilizador
        ? '${movimento.codigo} · ${movimento.utilizador} · ${movimento.hora}'
        : '${movimento.tipo.texto} · ${movimento.destinoOrigem}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: fundo,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icone, size: 18, color: cor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movimento.artigo,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(detalhe,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          Text(movimento.quantidadeTexto,
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: cor)),
        ],
      ),
    );
  }
}

class LinhaInfo extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool mono;

  const LinhaInfo({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta,
              style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(valor,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    fontFamily: mono ? 'monospace' : null)),
          ),
        ],
      ),
    );
  }
}

class CartaoBranco extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const CartaoBranco({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class TituloSecao extends StatelessWidget {
  final String texto;
  final String? acaoTexto;
  final VoidCallback? onAcao;

  const TituloSecao(this.texto, {super.key, this.acaoTexto, this.onAcao});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(texto,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          if (acaoTexto != null)
            InkWell(
              onTap: onAcao,
              child: Text(acaoTexto!,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.muted)),
            ),
        ],
      ),
    );
  }
}

class ResumoArtigo extends StatelessWidget {
  final String nome;
  final String codigo;
  final Widget direita;

  const ResumoArtigo({
    super.key,
    required this.nome,
    required this.codigo,
    required this.direita,
  });

  @override
  Widget build(BuildContext context) {
    return CartaoBranco(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 20, color: AppColors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                Text(codigo,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                        fontFamily: 'monospace')),
              ],
            ),
          ),
          direita,
        ],
      ),
    );
  }
}

class ChipFiltro extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback onTap;

  const ChipFiltro({
    super.key,
    required this.texto,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selecionado ? AppColors.blue : AppColors.border),
        ),
        child: Text(texto,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selecionado ? Colors.white : AppColors.text)),
      ),
    );
  }
}
