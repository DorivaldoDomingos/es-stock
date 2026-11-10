import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Erro devolvido pela API ou falha de ligação; a mensagem já vai pronta para o utilizador.
class ApiErro implements Exception {
  final String mensagem;
  final int? estado;

  const ApiErro(this.mensagem, [this.estado]);

  @override
  String toString() => mensagem;
}

// Faz os pedidos HTTP ao servidor (Node.js + Express). Os controllers usam esta classe
// e nunca falam diretamente com o pacote http.
class ApiService {
  static String? token;

  // Endereço indicado ao compilar: flutter run --dart-define=API_URL=http://192.168.1.20:3000
  static const String _definido = String.fromEnvironment('API_URL');
  static String? _manual;

  static String get baseUrl {
    if (_manual != null) return _manual!;
    if (_definido.isNotEmpty) return _definido;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000'; // emulador Android: 10.0.2.2 é o computador
    }
    return 'http://localhost:3000';
  }

  static const String _chaveEndereco = 'endereco_servidor';

  // lê o endereço guardado da última vez (para não o escrever sempre no telemóvel)
  static Future<void> carregarEndereco() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardado = prefs.getString(_chaveEndereco);
      if (guardado != null && guardado.isNotEmpty) _manual = guardado;
    } catch (_) {
      // sem armazenamento local: fica o endereço por omissão
    }
  }

  static Future<void> definirBase(String endereco) async {
    var e = endereco.trim();
    while (e.endsWith('/')) {
      e = e.substring(0, e.length - 1);
    }
    // aceita "192.168.1.20:3000" sem o http://
    if (e.isNotEmpty && !e.startsWith('http://') && !e.startsWith('https://')) {
      e = 'http://$e';
    }
    _manual = e.isEmpty ? null : e;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_manual == null) {
        await prefs.remove(_chaveEndereco);
      } else {
        await prefs.setString(_chaveEndereco, _manual!);
      }
    } catch (_) {
      // não foi possível guardar; o endereço vale até fechar a app
    }
  }

  static Uri _uri(String caminho, [Map<String, String>? query]) {
    final limpa = <String, String>{};
    query?.forEach((k, v) {
      if (v.isNotEmpty) limpa[k] = v;
    });
    final base = Uri.parse('$baseUrl$caminho');
    return limpa.isEmpty ? base : base.replace(queryParameters: limpa);
  }

  static Map<String, String> get _cabecalhos => {
        'Content-Type': 'application/json; charset=utf-8',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Future<dynamic> get(String caminho, {Map<String, String>? query}) {
    return _pedir(() => http.get(_uri(caminho, query), headers: _cabecalhos));
  }

  static Future<dynamic> post(String caminho, Map<String, dynamic> corpo) {
    return _pedir(() =>
        http.post(_uri(caminho), headers: _cabecalhos, body: jsonEncode(corpo)));
  }

  static Future<dynamic> put(String caminho, Map<String, dynamic> corpo) {
    return _pedir(() =>
        http.put(_uri(caminho), headers: _cabecalhos, body: jsonEncode(corpo)));
  }

  static Future<dynamic> _pedir(Future<http.Response> Function() pedido) async {
    http.Response resposta;
    try {
      resposta = await pedido().timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const ApiErro('O servidor demorou demasiado a responder.');
    } on http.ClientException {
      throw ApiErro('Não foi possível ligar ao servidor ($baseUrl). '
          'Confirme que a API está a correr.');
    }

    dynamic dados;
    if (resposta.bodyBytes.isNotEmpty) {
      try {
        dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      } on FormatException {
        dados = null;
      }
    }
    if (resposta.statusCode >= 400) {
      final mensagem = (dados is Map && dados['erro'] is String)
          ? dados['erro'] as String
          : 'Erro ${resposta.statusCode} do servidor.';
      throw ApiErro(mensagem, resposta.statusCode);
    }
    return dados;
  }
}
