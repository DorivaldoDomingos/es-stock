import 'package:flutter/material.dart';
import '../controllers/movimento_controller.dart';
import '../models/movimento.dart';
import 'tema/app_theme.dart';
import 'widgets/cartoes.dart';
import 'widgets/dados.dart';
import 'widgets/avisos.dart';
import '../services/api_service.dart';
import 'filtros_sheet.dart';
class HistoricoView extends StatefulWidget {
  const HistoricoView({super.key});

  @override
  State<HistoricoView> createState() => _HistoricoViewState();
}

class _HistoricoViewState extends State<HistoricoView> {
  // o filtro fica guardado no controller, para sobreviver às recargas de dados
  FiltroMovimentos get _filtro => MovimentoController.filtro;

  Future<void> _abrirFiltros() async {
    final resultado = await mostrarFiltros(context, _filtro);
    if (resultado == null) return;
    try {
      await MovimentoController.carregar(resultado);
    } on ApiErro catch (e) {
      if (mounted) mostrarErro(context, e.mensagem);
      return;
    }
    if (mounted) setState(() {});
  }

  Widget _chipFiltro(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(texto,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OuveDados(builder: _corpo);
  }

  Widget _corpo(BuildContext context) {
    final lista = MovimentoController.movimentos;

    // um cabeçalho (HOJE, ONTEM...) sempre que o dia muda
    final linhas = <Widget>[];
    int? diaAnterior;
    for (final m in lista) {
      if (m.diasAtras != diaAnterior) {
        linhas.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(MovimentoController.tituloDoDia(m.diasAtras),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted)),
        ));
        diaAnterior = m.diasAtras;
      }
      linhas.add(MovimentoCard(movimento: m));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          IconButton(
            tooltip: 'Filtros',
            icon: const Icon(Icons.filter_list),
            onPressed: _abrirFiltros,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chipFiltro(_filtro.periodoTexto),
                if (_filtro.tipo != null) _chipFiltro(_filtro.tipo!.texto),
                if (_filtro.utilizador != 'Todos')
                  _chipFiltro(_filtro.utilizador),
                if (_filtro.artigo.isNotEmpty) _chipFiltro(_filtro.artigo),
              ],
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text('Sem movimentos para estes filtros.'))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    children: linhas,
                  ),
          ),
        ],
      ),
    );
  }
}
