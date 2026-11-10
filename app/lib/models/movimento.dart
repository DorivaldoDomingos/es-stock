import 'artigo.dart';

enum TipoMovimento {
  entrada,
  saida,
  ajuste;

  String get texto {
    if (this == TipoMovimento.entrada) return 'Entrada';
    if (this == TipoMovimento.saida) return 'Saída';
    return 'Ajuste';
  }

  // valor enviado à API ('entrada', 'saida' ou 'ajuste')
  String get api => name;

  static TipoMovimento doTexto(String valor) {
    return TipoMovimento.values.firstWhere((t) => t.name == valor,
        orElse: () => TipoMovimento.ajuste);
  }
}

class Movimento {
  final String codigo;
  final String artigo;
  final TipoMovimento tipo;
  final int quantidade;
  final String utilizador;
  final int diasAtras; // 0 = hoje, 1 = ontem, ...
  final String hora;
  final String destinoOrigem;

  const Movimento({
    required this.codigo,
    required this.artigo,
    required this.tipo,
    required this.quantidade,
    required this.utilizador,
    required this.diasAtras,
    required this.hora,
    this.destinoOrigem = '',
  });

  // converte a resposta JSON da API; diasAtras conta os dias de calendário até hoje
  factory Movimento.fromJson(Map<String, dynamic> json) {
    final quando =
        DateTime.parse((json['dataHora'] as String).replaceFirst(' ', 'T'));
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dia = DateTime(quando.year, quando.month, quando.day);
    final hora = quando.hour.toString().padLeft(2, '0');
    final minuto = quando.minute.toString().padLeft(2, '0');
    return Movimento(
      codigo: json['codigo'] as String,
      artigo: json['artigo'] as String,
      tipo: TipoMovimento.doTexto(json['tipo'] as String),
      quantidade: json['quantidade'] as int,
      utilizador: json['utilizador'] as String,
      diasAtras: hoje.difference(dia).inDays,
      hora: '$hora:$minuto',
      destinoOrigem: (json['destinoOrigem'] as String?) ?? '',
    );
  }

  String get quantidadeTexto {
    if (tipo == TipoMovimento.saida) return '-$quantidade';
    if (tipo == TipoMovimento.entrada) return '+$quantidade';
    return '±$quantidade';
  }
}

// o que o utilizador escolhe na folha de filtros do histórico
class FiltroMovimentos {
  final TipoMovimento? tipo;
  final String periodo; // Hoje, 7 dias, 30 dias ou Tudo
  final String utilizador;
  final String artigo;

  const FiltroMovimentos({
    this.tipo,
    this.periodo = '7 dias',
    this.utilizador = 'Todos',
    this.artigo = '',
  });

  int get maxDias {
    if (periodo == 'Hoje') return 1;
    if (periodo == '7 dias') return 7;
    if (periodo == '30 dias') return 30;
    return 100000;
  }

  String get periodoTexto {
    if (periodo == 'Hoje') return 'Hoje';
    if (periodo == '7 dias') return 'Últimos 7 dias';
    if (periodo == '30 dias') return 'Últimos 30 dias';
    return 'Tudo';
  }
}

// dados que passam do ecrã de registo para o de confirmação
class ResultadoMovimento {
  final Artigo artigo;
  final TipoMovimento tipo;
  final int quantidade;
  final String destinoOrigem;
  final int stockDepois;

  const ResultadoMovimento({
    required this.artigo,
    required this.tipo,
    required this.quantidade,
    required this.destinoOrigem,
    required this.stockDepois,
  });
}
