import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:provider/provider.dart';
import '../models/transacao.dart';
import '../providers/transacao_provider.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({Key? key}) : super(key: key);

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _ganhoController = MoneyMaskedTextController(leftSymbol: 'R\$ ', decimalSeparator: ',', thousandSeparator: '.');
  final _gastoController = MoneyMaskedTextController(leftSymbol: 'R\$ ', decimalSeparator: ',', thousandSeparator: '.');

  String _origemGanho = 'salario';
  String _origemGasto = 'compras';

  final _descricaoGanhoController = TextEditingController();
  final _descricaoGastoController = TextEditingController();

  void _registrarGanho() {
  final novaTransacao = Transacao(
    tipo: 'ganho',
    categoria: _origemGanho,
    valor: _ganhoController.numberValue,
    descricao: _descricaoGanhoController.text,
    data: DateTime.now(),
  );
  Provider.of<TransacaoProvider>(context, listen: false)
      .adicionarTransacao(novaTransacao);

  _ganhoController.updateValue(0.0);
  _descricaoGanhoController.clear();
}

  void _registrarGasto() {
    print('Gasto registrado: $_origemGasto - ${_gastoController.text} - ${_descricaoGastoController.text}');
    // Banco
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Ganhos e Gastos"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCardFormulario(
              titulo: "Registrar Ganho",
              dropdownLabel: "Origem do ganho",
              dropdownValue: _origemGanho,
              dropdownItems: ['salario', 'bico', 'extra', 'outro'],
              onDropdownChanged: (val) => setState(() => _origemGanho = val!),
              valorController: _ganhoController,
              descricaoController: _descricaoGanhoController,
              onSalvar: _registrarGanho,
              labelValor: "Valor do ganho",
              labelDescricao: "Especifique o ganho (opcional)",
              icon: Icons.arrow_upward,
              color: Colors.green.shade50,
            ),
            const SizedBox(height: 24),
            _buildCardFormulario(
              titulo: "Registrar Gasto",
              dropdownLabel: "Motivo do gasto",
              dropdownValue: _origemGasto,
              dropdownItems: ['compras', 'dividas', 'emprestou', 'perdido'],
              onDropdownChanged: (val) => setState(() => _origemGasto = val!),
              valorController: _gastoController,
              descricaoController: _descricaoGastoController,
              onSalvar: _registrarGasto,
              labelValor: "Valor do gasto",
              labelDescricao: "Especifique o gasto (opcional)",
              icon: Icons.arrow_downward,
              color: Colors.red.shade50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFormulario({
    required String titulo,
    required String dropdownLabel,
    required String dropdownValue,
    required List<String> dropdownItems,
    required Function(String?) onDropdownChanged,
    required MoneyMaskedTextController valorController,
    required TextEditingController descricaoController,
    required VoidCallback onSalvar,
    required String labelValor,
    required String labelDescricao,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 8),
              Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: dropdownValue,
            decoration: InputDecoration(
              labelText: dropdownLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            items: dropdownItems
                .map((opcao) => DropdownMenuItem(value: opcao, child: Text(opcao)))
                .toList(),
            onChanged: onDropdownChanged,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: valorController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: labelValor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descricaoController,
            decoration: InputDecoration(
              labelText: labelDescricao,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.note_alt_outlined),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSalvar,
              icon: const Icon(Icons.save),
              label: const Text("Salvar"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
