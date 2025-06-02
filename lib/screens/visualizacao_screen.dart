import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transacao.dart';
import '../providers/transacao_provider.dart';
import 'package:intl/intl.dart';

class VisualizacaoScreen extends StatelessWidget {
  const VisualizacaoScreen({super.key});

  
  IconData _getIcon(Transacao transacao) {
    if (transacao.tipo == 'ganho') {
      switch (transacao.categoria?.toLowerCase()) {
        case 'salario':
          return Icons.attach_money; 
        case 'bico':
          return Icons.work_outline; 
        case 'extra':
          return Icons.monetization_on_outlined; 
        case 'outro':
          return Icons.payments_outlined; 
        default:
          return Icons.attach_money;
      }
    } else {
      
      switch (transacao.categoria?.toLowerCase()) {
        case 'compras':
          return Icons.shopping_cart;
        case 'dividas':
          return Icons.account_balance_wallet; 
        case 'emprestou':
          return Icons.handshake; 
        case 'perdido':
          return Icons.money_off;
        default:
          return Icons.money_off;
      }
    }
  }

  // Cor de fundo do circle avatar dependendo do tipo
  Color? _getBackgroundColor(Transacao transacao) {
    return transacao.tipo == 'ganho' ? Colors.green[100] : Colors.red[100];
  }

  // Cor do ícone dependendo do tipo
  Color _getIconColor(Transacao transacao) {
    return transacao.tipo == 'ganho' ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualização de Transações'),
        centerTitle: true,
      ),
      body: Consumer<TransacaoProvider>(
        builder: (context, provider, child) {
          final transacoes = List<Transacao>.from(provider.transacoes);
          transacoes.sort((a, b) => b.data.compareTo(a.data));

          if (transacoes.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma transação encontrada.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: transacoes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final transacao = transacoes[index];
              final formattedDate = DateFormat('dd/MM/yyyy').format(transacao.data);
              final valorFormatado = NumberFormat.currency(
                locale: 'pt_BR',
                symbol: 'R\$',
              ).format(transacao.valor);

              return Dismissible(
                key: ValueKey(transacao.id?.toString() ?? UniqueKey().toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  child: const Icon(Icons.delete_forever, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirmar exclusão'),
                      content: Text(
                        'Deseja realmente excluir a transação "${transacao.descricao ?? 'Sem descrição'}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Excluir',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) {
                  final id = transacao.id;
                  if (id != null) {
                    provider.removerTransacao(id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transação excluída com sucesso!'),
                      ),
                    );
                  }
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: _getBackgroundColor(transacao),
                      child: Icon(
                        _getIcon(transacao),
                        color: _getIconColor(transacao),
                        size: 30,
                      ),
                    ),
                    title: Text(
                      transacao.descricao ?? 'Sem descrição',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text('Data: $formattedDate'),
                    trailing: SizedBox(
                      width: 110,
                      child: Text(
                        valorFormatado,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: transacao.tipo == 'ganho' ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
