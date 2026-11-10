class Estatistica {
  final String codigo;
  final String nome;
  final int minimoAtual;
  final double mediaSemanal;
  final double desvioPadrao;
  final int sugerido;

  const Estatistica({
    required this.codigo,
    required this.nome,
    required this.minimoAtual,
    required this.mediaSemanal,
    required this.desvioPadrao,
    required this.sugerido,
  });

  factory Estatistica.fromJson(Map<String, dynamic> json) {
    return Estatistica(
      codigo: json['codigo'] as String,
      nome: json['nome'] as String,
      minimoAtual: json['minimoAtual'] as int,
      mediaSemanal: (json['mediaSemanal'] as num).toDouble(),
      desvioPadrao: (json['desvioPadrao'] as num).toDouble(),
      sugerido: json['sugerido'] as int,
    );
  }
}
