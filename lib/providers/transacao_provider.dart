import 'package:flutter/material.dart';
import '../models/transacao.dart';
import '../database/db_helper.dart';

class TransacaoProvider extends ChangeNotifier {
  final List<Transacao> _transacoes = [];
  double _totalGanhos = 0.0;
  double _totalGastos = 0.0;

  List<Transacao> get transacoes => _transacoes;
  double get totalGanhos => _totalGanhos;
  double get totalGastos => _totalGastos;

  Future<void> carregarTransacoes() async {
    final dados = await DBHelper.obterTransacoes();
    _transacoes.clear();
    _transacoes.addAll(dados);
    _calcularTotais();
    notifyListeners();
  }

  Future<void> adicionarTransacao(Transacao transacao) async {
    await DBHelper.inserirTransacao(transacao);
    _transacoes.add(transacao);
    _calcularTotais();
    notifyListeners();
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
