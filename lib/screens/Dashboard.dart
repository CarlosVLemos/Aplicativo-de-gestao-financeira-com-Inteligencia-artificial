import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/transacao_provider.dart';
import '../widgets/kpi_card.dart';
import '../widgets/grafico_pizza.dart';
import '../widgets/grafico_linha.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final provider = context.read<TransacaoProvider>();
    await provider.carregarTransacoes();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransacaoProvider>();
    final formatador = NumberFormat.simpleCurrency(locale: 'pt_BR');

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalGanhos = provider.totalGanhos;
    final totalGastos = provider.totalGastos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Gastos'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // KPIs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                KpiCard(
                  label: 'Ganhos',
                  value: formatador.format(totalGanhos),
                  color: Colors.green,
                  icon: Icons.arrow_upward,
                ),
                KpiCard(
                  label: 'Gastos',
                  value: formatador.format(totalGastos),
                  color: Colors.red,
                  icon: Icons.arrow_downward,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Gráfico de Pizza
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Distribuição de Gastos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GraficoPizza(dados: provider.gastosPorCategoria),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Gráfico de Linha
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Evolução Financeira Mensal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: GraficoLinha(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
