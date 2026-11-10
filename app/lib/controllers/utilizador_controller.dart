import '../services/api_service.dart';

// Guarda quem fez login. A autenticação é feita pelo servidor (email + palavra-passe).
class UtilizadorController {
  static String nome = '';
  static bool gestor = false;

  static Future<void> entrar(String email, String palavraPasse) async {
    final resposta = await ApiService.post('/auth/login', {
      'email': email.trim().toLowerCase(),
      'password': palavraPasse,
    }) as Map<String, dynamic>;

    final utilizador = resposta['utilizador'] as Map<String, dynamic>;
    ApiService.token = resposta['token'] as String;
    nome = utilizador['nome'] as String;
    gestor = utilizador['perfil'] == 'gestor';
  }

  // cria a conta (fica como operador) e já entra com ela
  static Future<void> registar(
      String nomeCompleto, String email, String palavraPasse) async {
    final resposta = await ApiService.post('/auth/registar', {
      'nome': nomeCompleto.trim(),
      'email': email.trim().toLowerCase(),
      'password': palavraPasse,
    }) as Map<String, dynamic>;

    final utilizador = resposta['utilizador'] as Map<String, dynamic>;
    ApiService.token = resposta['token'] as String;
    nome = utilizador['nome'] as String;
    gestor = utilizador['perfil'] == 'gestor';
  }

  static void sair() {
    ApiService.token = null;
    nome = '';
    gestor = false;
  }

  static String get primeiroNome => nome.isEmpty ? '' : nome.split(' ').first;

  static String get papel => gestor ? 'Gestor' : 'Operador';

  static String get iniciais {
    if (nome.isEmpty) return '';
    final partes = nome.split(' ');
    return partes.first[0] + partes.last[0];
  }
}
