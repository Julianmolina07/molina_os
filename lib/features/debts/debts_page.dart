import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/debt_repository.dart';
import '../../services/debt_payment_service.dart';
import 'add_debt_page.dart';

class DebtsPage extends StatelessWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final database = DatabaseProvider.instance;
    final repository = DebtRepository(database);

    return Scaffold(
      appBar: AppBar(title: const Text('Deudas')),
      body: StreamBuilder<List<Debt>>(
        stream: repository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar las deudas.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final debts = snapshot.data ?? <Debt>[];

          final activeDebts = debts.where((debt) => debt.status == 0).toList();

          final overdueDebts = debts.where((debt) => debt.status == 2).toList();

          final totalRemaining = debts.fold<int>(
            0,
            (sum, debt) => sum + debt.remainingBalance,
          );

          final totalOriginal = debts.fold<int>(
            0,
            (sum, debt) => sum + debt.originalAmount,
          );

          final totalPaid = totalOriginal - totalRemaining;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DebtSummaryCard(
                totalRemaining: totalRemaining,
                totalOriginal: totalOriginal,
                totalPaid: totalPaid,
                activeCount: activeDebts.length,
                overdueCount: overdueDebts.length,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Mis deudas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddDebtPage()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva deuda'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (debts.isEmpty)
                const _EmptyDebtsState()
              else
                ...debts.map(
                  (debt) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DebtCard(
                      debt: debt,
                      paymentService: DebtPaymentService(database),
                      accountRepository: AccountRepository(database),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DebtSummaryCard extends StatelessWidget {
  final int totalRemaining;
  final int totalOriginal;
  final int totalPaid;
  final int activeCount;
  final int overdueCount;

  const _DebtSummaryCard({
    required this.totalRemaining,
    required this.totalOriginal,
    required this.totalPaid,
    required this.activeCount,
    required this.overdueCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalOriginal > 0
        ? (totalPaid / totalOriginal).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deuda pendiente',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              _formatCurrency(totalRemaining),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: progress, minHeight: 8),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% pagado',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Deudas activas',
                    value: '$activeCount',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Vencidas',
                    value: '$overdueCount',
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Pagado',
                    value: _formatCompactCurrency(totalPaid),
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DebtCard extends StatelessWidget {
  final Debt debt;
  final DebtPaymentService paymentService;
  final AccountRepository accountRepository;

  const _DebtCard({
    required this.debt,
    required this.paymentService,
    required this.accountRepository,
  });

  @override
  Widget build(BuildContext context) {
    final progress = debt.originalAmount > 0
        ? ((debt.originalAmount - debt.remainingBalance) / debt.originalAmount)
              .clamp(0.0, 1.0)
        : 0.0;

    final isPaid = debt.status == 1;
    final isOverdue = debt.status == 2;
    final isCancelled = debt.status == 3;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        debt.creditor,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _DebtStatusChip(status: debt.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DebtDetail(
                    label: 'Saldo pendiente',
                    value: _formatCurrency(debt.remainingBalance),
                  ),
                ),
                Expanded(
                  child: _DebtDetail(
                    label: 'Original',
                    value: _formatCurrency(debt.originalAmount),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: progress, minHeight: 7),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% pagado',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (debt.nextDueDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Próximo vencimiento: '
                    '${_formatDate(debt.nextDueDate!)}',
                  ),
                ],
              ),
            ],
            if (debt.installmentAmount != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Cuota: '
                    '${_formatCurrency(debt.installmentAmount!)}',
                  ),
                ],
              ),
            ],
            if (debt.notes != null && debt.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(debt.notes!, style: const TextStyle(color: Colors.grey)),
            ],
            if (!isPaid && !isCancelled) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showPaymentDialog(
                    context,
                    debt,
                    accountRepository,
                    paymentService,
                  ),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Registrar pago'),
                ),
              ),
            ],
            if (isOverdue) ...[
              const SizedBox(height: 8),
              const Text(
                'Esta deuda está vencida.',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DebtStatusChip extends StatelessWidget {
  final int status;

  const _DebtStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;

    switch (status) {
      case 1:
        label = 'Pagada';
        icon = Icons.check_circle_outline;
      case 2:
        label = 'Vencida';
        icon = Icons.warning_amber_rounded;
      case 3:
        label = 'Cancelada';
        icon = Icons.cancel_outlined;
      default:
        label = 'Activa';
        icon = Icons.schedule;
    }

    return Chip(avatar: Icon(icon, size: 17), label: Text(label));
  }
}

class _DebtDetail extends StatelessWidget {
  final String label;
  final String value;

  const _DebtDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _EmptyDebtsState extends StatelessWidget {
  const _EmptyDebtsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.account_balance_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No tienes deudas registradas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega una deuda para comenzar a controlar '
            'tus obligaciones financieras.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _PaymentData {
  final String accountId;
  final int amount;

  const _PaymentData({required this.accountId, required this.amount});
}

class _DebtPaymentDialog extends StatefulWidget {
  final Debt debt;
  final List<Account> accounts;

  const _DebtPaymentDialog({required this.debt, required this.accounts});

  @override
  State<_DebtPaymentDialog> createState() => _DebtPaymentDialogState();
}

class _DebtPaymentDialogState extends State<_DebtPaymentDialog> {
  late final TextEditingController _amountController;

  late String _selectedAccountId;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();

    _selectedAccountId = widget.accounts.first.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(
      _amountController.text.replaceAll('.', '').replaceAll(',', '').trim(),
    );

    if (value == null || value <= 0) {
      setState(() {
        _errorMessage = 'Ingresa un valor de pago válido.';
      });
      return;
    }

    if (value > widget.debt.remainingBalance) {
      setState(() {
        _errorMessage =
            'El pago no puede superar el saldo pendiente '
            'de la deuda.';
      });
      return;
    }

    Navigator.of(context)
        .pop(_PaymentData(accountId: _selectedAccountId, amount: value));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar pago'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.debt.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedAccountId,
              decoration: const InputDecoration(
                labelText: 'Cuenta de origen',
                prefixIcon: Icon(Icons.account_balance_outlined),
              ),
              items: widget.accounts.map((account) {
                return DropdownMenuItem<String>(
                  value: account.id,
                  child: Text(account.name, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedAccountId = value;
                  _errorMessage = null;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Valor del abono',
                prefixText: '\$ ',
                hintText:
                    'Máximo ${_formatCurrency(widget.debt.remainingBalance)}',
                errorText: _errorMessage,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Continuar')),
      ],
    );
  }
}

Future<void> _showPaymentDialog(
  BuildContext context,
  Debt debt,
  AccountRepository accountRepository,
  DebtPaymentService paymentService,
) async {
  final accounts = await accountRepository.watchAll().first;

  if (!context.mounted) {
    return;
  }

  // Las tarjetas de crédito no se utilizan como fuente
  // para pagar otra deuda.
  final paymentAccounts = accounts
      .where((account) => account.type != 2)
      .toList();

  if (paymentAccounts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Primero necesitas una cuenta bancaria, '
          'billetera digital o efectivo para realizar '
          'el pago.',
        ),
      ),
    );
    return;
  }

  final paymentData = await showDialog<_PaymentData>(
    context: context,
    builder: (_) {
      return _DebtPaymentDialog(debt: debt, accounts: paymentAccounts);
    },
  );

  if (paymentData == null || !context.mounted) {
    return;
  }

  try {
    await paymentService.registerPrincipalPayment(
      debtId: debt.id,
      accountId: paymentData.accountId,
      amount: paymentData.amount,
      date: DateTime.now(),
      note: 'Pago de deuda: ${debt.name}',
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pago de ${_formatCurrency(paymentData.amount)} '
          'registrado correctamente.',
        ),
      ),
    );
  } on Object catch (error) {
    if (!context.mounted) {
      return;
    }

    final message = error is StateError
        ? error.message
        : 'No se pudo registrar el pago.';

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message.toString())));
  }
}

String _formatCurrency(int value) {
  final text = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write('.');
    }

    buffer.write(text[i]);
  }

  final formatted = buffer.toString();

  return value < 0 ? '-\$ $formatted' : '\$ $formatted';
}

String _formatCompactCurrency(int value) {
  if (value >= 1000000) {
    return '\$ ${(value / 1000000).toStringAsFixed(1)} M';
  }

  if (value >= 1000) {
    return '\$ ${(value / 1000).toStringAsFixed(0)} K';
  }

  return _formatCurrency(value);
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day/$month/$year';
}
