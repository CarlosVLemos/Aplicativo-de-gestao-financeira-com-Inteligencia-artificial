import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transacao_provider.dart';
import 'package:intl/intl.dart';

class GraficoLinha extends StatelessWidget {
  const GraficoLinha({super.key});

  // Função para formatar valores grandes com sufixos k, M, B
  String formatarValor(double valor) {
    if (valor >= 1e9) {
      return '${(valor / 1e9).toStringAsFixed(1)}B';
    } else if (valor >= 1e6) {
      return '${(valor / 1e6).toStringAsFixed(1)}M';
    } else if (valor >= 1e3) {
      return '${(valor / 1e3).toStringAsFixed(1)}k';
    }
    return valor.toStringAsFixed(0);
  }

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


    final mesesOrdenados = {...ganhos.keys, ...gastos.keys}.toList()
      ..sort((a, b) {
        final formato = DateFormat('MM/yyyy');
        return formato.parse(a).compareTo(formato.parse(b));
      });

    if (mesesOrdenados.isEmpty) {
      return const Center(child: Text('Nenhum dado para exibir no gráfico.'));
    }

    // Encontrar máximo valor para ajustar escala Y
    double maxValor = 0;
    for (var mes in mesesOrdenados) {
      maxValor = [
        maxValor,
        ganhos[mes] ?? 0,
        gastos[mes] ?? 0,
      ].reduce((a, b) => a > b ? a : b);
    }

    // Definir intervalo Y dinâmico baseado no máximo valor encontrado
    double intervaloY = (maxValor / 5).ceilToDouble();
    if (intervaloY == 0) intervaloY = 1;

    // Limite máximo Y para o gráfico arredondado para cima
    double maxY = intervaloY * 5;

    // Decidir se rotaciona texto dos meses para evitar sobreposição
    bool rotacionarTexto = mesesOrdenados.length > 6;

    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final altura = constraints.maxHeight > 300 ? 300.0 : constraints.maxHeight;

        return SizedBox(
          width: largura,
          height: altura,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: intervaloY,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: rotacionarTexto ? 60 : 40, // AUMENTADO
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < mesesOrdenados.length) {
                        final mes = mesesOrdenados[index];
                        final dataMes = DateFormat('MM/yyyy').parse(mes);
                        final texto = DateFormat('MMM').format(dataMes);

                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 10, // MARGEM EXTRA
                          child: rotacionarTexto
                              ? Transform.rotate(
                                  angle: -0.5,
                                  child: Text(texto, style: const TextStyle(fontSize: 10)),
                                )
                              : Text(texto, style: const TextStyle(fontSize: 12)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: intervaloY,
                      reservedSize: 50,
                      getTitlesWidget: (value, _) {
                        return Text(formatarValor(value), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(mesesOrdenados.length, (i) {
                      final mes = mesesOrdenados[i];
                      return FlSpot(i.toDouble(), ganhos[mes] ?? 0);
                    }),
                    isCurved: true,
                    color: Colors.green.shade700,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.shade700.withOpacity(0.3),
                    ),
                  ),
                  LineChartBarData(
                    spots: List.generate(mesesOrdenados.length, (i) {
                      final mes = mesesOrdenados[i];
                      return FlSpot(i.toDouble(), gastos[mes] ?? 0);
                    }),
                    isCurved: true,
                    color: Colors.red.shade700,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.shade700.withOpacity(0.3),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final mes = mesesOrdenados[spot.x.toInt()];
                        final valor = spot.y;
                        final tipo = spot.barIndex == 0 ? 'Ganhos' : 'Gastos';
                        return LineTooltipItem(
                          '$tipo\n$mes\nR\$ ${valor.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
