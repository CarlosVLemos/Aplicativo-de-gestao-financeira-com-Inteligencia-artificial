import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class ConversorMoedaScreen extends StatefulWidget {
  const ConversorMoedaScreen({Key? key}) : super(key: key);

  @override
  State<ConversorMoedaScreen> createState() => _ConversorMoedaScreenState();
}

class _ConversorMoedaScreenState extends State<ConversorMoedaScreen> {
  final _realController = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      thousandSeparator: '.');

  double? _valorDolar;
  double? _valorEuro;
  bool _carregando = false;
  String? _erro;

  Future<void> _converter() async {
    setState(() {
      _carregando = true;
      _erro = null;
      _valorDolar = null;
      _valorEuro = null;
    });

    final valorReal = _realController.numberValue;

    if (valorReal <= 0) {
      setState(() {
        _erro = 'Informe um valor maior que zero.';
        _carregando = false;
      });
      return;
    }

    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/BRL');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'];

        final dolar = rates['USD'] as double;
        final euro = rates['EUR'] as double;

        setState(() {
          _valorDolar = valorReal * dolar;
          _valorEuro = valorReal * euro;
          _carregando = false;
        });
      } else {
        setState(() {
          _erro = 'Erro ao buscar taxas de câmbio.';
          _carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        _erro = 'Erro de conexão: $e';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Real para Dólar e Euro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _realController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor em Real (R\$)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregando ? null : _converter,
              child: _carregando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Converter'),
            ),
            const SizedBox(height: 24),
            if (_erro != null)
              Text(
                _erro!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_valorDolar != null && _valorEuro != null)
              Column(
                children: [
                  Text(
                    'Dólar (USD): \$${_valorDolar!.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Euro (EUR): €${_valorEuro!.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
