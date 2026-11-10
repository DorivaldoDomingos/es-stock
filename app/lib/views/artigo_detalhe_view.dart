import 'package:flutter/material.dart';
import '../controllers/movimento_controller.dart';
import '../models/artigo.dart';
import '../models/movimento.dart';
import '../routes.dart';
import 'tema/app_theme.dart';
import 'widgets/botoes.dart';
import 'widgets/cartoes.dart';
import 'widgets/avisos.dart';
class ArtigoDetalheView extends StatefulWidget {
  final Artigo artigo;

  const ArtigoDetalheView({super.key, required this.artigo});

  @override
  State<ArtigoDetalheView> createState() => _ArtigoDetalheViewState();
}

class _ArtigoDetalheViewState extends State<ArtigoDetalheView> {
  List<Movimento> movimentos = [];

  Artigo get artigo => widget.artigo;

  @override
  void initState() {
    super.initState();
    _carregarMovimentos();
  }

  // os últimos movimentos vêm da API; se falhar, a ficha aparece na mesma
  Future<void> _carregarMovimentos() async {
    try {
      final lista = await MovimentoController.doArtigo(artigo.codigo);
      if (mounted) setState(() => movimentos = lista);
    } catch (_) {
      // sem histórico: a ficha mostra "Sem movimentos"
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = movimentos.isEmpty
        ? 'Sem movimentos'
        : '${movimentos.first.tipo.texto} de ${movimentos.first.quantidade} · ${MovimentoController.dataDe(movimentos.first.diasAtras).substring(0, 5)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha do artigo'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'qr') {
                Navigator.pushNamed(context, Rotas.qrArtigo,
                    arguments: artigo);
              } else {
                mostrarMensagem(context,
                    'Editar artigo: ainda não está disponível nesta versão.');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'qr', child: Text('Ver QR Code')),
              PopupMenuItem(value: 'editar', child: Text('Editar artigo')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          CartaoBranco(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconeCaixa(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(artigo.nome,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800)),
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
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Stock atual',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.muted)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${artigo.stock}',
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1)),
                            const SizedBox(width: 6),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text('unidades',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.muted)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Stock mínimo',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.muted)),
                        Text('${artigo.stockMinimo}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                LinhaInfo(etiqueta: 'Categoria', valor: artigo.categoria),
                LinhaInfo(etiqueta: 'Localização', valor: artigo.localizacao),
                LinhaInfo(etiqueta: 'Fornecedor', valor: artigo.fornecedor),
                LinhaInfo(etiqueta: 'Último movimento', valor: ultimo),
              ],
            ),
          ),
          if (movimentos.isNotEmpty) ...[
            const TituloSecao('Últimos movimentos'),
            ...movimentos.map((m) => MovimentoCard(
                  movimento: m,
                  mostrarUtilizador: false,
                )),
          ],
          const SizedBox(height: 16),
          BotaoPrincipal(
            texto: 'Registar saída',
            onPressed: artigo.semStock
                ? () => mostrarErro(
                    context, 'Sem stock: não é possível registar saídas.')
                : () => Navigator.pushNamed(context, Rotas.saida,
                    arguments: artigo),
          ),
          const SizedBox(height: 10),
          BotaoSecundario(
            texto: 'Registar entrada',
            onPressed: () => Navigator.pushNamed(context, Rotas.entrada,
                arguments: artigo),
          ),
        ],
      ),
    );
  }
}
