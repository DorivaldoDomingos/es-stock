import 'package:flutter/material.dart';
import 'models/artigo.dart';
import 'models/movimento.dart';
import 'views/artigo_detalhe_view.dart';
import 'views/confirmacao_view.dart';
import 'views/estatisticas_view.dart';
import 'views/home_view.dart';
import 'views/ler_qr_view.dart';
import 'views/login_view.dart';
import 'views/novo_artigo_view.dart';
import 'views/qr_artigo_view.dart';
import 'views/registo_view.dart';
import 'views/registar_movimento_view.dart';

// nomes das rotas e a função que escolhe o ecrã
class Rotas {
  static const String login = '/';
  static const String registo = '/registo';
  static const String home = '/home';
  static const String lerQr = '/ler-qr';
  static const String artigo = '/artigo';
  static const String saida = '/saida';
  static const String entrada = '/entrada';
  static const String confirmacao = '/confirmacao';
  static const String novoArtigo = '/novo-artigo';
  static const String qrArtigo = '/qr-artigo';
  static const String estatisticas = '/estatisticas';

  static Route<dynamic> gerar(RouteSettings settings) {
    final Object? args = settings.arguments;
    Widget pagina;

    switch (settings.name) {
      case login:
        pagina = const LoginView();
        break;
      case registo:
        pagina = const RegistoView();
        break;
      case home:
        pagina = const HomeView();
        break;
      case lerQr:
        pagina = const LerQrView();
        break;
      case artigo:
        pagina = ArtigoDetalheView(artigo: args as Artigo);
        break;
      case saida:
        pagina = RegistarMovimentoView(
            artigo: args as Artigo, tipo: TipoMovimento.saida);
        break;
      case entrada:
        pagina = RegistarMovimentoView(
            artigo: args as Artigo, tipo: TipoMovimento.entrada);
        break;
      case confirmacao:
        pagina = ConfirmacaoView(dados: args as ResultadoMovimento);
        break;
      case novoArtigo:
        pagina = const NovoArtigoView();
        break;
      case qrArtigo:
        pagina = QrArtigoView(artigo: args as Artigo);
        break;
      case estatisticas:
        pagina = const EstatisticasView();
        break;
      default:
        pagina = const LoginView();
    }
    return MaterialPageRoute<dynamic>(settings: settings, builder: (_) => pagina);
  }
}
