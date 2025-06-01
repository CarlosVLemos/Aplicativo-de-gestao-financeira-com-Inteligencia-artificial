import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/transacao_provider.dart';

// Telas
import 'screens/TelaInicial.dart';
import 'screens/Dashboard.dart';
import 'screens/registro_screen.dart';
import 'widgets/barra_navegacao_inferior.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransacaoProvider()..carregarTransacoes()),
      ],
      child: MaterialApp(
        title: 'Gestor de Gastos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const TelaInicial(),
          '/home': (context) => const BottomNavWrapper(),
          '/dashboard': (context) => const DashboardScreen(),
          '/registro': (_) => const RegistroScreen(),
        },
      ),
    );
  }
}
