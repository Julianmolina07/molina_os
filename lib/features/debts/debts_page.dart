import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/app_database.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/debt_repository.dart';
import '../../services/debt_payment_service.dart';

import 'add_debt_page.dart';

import 'package:drift/drift.dart' hide Column;

class DebtsPage extends StatelessWidget {
  final AppDatabase database;

  const DebtsPage({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    final repository = DebtRepository(database);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deudas'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDebtPage()),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Nueva deuda',
          ),
        ],
      ),
      body: StreamBuilder<List<Debt>>(
        stream: repository.watchAll(),
        builder: (context, snapshot) {
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

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final debts = snapshot.data ?? [];

          if (debts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No tienes deudas registradas.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final totalOriginal = debts.fold<int>(
            0,
            (sum, debt) => sum + debt.originalAmount,
          );

          final totalRemaining = debts.fold<int>(
            0,
            (sum, debt) => sum + debt.remainingBalance,
          );

          final totalPaid = totalOriginal - totalRemaining;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(
                totalOriginal: totalOriginal,
                totalRemaining: totalRemaining,
                totalPaid: totalPaid,
                debtCount: debts.length,
              ),
              const SizedBox(height: 16),
              ...debts.map(
                (debt) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DebtCard(
                    debt: debt,
                    database: database,
                    onPaymentRegistered: () {
                      // El StreamBuilder se actualiza automáticamente
                      // cuando cambia la base de datos.
                    },
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

class _SummaryCard extends StatelessWidget {
  final int totalOriginal;
  final int totalRemaining;
  final int totalPaid;
  final int debtCount;

  const _SummaryCard({
    required this.totalOriginal,
    required this.totalRemaining,
    required this.totalPaid,
    required this.debtCount,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$',
      decimalDigits: 0,
    );

    final progress = totalOriginal <= 0
        ? 0.0
        : (totalPaid / totalOriginal).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de deudas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Deuda total',
                    value: currency.format(totalOriginal),
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Pendiente',
                    value: currency.format(totalRemaining),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Pagado',
                    value: currency.format(totalPaid),
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Deudas',
                    value: debtCount.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: progress, minHeight: 8),
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

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final Debt debt;
  final AppDatabase database;
  final VoidCallback onPaymentRegistered;

  const _DebtCard({
    required this.debt,
    required this.database,
    required this.onPaymentRegistered,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$',
      decimalDigits: 0,
    );

    final progress = debt.originalAmount <= 0
        ? 0.0
        : ((debt.originalAmount - debt.remainingBalance) / debt.originalAmount)
              .clamp(0.0, 1.0);

    final isPaid = debt.remainingBalance == 0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showDebtDetail(context);
        },
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          debt.creditor,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  _DebtStatusChip(debt: debt),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      label: 'Saldo pendiente',
                      value: currency.format(debt.remainingBalance),
                    ),
                  ),
                  if (debt.installmentAmount != null)
                    Expanded(
                      child: _SummaryItem(
                        label: 'Cuota',
                        value: currency.format(debt.installmentAmount!),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: progress, minHeight: 7),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).round()}% pagado',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (debt.nextDueDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.event_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Próximo pago: '
                      '${DateFormat('dd/MM/yyyy').format(debt.nextDueDate!)}',
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              if (!isPaid && debt.status != 3)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      _showPaymentDialog(context);
                    },
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Registrar pago'),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _confirmDeleteDebt(context);
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Eliminar deuda'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteDebt(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar deuda'),
          content: const Text(
            'Se eliminará esta deuda junto con todos los pagos registrados '
            'y sus movimientos asociados. Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      final deleted = await DebtRepository(database).delete(debt.id);

      if (!context.mounted) {
        return;
      }

      if (!deleted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('La deuda ya no existe.')));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deuda eliminada correctamente.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la deuda: $error')),
      );
    }
  }

  void _showDebtDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return _DebtDetail(debt: debt, database: database);
      },
    );
  }

  Future<void> _showPaymentDialog(BuildContext context) async {
    final accountRepository = AccountRepository(database);

    final accounts = await accountRepository.findActivePaymentAccounts();

    if (!context.mounted) {
      return;
    }

    final selectedAccount = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _DebtPaymentDialog(
          debt: debt,
          database: database,
          accounts: accounts,
        );
      },
    );

    if (selectedAccount == true) {
      onPaymentRegistered();
    }
  }
}

class _DebtStatusChip extends StatelessWidget {
  final Debt debt;

