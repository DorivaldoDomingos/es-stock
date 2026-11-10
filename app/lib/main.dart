import 'package:flutter/material.dart';
import 'routes.dart';
import 'services/api_service.dart';
import 'views/tema/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.carregarEndereco();
  runApp(const EsStockApp());
}

class EsStockApp extends StatelessWidget {
  const EsStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ES Stock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: Rotas.login,
      onGenerateRoute: Rotas.gerar,
    );
  }
}
