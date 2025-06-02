class Transacao {
  final int? id;
  final String tipo; 
  final String categoria;
  final double valor;
  final String? descricao;
  final DateTime data;

  Transacao({
    this.id,
    required this.tipo,
    required this.categoria,
    required this.valor,
    this.descricao,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'categoria': categoria,
      'valor': valor,
      'descricao': descricao,
      'data': data.toIso8601String(),
    };
  }

  factory Transacao.fromMap(Map<String, dynamic> map) {
    return Transacao(
      id: map['id'],
      tipo: map['tipo'],
      categoria: map['categoria'],
      valor: (map['valor'] is int)
          ? (map['valor'] as int).toDouble()
          : (map['valor'] as num).toDouble(),
      descricao: map['descricao'],
      data: DateTime.tryParse(map['data']) ?? DateTime.now(),
    );
  }
}