  const _DebtStatusChip({required this.debt});

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (debt.status) {
      0 => ('Activa', Icons.schedule),
      1 => ('Pagada', Icons.check_circle_outline),
      2 => ('Vencida', Icons.warning_amber_rounded),
      3 => ('Cancelada', Icons.cancel_outlined),
      _ => ('Desconocida', Icons.help_outline),
    };

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _DebtDetail extends StatelessWidget {
  final Debt debt;
  final AppDatabase database;

  const _DebtDetail({required this.debt, required this.database});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$',
      decimalDigits: 0,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              debt.name,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(debt.creditor, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            _DetailRow(
              label: 'Monto original',
              value: currency.format(debt.originalAmount),
            ),
            _DetailRow(
              label: 'Saldo pendiente',
              value: currency.format(debt.remainingBalance),
            ),
            _DetailRow(
              label: 'Tasa de interés',
              value: '${debt.interestRate.toStringAsFixed(2)}%',
            ),
            _DetailRow(
              label: 'Fecha de inicio',
              value: DateFormat('dd/MM/yyyy').format(debt.startDate),
            ),
            if (debt.dueDate != null)
              _DetailRow(
                label: 'Fecha límite',
                value: DateFormat('dd/MM/yyyy').format(debt.dueDate!),
              ),
            if (debt.installmentAmount != null)
              _DetailRow(
                label: 'Cuota',
                value: currency.format(debt.installmentAmount!),
              ),
            if (debt.nextDueDate != null)
              _DetailRow(
                label: 'Próximo pago',
                value: DateFormat('dd/MM/yyyy').format(debt.nextDueDate!),
              ),
            if (debt.notes != null && debt.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Notas',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(debt.notes!),
            ],
            const SizedBox(height: 24),
            StreamBuilder<List<DebtPayment>>(
              stream:
                  (database.select(database.debtPayments)
                        ..where((payment) => payment.debtId.equals(debt.id))
                        ..orderBy([
                          (payment) => OrderingTerm(
                            expression: payment.date,
                            mode: OrderingMode.desc,
                          ),
                        ]))
                      .watch(),
              builder: (context, snapshot) {
                final payments = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historial de pagos',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    if (payments.isEmpty)
                      const Text('Todavía no hay pagos registrados.')
                    else
                      ...payments.map(
                        (payment) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.payments_outlined, size: 20),
                          ),
                          title: Text(currency.format(payment.totalAmount)),
                          subtitle: Text(
                            '${DateFormat('dd/MM/yyyy').format(payment.date)}\n'
                            'Capital: ${currency.format(payment.principalAmount)}'
                            '${payment.interestAmount > 0 ? '\nIntereses: ${currency.format(payment.interestAmount)}' : ''}'
                            '${payment.feeAmount > 0 ? '\nComisiones: ${currency.format(payment.feeAmount)}' : ''}',
                          ),
                          isThreeLine: true,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtPaymentDialog extends StatefulWidget {
  final Debt debt;
  final AppDatabase database;
  final List<Account> accounts;

  const _DebtPaymentDialog({
    required this.debt,
    required this.database,
    required this.accounts,
  });

  @override
  State<_DebtPaymentDialog> createState() => _DebtPaymentDialogState();
}

class _DebtPaymentDialogState extends State<_DebtPaymentDialog> {
  late final TextEditingController _totalController;
  late final TextEditingController _interestController;
  late final TextEditingController _feeController;
  late final TextEditingController _noteController;

  String? _selectedAccountId;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _totalController = TextEditingController();
    _interestController = TextEditingController(text: '0');
    _feeController = TextEditingController(text: '0');
    _noteController = TextEditingController();

    if (widget.accounts.isNotEmpty) {
      _selectedAccountId = widget.accounts.first.id;
    }

    _totalController.addListener(_refresh);
    _interestController.addListener(_refresh);
    _feeController.addListener(_refresh);
  }

  @override
  void dispose() {
    _totalController
      ..removeListener(_refresh)
      ..dispose();

    _interestController
      ..removeListener(_refresh)
      ..dispose();

    _feeController
      ..removeListener(_refresh)
      ..dispose();

    _noteController.dispose();

    super.dispose();
  }

  void _refresh() {
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });
  }

  int _parseAmount(String value) {
    final normalized = value
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll(r'$', '')
        .trim();

    return int.tryParse(normalized) ?? 0;
  }

  int get _totalAmount {
    return _parseAmount(_totalController.text);
  }

  int get _interestAmount {
    return _parseAmount(_interestController.text);
  }

  int get _feeAmount {
    return _parseAmount(_feeController.text);
  }

  int get _principalAmount {
    final principal = _totalAmount - _interestAmount - _feeAmount;

    return principal < 0 ? 0 : principal;
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _savePayment() async {
    FocusScope.of(context).unfocus();

    if (_isSaving) {
      return;
    }

    final totalAmount = _totalAmount;
    final interestAmount = _interestAmount;
    final feeAmount = _feeAmount;
    final principalAmount = _principalAmount;

    if (_selectedAccountId == null) {
      setState(() {
        _errorMessage = 'Selecciona la cuenta desde la que pagarás.';
      });
      return;
    }

    if (totalAmount <= 0) {
      setState(() {
        _errorMessage = 'El valor total del pago debe ser mayor que cero.';
      });
      return;
    }

    if (interestAmount < 0 || feeAmount < 0) {
      setState(() {
        _errorMessage = 'Intereses y comisiones no pueden ser negativos.';
      });
      return;
    }

    if (interestAmount + feeAmount > totalAmount) {
      setState(() {
        _errorMessage =
            'Intereses y comisiones no pueden superar el total del pago.';
      });
      return;
    }

    if (principalAmount <= 0) {
      setState(() {
        _errorMessage = 'El pago debe contener algún valor de capital.';
      });
      return;
    }

    if (principalAmount > widget.debt.remainingBalance) {
      setState(() {
        _errorMessage =
            'El capital calculado supera el saldo pendiente de la deuda.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final service = DebtPaymentService(widget.database);

      await service.registerPayment(
        debtId: widget.debt.id,
        accountId: _selectedAccountId!,
        totalAmount: totalAmount,
        principalAmount: principalAmount,
        interestAmount: interestAmount,
        feeAmount: feeAmount,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pago de ${_formatCurrency(totalAmount)} registrado correctamente.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage = _friendlyError(error);
      });
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();

    if (message.contains('no tiene suficiente dinero')) {
      return 'La cuenta no tiene suficiente dinero disponible para realizar este pago.';
    }

    if (message.contains('superar el saldo pendiente')) {
      return 'El capital del pago no puede superar el saldo pendiente.';
    }

    if (message.contains('cancelada')) {
      return 'No se puede pagar una deuda cancelada.';
    }

    if (message.contains('no existe')) {
      return 'La deuda o cuenta seleccionada ya no existe.';
    }

    return message
        .replaceFirst('StateError: ', '')
        .replaceFirst('ArgumentError: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalAmount;
    final interest = _interestAmount;
    final fee = _feeAmount;
    final principal = _principalAmount;

    return AlertDialog(
      title: const Text('Registrar pago'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.debt.name,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Saldo pendiente: '
              '${_formatCurrency(widget.debt.remainingBalance)}',
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _selectedAccountId,
              decoration: const InputDecoration(
                labelText: 'Cuenta de origen',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(),
              ),
              items: widget.accounts.map((account) {
                return DropdownMenuItem<String>(
                  value: account.id,
                  child: Text(account.name),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _selectedAccountId = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _totalController,
              enabled: !_isSaving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total de la cuota',
                hintText: 'Ej. 400000',
                prefixIcon: Icon(Icons.payments_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _interestController,
              enabled: !_isSaving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Intereses',
                hintText: '0',
                prefixIcon: Icon(Icons.percent),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feeController,
              enabled: !_isSaving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Comisiones',
                hintText: '0',
                prefixIcon: Icon(Icons.receipt_long_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desglose del pago',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _PaymentBreakdownRow(
                    label: 'Total',
                    value: _formatCurrency(total),
                    emphasized: true,
                  ),
                  const SizedBox(height: 6),
                  _PaymentBreakdownRow(
                    label: 'Capital',
                    value: _formatCurrency(principal),
                  ),
                  _PaymentBreakdownRow(
                    label: 'Intereses',
                    value: _formatCurrency(interest),
                  ),
                  _PaymentBreakdownRow(
                    label: 'Comisiones',
                    value: _formatCurrency(fee),
                  ),
                  const Divider(height: 20),
                  Text(
                    'La deuda disminuirá ${_formatCurrency(principal)}.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'De tu cuenta saldrán ${_formatCurrency(total)}.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              enabled: !_isSaving,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Nota (opcional)',
                hintText: 'Ej. Pago de cuota de octubre',
                prefixIcon: Icon(Icons.notes_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _savePayment,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Registrar pago'),
        ),
      ],
    );
  }
}

class _PaymentBreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _PaymentBreakdownRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? Theme.of(context).textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w700)
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}
