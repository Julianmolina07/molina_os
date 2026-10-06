import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../models/transaction.dart' as transaction_model;

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionRepository =
        TransactionRepository(DatabaseProvider.instance);

    final accountRepository =
        AccountRepository(DatabaseProvider.instance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: transactionRepository.watchAll(),
        builder: (context, transactionSnapshot) {
          if (transactionSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar los movimientos:\n'
                  '${transactionSnapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }

          if (!transactionSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final transactions = transactionSnapshot.data!;

          if (transactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 56,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay movimientos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Los ingresos, gastos y transferencias '
                      'que registres aparecerán aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return StreamBuilder<List<Account>>(
            stream: accountRepository.watchAll(),
            builder: (context, accountSnapshot) {
              if (accountSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error al cargar las cuentas:\n'
                      '${accountSnapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }

              if (!accountSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final accounts = accountSnapshot.data!;

              final accountNames = {
                for (final account in accounts) account.id: account.name,
              };

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                itemCount: transactions.length,
                separatorBuilder: (_, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];

                  final type =
                      transaction_model.TransactionType.values[
                          transaction.type];

                  final accountName =
                      accountNames[transaction.accountId] ??
                          'Cuenta desconocida';

                  final destinationAccountName =
                      transaction.destinationAccountId == null
                          ? null
                          : accountNames[
                              transaction.destinationAccountId!];

                  return _TransactionCard(
                    transaction: transaction,
                    accountName: accountName,
                    destinationAccountName:
                        destinationAccountName,
                    type: type,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String accountName;
  final String? destinationAccountName;
  final transaction_model.TransactionType type;

  const _TransactionCard({
    required this.transaction,
    required this.accountName,
    required this.destinationAccountName,
    required this.type,
  });

  String _categoryName(
    transaction_model.TransactionCategory category,
  ) {
    switch (category) {
      case transaction_model.TransactionCategory.food:
        return 'Alimentación';
      case transaction_model.TransactionCategory.gasoline:
        return 'Gasolina';
      case transaction_model.TransactionCategory.entertainment:
        return 'Entretenimiento';
      case transaction_model.TransactionCategory.outing:
        return 'Salida';
      case transaction_model.TransactionCategory.travel:
        return 'Viaje';
      case transaction_model.TransactionCategory.vehicle:
        return 'Vehículo';
      case transaction_model.TransactionCategory.bills:
        return 'Facturas';
      case transaction_model.TransactionCategory.shopping:
        return 'Compras';
      case transaction_model.TransactionCategory.health:
        return 'Salud';
      case transaction_model.TransactionCategory.education:
        return 'Educación';
      case transaction_model.TransactionCategory.family:
        return 'Familia';
      case transaction_model.TransactionCategory.work:
        return 'Trabajo';
      case transaction_model.TransactionCategory.debt:
        return 'Deuda';
      case transaction_model.TransactionCategory.other:
        return 'Otro';
    }
  }

  String _formatAmount(int amount) {
    final value = amount.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      final positionFromEnd = value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '\$${buffer.toString()}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isIncome =
        type == transaction_model.TransactionType.income;

    final isTransfer =
        type == transaction_model.TransactionType.transfer;

    final category =
        transaction_model.TransactionCategory.values[
            transaction.category];

    final String title;

    if (isTransfer) {
      title = 'Transferencia';
    } else if (isIncome) {
      title = 'Ingreso';
    } else {
      title = 'Gasto';
    }

    final String subtitle;

    if (isTransfer) {
      subtitle = destinationAccountName == null
          ? accountName
          : '$accountName → $destinationAccountName';
    } else {
      subtitle =
          '${_categoryName(category)} · $accountName';
    }

    final Color iconColor;

    if (isTransfer) {
      iconColor = colorScheme.secondary;
    } else if (isIncome) {
      iconColor = Colors.green;
    } else {
      iconColor = Colors.red;
    }

    final IconData icon;

    if (isTransfer) {
      icon = Icons.swap_horiz_rounded;
    } else if (isIncome) {
      icon = Icons.arrow_downward_rounded;
    } else {
      icon = Icons.arrow_upward_rounded;
    }

    final String amountPrefix;

    if (isTransfer) {
      amountPrefix = '';
    } else if (isIncome) {
      amountPrefix = '+';
    } else {
      amountPrefix = '-';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface
                        .withValues(alpha: 0.70),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.date),
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface
                        .withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$amountPrefix${_formatAmount(transaction.amount)}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}