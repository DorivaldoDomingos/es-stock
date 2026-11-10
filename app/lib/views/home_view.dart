import 'package:flutter/material.dart';
import '../routes.dart';
import 'tema/app_theme.dart';
import 'alertas_view.dart';
import 'artigos_view.dart';
import 'historico_view.dart';
import 'inicio_view.dart';
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _indice = 0;

  void _irPara(int i) => setState(() => _indice = i);

  Widget _item(int i, IconData icone, IconData iconeAtivo, String texto) {
    final ativo = _indice == i;
    final cor = ativo ? AppColors.blue : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: () => _irPara(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ativo ? iconeAtivo : icone, color: cor, size: 22),
            const SizedBox(height: 2),
            Text(texto,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: ativo ? FontWeight.w800 : FontWeight.w500,
                    color: cor)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paginas = <Widget>[
      InicioView(onIrPara: _irPara),
      const ArtigosView(),
      const AlertasView(),
      const HistoricoView(),
    ];
    return Scaffold(
      body: IndexedStack(index: _indice, children: paginas),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lime,
        foregroundColor: AppColors.navy,
        elevation: 2,
        shape: const CircleBorder(),
        tooltip: 'Ler QR Code',
        onPressed: () => Navigator.pushNamed(context, Rotas.lerQr),
        child: const Icon(Icons.qr_code_scanner, size: 28),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 64,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _item(0, Icons.home_outlined, Icons.home, 'Início'),
            _item(1, Icons.inventory_2_outlined, Icons.inventory_2, 'Artigos'),
            const SizedBox(width: 72),
            _item(2, Icons.notifications_none, Icons.notifications, 'Alertas'),
            _item(3, Icons.history, Icons.history, 'Histórico'),
          ],
        ),
      ),
    );
  }
}
