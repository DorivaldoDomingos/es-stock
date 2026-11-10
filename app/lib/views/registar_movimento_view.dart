import 'package:flutter/material.dart';
import '../controllers/dados_controller.dart';
import '../controllers/movimento_controller.dart';
import '../models/artigo.dart';
import '../models/movimento.dart';
import '../routes.dart';
import '../services/api_service.dart';
import 'tema/app_theme.dart';
import 'widgets/avisos.dart';
import 'widgets/botoes.dart';
import 'widgets/campos.dart';
import 'widgets/cartoes.dart';
class RegistarMovimentoView extends StatefulWidget {
  final Artigo artigo;
  final TipoMovimento tipo;

  const RegistarMovimentoView({
    super.key,
    required this.artigo,
    required this.tipo,
  });

  @override
  State<RegistarMovimentoView> createState() =>
      _RegistarMovimentoViewState();
}

class _RegistarMovimentoViewState extends State<RegistarMovimentoView> {
  int _quantidade = 1;
  late final TextEditingController _destinoOrigem;
  final _observacoes = TextEditingController();

  bool _aEnviar = false;

  bool get _saida => widget.tipo == TipoMovimento.saida;

  @override
  void initState() {
    super.initState();
    _destinoOrigem = TextEditingController(
        text: _saida ? '' : 'Fornecedor ${widget.artigo.fornecedor}');
  }

  @override
  void dispose() {
    _destinoOrigem.dispose();
    _observacoes.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final texto = _destinoOrigem.text.trim();
    if (_saida && texto.isEmpty) {
      mostrarErro(
          context, 'Indique o destino do material (ex.: Instalação Cliente X)');
      return;
    }
    setState(() => _aEnviar = true);
    try {
      final resultado = await MovimentoController.registar(
        artigo: widget.artigo,
        tipo: widget.tipo,
        quantidade: _quantidade,
        destinoOrigem: texto,
      );
      try {
        await DadosController.carregarTudo();
      } on ApiErro {
        // o movimento já ficou guardado; as listas atualizam na próxima ligação
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Rotas.confirmacao,
          arguments: resultado);
    } on ApiErro catch (e) {
      if (!mounted) return;
      setState(() => _aEnviar = false);
      mostrarErro(context, e.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.artigo;
    final depois = _saida ? a.stock - _quantidade : a.stock + _quantidade;
    final abaixo = depois <= a.stockMinimo;

    String? aviso;
    if (abaixo) {
      aviso = _saida
          ? 'O stock ficará no mínimo ou abaixo ($depois ≤ ${a.stockMinimo})'
          : 'O stock continuará no mínimo ou abaixo (${a.stockMinimo}).';
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(_saida ? 'Registar saída' : 'Registar entrada')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                ResumoArtigo(
                  nome: a.nome,
                  codigo: a.codigo,
                  direita: _SeloStock(a.stock),
                ),
                const TituloSecao('Quantidade'),
                SeletorQuantidade(
                  valor: _quantidade,
                  maximo: _saida ? a.stock : null,
                  onChanged: (v) => setState(() => _quantidade = v),
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: _saida ? 'Destino' : 'Origem',
                  dica: _saida
                      ? 'Ex.: Instalação Cliente X'
                      : 'Ex.: Fornecedor, guia de remessa',
                  icone: _saida
                      ? Icons.location_on_outlined
                      : Icons.local_shipping_outlined,
                  controller: _destinoOrigem,
                ),
                CampoTexto(
                  etiqueta: 'Observações (opcional)',
                  dica: 'Ex.: referência da encomenda',
                  controller: _observacoes,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Text('Stock: ${a.stock} → $depois',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('Mínimo ${a.stockMinimo}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
                if (aviso != null) ...[
                  const SizedBox(height: 10),
                  Aviso(aviso),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SafeArea(
              top: false,
              child: BotaoPrincipal(
                texto: _aEnviar
                    ? 'A guardar...'
                    : (_saida ? 'Confirmar saída' : 'Confirmar entrada'),
                onPressed: _aEnviar ? null : _confirmar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeloStock extends StatelessWidget {
  final int stock;

  const _SeloStock(this.stock);

  @override
  Widget build(BuildContext context) {
    final vazio = stock <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: vazio ? AppColors.redBg : AppColors.greenBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(vazio ? '0 em stock' : '$stock em stock',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: vazio ? AppColors.red : AppColors.green)),
    );
  }
}
