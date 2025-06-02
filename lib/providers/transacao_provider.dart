import 'package:flutter/material.dart';
import '../models/transacao.dart';
import '../database/db_helper.dart';

class TransacaoProvider extends ChangeNotifier {
  final List<Transacao> _transacoes = [];
  double _totalGanhos = 0.0;
  double _totalGastos = 0.0;

  List<Transacao> get transacoes => List.unmodifiable(_transacoes);
  double get totalGanhos => _totalGanhos;
  double get totalGastos => _totalGastos;

  Map<String, double> get gastosPorCategoria {
    final Map<String, double> mapa = {};
    for (var t in _transacoes.where((t) => t.tipo == 'gasto')) {
      mapa[t.categoria] = (mapa[t.categoria] ?? 0) + t.valor;
    }
    return mapa;
  }

  Future<void> carregarTransacoes() async {
    final dados = await DBHelper.obterTransacoes();
    _transacoes
      ..clear()
      ..addAll(dados);
    _calcularTotais();
    notifyListeners();
  }

  Future<void> adicionarTransacao(Transacao transacao) async {
    await DBHelper.inserirTransacao(transacao);
    await carregarTransacoes();
  }

  Future<void> removerTransacao(int id) async {
    await DBHelper.deletarTransacao(id);
    await carregarTransacoes();
  }

  void _calcularTotais() {
    _totalGanhos = _transacoes
        .where((t) => t.tipo == 'ganho')
        .fold(0.0, (soma, t) => soma + t.valor);
    _totalGastos = _transacoes
        .where((t) => t.tipo == 'gasto')
        .fold(0.0, (soma, t) => soma + t.valor);
  }
}
