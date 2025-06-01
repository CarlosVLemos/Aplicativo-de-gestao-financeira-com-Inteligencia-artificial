import 'package:flutter/material.dart';
import '../screens/Dashboard.dart';
import '../screens/registro_screen.dart';
// import '../screens/visualizacao_screen.dart';
// import '../screens/cotacao_screen.dart';

class BottomNavWrapper extends StatefulWidget {
  const BottomNavWrapper({super.key});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _paginaAtual = 0;

  final List<Widget> _telas = const [
    DashboardScreen(),
    RegistroScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _paginaAtual,
        children: _telas,
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Visualizar'),
          BottomNavigationBarItem(icon: Icon(Icons.currency_exchange), label: 'Cotação'),
        ],
      ),
    );
  }
}
