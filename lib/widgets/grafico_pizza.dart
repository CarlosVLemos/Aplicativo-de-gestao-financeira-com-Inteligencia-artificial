import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficoPizza extends StatefulWidget {
  final Map<String, double> dados;

  const GraficoPizza({super.key, required this.dados});

  @override
  State<GraficoPizza> createState() => _GraficoPizzaState();
}

class _GraficoPizzaState extends State<GraficoPizza> {
  int? _indiceSelecionado;
  final ScrollController _scrollController = ScrollController();

  final List<Color> cores = [
    Colors.red.shade400,
    Colors.orange.shade400,
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.purple.shade400,
    Colors.teal.shade400,
    Colors.brown.shade400,
    Colors.cyan.shade400,
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dados = widget.dados;
    final total = dados.values.fold(0.0, (a, b) => a + b);

    if (total == 0) {
      return const Center(child: Text('Sem dados suficientes para exibir o gráfico.'));
    }

    final categorias = dados.keys.toList();
    final valores = dados.values.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = constraints.maxWidth * 0.8;
        final size = maxSize > 300 ? 300.0 : maxSize;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: PieChart(
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
                        fontSize: selecionado ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      titlePositionPercentageOffset: 0.6,
                    );
                  }),
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 60,
              width: double.infinity,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,  // mostra sempre a barra do scroll
                trackVisibility: true,  // mostra o "trilho" da barra
                thickness: 6,
                radius: const Radius.circular(10),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(categorias.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: LegendItem(
                          color: cores[i % cores.length],
                          text: categorias[i],
                          isSelected: _indiceSelecionado == i,
                          onTap: () {
                            setState(() {
                              _indiceSelecionado = _indiceSelecionado == i ? null : i;
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const LegendItem({
    super.key,
    required this.color,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSelected ? 20 : 16,
            height: isSelected ? 20 : 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.6),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: isSelected ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
