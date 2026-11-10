import 'package:flutter/material.dart';
import '../controllers/movimento_controller.dart';
import '../models/movimento.dart';
import 'tema/app_theme.dart';
import 'widgets/botoes.dart';
import 'widgets/campos.dart';
import 'widgets/cartoes.dart';
Future<FiltroMovimentos?> mostrarFiltros(
    BuildContext context, FiltroMovimentos atual) {
  return showModalBottomSheet<FiltroMovimentos>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FiltrosSheet(atual: atual),
  );
}

class _FiltrosSheet extends StatefulWidget {
  final FiltroMovimentos atual;

  const _FiltrosSheet({required this.atual});

  @override
  State<_FiltrosSheet> createState() => _FiltrosSheetState();
}

class _FiltrosSheetState extends State<_FiltrosSheet> {
  late TipoMovimento? _tipo;
  late String _periodo;
  late String _utilizador;
  late final TextEditingController _artigo;

  @override
  void initState() {
    super.initState();
    _tipo = widget.atual.tipo;
    _periodo = widget.atual.periodo;
    _utilizador = widget.atual.utilizador;
    _artigo = TextEditingController(text: widget.atual.artigo);
  }

  @override
  void dispose() {
    _artigo.dispose();
    super.dispose();
  }

  void _limpar() {
    setState(() {
      _tipo = null;
      _periodo = '7 dias';
      _utilizador = 'Todos';
      _artigo.text = '';
    });
  }

  Widget _grupo(String titulo, List<Widget> chips) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EtiquetaCampo(titulo),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teclado = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + teclado),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text('Filtros',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                TextButton(onPressed: _limpar, child: const Text('Limpar')),
              ],
            ),
            _grupo('Tipo de movimento', [
              ChipFiltro(
                  texto: 'Todos',
                  selecionado: _tipo == null,
                  onTap: () => setState(() => _tipo = null)),
              ChipFiltro(
                  texto: 'Entradas',
                  selecionado: _tipo == TipoMovimento.entrada,
                  onTap: () =>
                      setState(() => _tipo = TipoMovimento.entrada)),
              ChipFiltro(
                  texto: 'Saídas',
                  selecionado: _tipo == TipoMovimento.saida,
                  onTap: () => setState(() => _tipo = TipoMovimento.saida)),
              ChipFiltro(
                  texto: 'Ajustes',
                  selecionado: _tipo == TipoMovimento.ajuste,
                  onTap: () =>
                      setState(() => _tipo = TipoMovimento.ajuste)),
            ]),
            _grupo(
              'Período',
              ['Hoje', '7 dias', '30 dias', 'Tudo']
                  .map((p) => ChipFiltro(
                      texto: p,
                      selecionado: _periodo == p,
                      onTap: () => setState(() => _periodo = p)))
                  .toList(),
            ),
            _grupo(
              'Utilizador',
              ['Todos', ...MovimentoController.utilizadores]
                  .map((u) => ChipFiltro(
                      texto: u,
                      selecionado: _utilizador == u,
                      onTap: () => setState(() => _utilizador = u)))
                  .toList(),
            ),
            const EtiquetaCampo('Artigo (nome ou código)'),
            TextField(
              controller: _artigo,
              decoration: const InputDecoration(
                hintText: 'Todos os artigos',
                prefixIcon: Icon(Icons.search, color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 16),
            BotaoPrincipal(
              texto: 'Aplicar filtros',
              onPressed: () => Navigator.pop(
                context,
                FiltroMovimentos(
                  tipo: _tipo,
                  periodo: _periodo,
                  utilizador: _utilizador,
                  artigo: _artigo.text.trim(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
