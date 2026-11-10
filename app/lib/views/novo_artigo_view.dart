import 'package:flutter/material.dart';
import '../controllers/artigo_controller.dart';
import '../controllers/dados_controller.dart';
import '../routes.dart';
import '../services/api_service.dart';
import 'tema/app_theme.dart';
import 'widgets/avisos.dart';
import 'widgets/botoes.dart';
import 'widgets/campos.dart';
class NovoArtigoView extends StatefulWidget {
  const NovoArtigoView({super.key});

  @override
  State<NovoArtigoView> createState() => _NovoArtigoViewState();
}

class _NovoArtigoViewState extends State<NovoArtigoView> {
  final _nome = TextEditingController();
  final _inicial = TextEditingController(text: '0');
  final _minimo = TextEditingController(text: '5');
  final _unidade = TextEditingController(text: 'un');
  final _fornecedor = TextEditingController();
  String? _categoria;
  String? _localizacao;
  String _codigo = '';
  bool _aGuardar = false;

  @override
  void dispose() {
    _nome.dispose();
    _inicial.dispose();
    _minimo.dispose();
    _unidade.dispose();
    _fornecedor.dispose();
    super.dispose();
  }

  // o código é gerado pelo servidor, a partir do prefixo da categoria
  Future<void> _escolherCategoria(String categoria) async {
    setState(() {
      _categoria = categoria;
      _codigo = '...';
    });
    try {
      final codigo = await ArtigoController.proximoCodigo(categoria);
      if (mounted) setState(() => _codigo = codigo);
    } on ApiErro catch (e) {
      if (!mounted) return;
      setState(() => _codigo = '');
      mostrarErro(context, e.mensagem);
    }
  }

  Future<void> _guardar() async {
    if (_nome.text.trim().isEmpty) {
      mostrarErro(context, 'Indique o nome do artigo.');
      return;
    }
    if (_categoria == null) {
      mostrarErro(context, 'Escolha a categoria.');
      return;
    }
    if (_localizacao == null) {
      mostrarErro(context, 'Escolha a localização.');
      return;
    }
    setState(() => _aGuardar = true);
    try {
      final novo = await ArtigoController.criar(
        nome: _nome.text.trim(),
        categoria: _categoria!,
        localizacao: _localizacao,
        fornecedor: _fornecedor.text.trim(),
        unidade: _unidade.text.trim().isEmpty ? 'un' : _unidade.text.trim(),
        stockMinimo: int.tryParse(_minimo.text) ?? 0,
        stockInicial: int.tryParse(_inicial.text) ?? 0,
      );
      try {
        await DadosController.carregarTudo();
      } on ApiErro {
        // o artigo já foi criado; as listas atualizam na próxima ligação
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Rotas.qrArtigo, arguments: novo);
    } on ApiErro catch (e) {
      if (!mounted) return;
      setState(() => _aGuardar = false);
      mostrarErro(context, e.mensagem);
    }
  }

  Widget _numero(String etiqueta, TextEditingController c, {bool texto = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EtiquetaCampo(etiqueta),
            TextField(
              controller: c,
              keyboardType: texto ? TextInputType.text : TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo artigo')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                CampoTexto(
                  etiqueta: 'Nome',
                  dica: 'Ex.: Sensor de movimento PIR',
                  controller: _nome,
                ),
                CampoSelecao(
                  etiqueta: 'Categoria',
                  dica: 'Escolha a categoria',
                  valor: _categoria,
                  opcoes: ArtigoController.categorias,
                  onChanged: _escolherCategoria,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const EtiquetaCampo('Código (gerado)'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.qr_code_2,
                                size: 20, color: AppColors.muted),
                            const SizedBox(width: 10),
                            Text(
                              _categoria == null
                                  ? 'Escolha a categoria'
                                  : _codigo,
                              style: TextStyle(
                                fontSize: 14,
                                color: _categoria == null
                                    ? const Color(0xFF8795A9)
                                    : AppColors.text,
                                fontFamily:
                                    _categoria == null ? null : 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      _numero('Stock inicial', _inicial),
                      _numero('Stock mínimo', _minimo),
                      _numero('Unidade', _unidade, texto: true),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                CampoSelecao(
                  etiqueta: 'Localização',
                  dica: 'Zona e prateleira',
                  icone: Icons.location_on_outlined,
                  valor: _localizacao,
                  opcoes: ArtigoController.localizacoes,
                  onChanged: (v) => setState(() => _localizacao = v),
                ),
                CampoTexto(
                  etiqueta: 'Fornecedor (opcional)',
                  dica: 'Ex.: Nova Vision',
                  controller: _fornecedor,
                ),
                const Aviso(
                  'O QR Code com o código do artigo é gerado ao guardar.',
                  informativo: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SafeArea(
              top: false,
              child: BotaoPrincipal(
                texto: _aGuardar ? 'A guardar...' : 'Guardar e gerar QR',
                onPressed: _aGuardar ? null : _guardar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
