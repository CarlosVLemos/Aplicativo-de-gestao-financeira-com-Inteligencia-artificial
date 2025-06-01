import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transacao_provider.dart';

class GraficoPizza extends StatefulWidget {
  const GraficoPizza({super.key});

  @override
  State<GraficoPizza> createState() => _GraficoPizzaState();
}

class _GraficoPizzaState extends State<GraficoPizza> {
  int? _indiceSelecionado;

  @override
  Widget build(BuildContext context) {
    final transacoes = context.watch<TransacaoProvider>().transacoes;

    // Filtra apenas os gastos
    final gastos = transacoes.where((t) => t.tipo == 'gasto').toList();

    final Map<String, double> gastosPorCategoria = {};
    for (var t in gastos) {
      gastosPorCategoria[t.categoria] = (gastosPorCategoria[t.categoria] ?? 0) + t.valor;
    }

    final total = gastosPorCategoria.values.fold(0.0, (a, b) => a + b);

    if (total == 0) {
      return const Center(child: Text('Sem dados suficientes.'));
    }

    final categorias = gastosPorCategoria.keys.toList();
    final valores = gastosPorCategoria.values.toList();
    final cores = [Colors.red, Colors.orange, Colors.blue, Colors.green, Colors.purple, Colors.teal];

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            setState(() {
              _indiceSelecionado = response?.touchedSection?.touchedSectionIndex;
            });
          },
        ),
        sections: List.generate(categorias.length, (i) {
          final valor = valores[i];
          final porcentagem = (valor / total) * 100;
          final selecionado = _indiceSelecionado == i;

          return PieChartSectionData(
            color: cores[i % cores.length],
            value: valor,
            title: selecionado
                ? 'R\$ ${valor.toStringAsFixed(2)}'
                : '${porcentagem.toStringAsFixed(1)}%',
            radius: selecionado ? 60 : 50,
            titleStyle: TextStyle(
              fontSize: selecionado ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
        sectionsSpace: 2,
        centerSpaceRadius: 30,
      ),
    );
  }
}
