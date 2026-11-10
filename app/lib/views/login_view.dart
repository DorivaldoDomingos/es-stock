import 'package:flutter/material.dart';
import '../controllers/dados_controller.dart';
import '../controllers/utilizador_controller.dart';
import '../routes.dart';
import '../services/api_service.dart';
import 'tema/app_theme.dart';
import 'widgets/botoes.dart';
import 'widgets/campos.dart';
import 'widgets/avisos.dart';
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _ocultar = true;
  bool _aEntrar = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      mostrarErro(context, 'Indique o email e a palavra-passe.');
      return;
    }
    setState(() => _aEntrar = true);
    try {
      await UtilizadorController.entrar(_email.text, _password.text);
      await DadosController.carregarTudo();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Rotas.home);
    } on ApiErro catch (e) {
      if (!mounted) return;
      setState(() => _aEntrar = false);
      mostrarErro(context, e.mensagem);
    }
  }

  // útil num telemóvel real: o servidor está no IP do computador
  Future<void> _alterarServidor() async {
    final controller = TextEditingController(text: ApiService.baseUrl);
    final novo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Endereço do servidor'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration:
              const InputDecoration(hintText: 'http://192.168.1.20:3000'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Guardar')),
        ],
      ),
    );
    controller.dispose();
    if (novo != null) {
      await ApiService.definirBase(novo);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.lime,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.inventory_2_outlined,
                          color: AppColors.navy, size: 28),
                    ),
                    const SizedBox(height: 14),
                    const Text('ES Stock',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text('Inventário do armazém com QR Code',
                        style: TextStyle(
                            color: Color(0xFFC9D4E4), fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CampoTexto(
                etiqueta: 'Email',
                dica: 'nome@electrosmart.example',
                icone: Icons.mail_outline,
                controller: _email,
                teclado: TextInputType.emailAddress,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EtiquetaCampo('Palavra-passe'),
                    TextField(
                      controller: _password,
                      obscureText: _ocultar,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline,
                            size: 20, color: AppColors.muted),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _ocultar
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: AppColors.muted),
                          onPressed: () =>
                              setState(() => _ocultar = !_ocultar),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BotaoEscuro(
                texto: _aEntrar ? 'A entrar...' : 'Entrar',
                onPressed: _aEntrar ? null : _entrar,
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, Rotas.registo),
                  child: const Text('Criar conta',
                      style: TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => mostrarMensagem(context,
                      'Recuperação de palavra-passe: ainda não está disponível nesta versão.'),
                  child: const Text('Esqueceu-se da palavra-passe?',
                      style: TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Projeto académico · dados fictícios · ElectroSmart Solutions',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _alterarServidor,
                  child: Text('Servidor: ${ApiService.baseUrl}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
