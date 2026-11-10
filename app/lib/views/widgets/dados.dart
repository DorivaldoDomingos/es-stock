import 'package:flutter/material.dart';
import '../../controllers/dados_controller.dart';

// Reconstrói o ecrã sempre que os dados são recarregados da API.
class OuveDados extends StatelessWidget {
  final WidgetBuilder builder;

  const OuveDados({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: DadosController.versao,
      builder: (context, _, __) => builder(context),
    );
  }
}
