class Artigo {
  final int id;
  final String codigo;
  final String nome;
  final String categoria;
  final String localizacao;
  final String fornecedor;
  final int stock;
  final int stockMinimo;
  final String unidade;

  const Artigo({
    this.id = 0,
    required this.codigo,
    required this.nome,
    required this.categoria,
    required this.localizacao,
    required this.fornecedor,
    required this.stock,
    required this.stockMinimo,
    this.unidade = 'un',
  });

  // converte a resposta JSON da API
  factory Artigo.fromJson(Map<String, dynamic> json) {
    return Artigo(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      nome: json['nome'] as String,
      categoria: json['categoria'] as String,
      localizacao: json['localizacao'] as String,
      fornecedor: (json['fornecedor'] as String?) ?? '',
      stock: json['stock'] as int,
      stockMinimo: json['stockMinimo'] as int,
      unidade: (json['unidade'] as String?) ?? 'un',
    );
  }

  bool get semStock => stock <= 0;

  // stock baixo = ainda tem unidades mas está no mínimo ou abaixo
  bool get stockBaixo => stock > 0 && stock <= stockMinimo;

  bool get emAlerta => semStock || stockBaixo;
}
