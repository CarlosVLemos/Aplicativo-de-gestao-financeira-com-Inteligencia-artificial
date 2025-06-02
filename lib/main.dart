import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

// Para desktop, inicializar sqflite_common_ffi
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Providers
import 'providers/transacao_provider.dart';

// Telas
import 'screens/TelaInicial.dart';
import 'screens/Dashboard.dart';
import 'screens/registro_screen.dart';
import 'screens/cotacao_screen.dart';
import 'widgets/barra_navegacao_inferior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização condicional para desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransacaoProvider()..carregarTransacoes(),
        ),
      ],
      child: MaterialApp(
        title: 'Gestor de Gastos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        initialRoute: '/',
        routes: {
          '/': (context) => const TelaInicial(),
          '/home': (context) => const BottomNavWrapper(),
          '/dashboard': (context) => const DashboardScreen(),
          '/registro': (_) => const RegistroScreen(),
          '/cotacao': (_) => const ConversorMoedaScreen(),
          // '/visualizacao': (_) => VisualizacaoScreen(id: 0), // ❌ Removido!
        },
      ),
    );
  }
}
