import 'package:flutter/material.dart';
import 'package:gestor_gastos/screens/visualizacao_screen.dart';
import '../screens/Dashboard.dart';
import '../screens/registro_screen.dart';
import '../screens/cotacao_screen.dart';

class BottomNavWrapper extends StatefulWidget {
  const BottomNavWrapper({super.key});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _paginaAtual = 0;

  final List<Widget> _telasPrincipais = const [
    DashboardScreen(),
    RegistroScreen(),
    ConversorMoedaScreen(),
    VisualizacaoScreen(),  // aqui sem passar id
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telasPrincipais[_paginaAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _paginaAtual = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Registrar'),
          BottomNavigationBarItem(icon: Icon(Icons.currency_exchange), label: 'Cotação'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Visualizar'),
        ],
      ),
    );
  }
}
