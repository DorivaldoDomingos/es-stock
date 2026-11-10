import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/artigo_controller.dart';
import '../routes.dart';
import '../services/api_service.dart';
import 'tema/app_theme.dart';
import 'widgets/botoes.dart';
import 'widgets/avisos.dart';

class LerQrView extends StatefulWidget {
  const LerQrView({super.key});

  @override
  State<LerQrView> createState() => _LerQrViewState();
}

class _LerQrViewState extends State<LerQrView> {
  // no browser a câmara não é usada: o código escreve-se à mão
  MobileScannerController? _scanner;
  bool _lanterna = false;
  bool _aProcurar = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _scanner = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        formats: const [BarcodeFormat.qrCode],
      );
    }
  }

  @override
  void dispose() {
    _scanner?.dispose();
    super.dispose();
  }

  // procura o artigo na API e abre a ficha
  Future<void> _abrirArtigo(String codigo) async {
    if (_aProcurar) return;
    _aProcurar = true;
    try {
      final artigo = await ArtigoController.procurarPorCodigo(codigo);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Rotas.artigo, arguments: artigo);
    } on ApiErro catch (e) {
      _aProcurar = false;
      if (mounted) mostrarErro(context, e.mensagem);
    }
  }

  void _aoDetetar(BarcodeCapture captura) {
    if (captura.barcodes.isEmpty) return;
    final texto = captura.barcodes.first.rawValue;
    if (texto != null && texto.isNotEmpty) _abrirArtigo(texto);
  }

  void _codigoManual() {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Introduzir código',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Exemplo: ES-CAB-0107',
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(hintText: 'ES-XXX-0000'),
              ),
              const SizedBox(height: 12),
              BotaoPrincipal(
                texto: 'Procurar',
                icone: Icons.search,
                onPressed: () {
                  final codigo = controller.text.trim().toUpperCase();
                  Navigator.pop(ctx);
                  _abrirArtigo(codigo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _zonaDeLeitura() {
    final scanner = _scanner;
    if (scanner == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No browser não há leitura por câmara.\nUse a introdução manual do código.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      );
    }
    return Center(
      child: Container(
        width: 270,
        height: 270,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lime, width: 4),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: MobileScanner(
          controller: scanner,
          onDetect: _aoDetetar,
          errorBuilder: (context, erro, child) => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Não foi possível abrir a câmara.\nUse a introdução manual do código.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Ler QR Code',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        actions: [
          if (_scanner != null)
            IconButton(
              tooltip: 'Lanterna',
              icon: Icon(_lanterna ? Icons.flash_on : Icons.flash_off,
                  color: _lanterna ? AppColors.lime : Colors.white),
              onPressed: () {
                _scanner?.toggleTorch();
                setState(() => _lanterna = !_lanterna);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _zonaDeLeitura()),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Aponte a câmara ao QR Code da etiqueta.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BotaoPrincipal(
                texto: 'Introduzir código manualmente',
                icone: Icons.keyboard_outlined,
                onPressed: _codigoManual,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
