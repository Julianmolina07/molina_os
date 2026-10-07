import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../services/financial_calculator.dart';
import '../../services/loan_payment_service.dart';

class RegisterLoanPaymentPage extends StatefulWidget {
  final Loan loan;
  final PeopleData person;

  const RegisterLoanPaymentPage({
    super.key,
    required this.loan,
    required this.person,
  });

  @override
  State<RegisterLoanPaymentPage> createState() =>
      _RegisterLoanPaymentPageState();
}

class _RegisterLoanPaymentPageState extends State<RegisterLoanPaymentPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final _accountRepository = AccountRepository(DatabaseProvider.instance);

  final _transactionRepository = TransactionRepository(
    DatabaseProvider.instance,
  );

  final _loanPaymentService = LoanPaymentService(DatabaseProvider.instance);

  String? _selectedAccountId;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _registerPayment() async {
    FocusScope.of(context).unfocus();

    if (_saving) {
      return;
    }

    final amountText = _amountController.text.trim().replaceAll('.', '');

    final amount = int.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showMessage('Escribe un valor válido mayor que cero.');
      return;
    }

    if (amount > widget.loan.remainingBalance) {
      _showMessage('El cobro no puede superar el saldo pendiente.');
      return;
    }

    if (_selectedAccountId == null) {
      _showMessage('Selecciona la cuenta donde recibiste el dinero.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _loanPaymentService.registerPayment(
        loanId: widget.loan.id,
        accountId: _selectedAccountId!,
        amount: amount,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });

      _showMessage('No se pudo registrar el cobro:\n$error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _setFullAmount() {
    _amountController.text = widget.loan.remainingBalance.toString();

    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar cobro')),
      body: StreamBuilder<List<Account>>(
        stream: _accountRepository.watchAll(),
        builder: (context, accountSnapshot) {
          if (accountSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar las cuentas.\n\n'
                  '${accountSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!accountSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = accountSnapshot.data!
              .where((account) => account.type != 2)
              .toList();

          return StreamBuilder<List<Transaction>>(
            stream: _transactionRepository.watchAll(),
            builder: (context, transactionSnapshot) {
              if (transactionSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No se pudieron cargar los movimientos.\n\n'
                      '${transactionSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (!transactionSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final transactions = transactionSnapshot.data!;

              final balances = const FinancialCalculator()
                  .calculateAccountBalances(transactions);

              final balanceByAccountId = {
                for (final balance in balances)
                  balance.accountId: balance.balance,
              };

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person_outline,
                            color: colorScheme.onPrimaryContainer,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.person.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Registrar pago del préstamo',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.60,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SALDO PENDIENTE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.60,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatCurrency(widget.loan.remainingBalance),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      '¿Cuánto pagó?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _amountController,
                      enabled: !_saving,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Valor recibido',
                        prefixText: '\$ ',
                        suffixIcon: IconButton(
                          onPressed: _saving ? null : _setFullAmount,
                          icon: const Icon(Icons.done_all_rounded),
                          tooltip: 'Cobrar todo',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _saving ? null : _setFullAmount,
                        child: const Text('Cobrar todo'),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      '¿Dónde recibiste el dinero?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (accounts.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'No tienes cuentas disponibles '
                          'para recibir este cobro.',
                          style: TextStyle(color: colorScheme.onErrorContainer),
                        ),
                      )
                    else
                      ...accounts.map((account) {
                        final balance = balanceByAccountId[account.id] ?? 0;

                        final selected = _selectedAccountId == account.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _saving
                                ? null
                                : () {
                                    setState(() {
                                      _selectedAccountId = account.id;
                                    });
                                  },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selected
                                    ? colorScheme.primaryContainer
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    selected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: selected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface.withValues(
                                            alpha: 0.50,
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          account.currency,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.60),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(balance),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 18),

                    Text(
                      'Nota',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _noteController,
                      enabled: !_saving,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText:
                            'Ej. Pago parcial, transferencia, efectivo...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: _saving || _selectedAccountId == null
                ? null
                : _registerPayment,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.payments_outlined),
            label: Text(_saving ? 'Registrando...' : 'Registrar cobro'),
          ),
        ),
      ),
    );
  }

  static String _formatCurrency(int amount) {
    final isNegative = amount < 0;
    final absoluteAmount = amount.abs();
    final value = absoluteAmount.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      final positionFromEnd = value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${isNegative ? '-\$' : '\$'}${buffer.toString()}';
  }
}
