import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transacao_provider.dart';
import 'package:intl/intl.dart';

class GraficoLinha extends StatelessWidget {
  const GraficoLinha({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransacaoProvider>();
    final transacoes = provider.transacoes;

    final Map<String, double> ganhos = {};
    final Map<String, double> gastos = {};

    final formatter = DateFormat('MM/yyyy');

    // Agrupar os dados por mês/ano
    for (var transacao in transacoes) {
      final mesAno = formatter.format(transacao.data);
      if (transacao.tipo == 'ganho') {
        ganhos[mesAno] = (ganhos[mesAno] ?? 0) + transacao.valor;
      } else {
        gastos[mesAno] = (gastos[mesAno] ?? 0) + transacao.valor;
      }
    }

    // Garantir a ordem cronológica dos meses
    final mesesOrdenados = {...ganhos.keys, ...gastos.keys}.toList()
      ..sort((a, b) {
        final formato = DateFormat('MM/yyyy');
        return formato.parse(a).compareTo(formato.parse(b));
      });

    return mesesOrdenados.isEmpty
        ? const Center(child: Text('Nenhum dado para exibir no gráfico.'))
        : LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text('Meses'),
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      int index = value.toInt();
                      if (index < mesesOrdenados.length) {
                        final mes = mesesOrdenados[index];
                        final abreviado = DateFormat('MMM').format(
                          DateFormat('MM/yyyy').parse(mes),
                        );
                        return Text(abreviado, style: const TextStyle(fontSize: 10));
                      }
                      return const Text('');
                    },
                    reservedSize: 32,
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Text('Valor'),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 500,
                  ),
                ),
              ),
              minY: 0,
              gridData: FlGridData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(mesesOrdenados.length, (i) {
                    final mes = mesesOrdenados[i];
                    return FlSpot(i.toDouble(), ganhos[mes] ?? 0);
                  }),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: List.generate(mesesOrdenados.length, (i) {
                    final mes = mesesOrdenados[i];
                    return FlSpot(i.toDouble(), gastos[mes] ?? 0);
                  }),
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          );
  }
}
