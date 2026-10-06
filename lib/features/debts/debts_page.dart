import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/debt_repository.dart';
import 'add_debt_page.dart';

class DebtsPage extends StatelessWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = DebtRepository(DatabaseProvider.instance);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Deudas')),
      body: StreamBuilder<List<Debt>>(
        stream: repository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar las deudas:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final debts = snapshot.data!;

          final activeDebts = debts
              .where((debt) => debt.status == 0 || debt.status == 2)
              .toList();

          final totalOriginal = activeDebts.fold<int>(
            0,
            (total, debt) => total + debt.originalAmount,
          );

          final totalRemaining = activeDebts.fold<int>(
            0,
            (total, debt) => total + debt.remainingBalance,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo pendiente total',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.60),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatCurrency(totalRemaining),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryItem(
                              label: 'Original',
                              value: _formatCurrency(totalOriginal),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SummaryItem(
                              label: 'Deudas activas',
                              value: '${activeDebts.length}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mis deudas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddDebtPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Nueva deuda',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (activeDebts.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 44,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No tienes deudas activas',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tu situación de deuda está limpia.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.60,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...activeDebts.map(
                    (debt) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _DebtCard(debt: debt, repository: repository),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddDebtPage()),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Nueva deuda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _formatCurrency(int amount) {
    final value = amount.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      final positionFromEnd = value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${amount < 0 ? '-\$' : '\$'}'
        '${buffer.toString()}';
  }
}

class _DebtCard extends StatelessWidget {
  final Debt debt;
  final DebtRepository repository;

  const _DebtCard({required this.debt, required this.repository});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final progress = debt.originalAmount <= 0
        ? 0.0
        : (debt.originalAmount - debt.remainingBalance) / debt.originalAmount;

    final safeProgress = progress.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      debt.creditor,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.60),
                      ),
                    ),
                  ],
                ),
              ),
              if (debt.status == 2)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Vencida',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Saldo pendiente',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.60),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(debt.remainingBalance),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: safeProgress, minHeight: 8),
          ),
          const SizedBox(height: 8),
          Text(
            '${(safeProgress * 100).round()}% pagado',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.60),
            ),
          ),
          const SizedBox(height: 18),
          if (debt.installmentAmount != null)
            _DebtDetail(
              label: 'Cuota',
              value: _formatCurrency(debt.installmentAmount!),
            ),
          if (debt.interestRate > 0)
            _DebtDetail(
              label: 'Interés anual',
              value: '${debt.interestRate.toStringAsFixed(2)}%',
            ),
          if (debt.nextDueDate != null)
            _DebtDetail(
              label: 'Próximo pago',
              value: _formatDate(debt.nextDueDate!),
            ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                _showPaymentDialog(context, debt, repository);
              },
              icon: const Icon(Icons.payments_outlined),
              label: const Text(
                'Registrar pago',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentDialog(
    BuildContext context,
    Debt debt,
    DebtRepository repository,
  ) async {
    final controller = TextEditingController();

    final amount = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Registrar pago'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Valor del abono',
              prefixText: '\$ ',
              hintText: 'Máximo ${_formatCurrency(debt.remainingBalance)}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final value = int.tryParse(
                  controller.text
                      .replaceAll('.', '')
                      .replaceAll(',', '')
                      .trim(),
                );

                if (value == null ||
                    value <= 0 ||
                    value > debt.remainingBalance) {
                  return;
                }

                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (amount == null || !context.mounted) {
      return;
    }

    try {
      final success = await repository.registerPrincipalPayment(
        debtId: debt.id,
        amount: amount,
      );

      if (!context.mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pago de ${_formatCurrency(amount)} registrado.'),
          ),
        );
      }
    } on Object catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar el pago: $error')),
      );
    }
  }

  static String _formatCurrency(int amount) {
    final value = amount.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      final positionFromEnd = value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${amount < 0 ? '-\$' : '\$'}'
        '${buffer.toString()}';
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}

class _DebtDetail extends StatelessWidget {
  final String label;
  final String value;

  const _DebtDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.60),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.60),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}