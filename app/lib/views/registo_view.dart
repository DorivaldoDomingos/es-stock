import 'package:flutter/material.dart';
import '../controllers/dados_controller.dart';
import '../controllers/utilizador_controller.dart';
import '../routes.dart';
import '../services/api_service.dart';
import 'tema/app_theme.dart';
import 'widgets/avisos.dart';
import 'widgets/botoes.dart';
import 'widgets/campos.dart';

// Criar conta: a conta nasce como operador e a sessão fica logo iniciada.
class RegistoView extends StatefulWidget {
  const RegistoView({super.key});

  @override
  State<RegistoView> createState() => _RegistoViewState();
}

class _RegistoViewState extends State<RegistoView> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();
  bool _aCriar = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _password.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    final nome = _nome.text.trim();
    final email = _email.text.trim();
    if (nome.length < 2) {
      mostrarErro(context, 'Indique o nome completo.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      mostrarErro(context, 'Indique um email válido.');
      return;
    }
    if (_password.text.length < 8) {
      mostrarErro(context, 'A palavra-passe precisa de pelo menos 8 caracteres.');
      return;
    }
    if (_password.text != _confirmar.text) {
      mostrarErro(context, 'As palavras-passe não coincidem.');
      return;
    }

    setState(() => _aCriar = true);
    try {
      await UtilizadorController.registar(nome, email, _password.text);
      await DadosController.carregarTudo();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, Rotas.home, (route) => false);
    } on ApiErro catch (e) {
      if (!mounted) return;
      setState(() => _aCriar = false);
      mostrarErro(context, e.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CampoTexto(
                etiqueta: 'Nome completo',
                dica: 'Ex.: Maria Santos',
                icone: Icons.person_outline,
                controller: _nome,
              ),
              CampoTexto(
                etiqueta: 'Email',
                dica: 'nome@electrosmart.example',
                icone: Icons.mail_outline,
                controller: _email,
                teclado: TextInputType.emailAddress,
              ),
              CampoTexto(
                etiqueta: 'Palavra-passe (mínimo 8 caracteres)',
                icone: Icons.lock_outline,
                controller: _password,
                password: true,
              ),
              CampoTexto(
                etiqueta: 'Repetir palavra-passe',
                icone: Icons.lock_outline,
                controller: _confirmar,
                password: true,
              ),
              const Aviso(
                'As contas novas são de operador: podem consultar artigos e registar entradas e saídas.',
                informativo: true,
              ),
              const SizedBox(height: 16),
              BotaoPrincipal(
                texto: _aCriar ? 'A criar conta...' : 'Criar conta',
                onPressed: _aCriar ? null : _criar,
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Já tenho conta',
                      style: TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
