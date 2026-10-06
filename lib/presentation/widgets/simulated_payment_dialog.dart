import 'package:flutter/material.dart';

enum SimulatedPaymentMethod {
  card('Tarjeta de crédito/débito', Icons.credit_card_rounded),
  mercadoPago('Mercado Pago', Icons.account_balance_wallet_rounded),
  bankTransfer('Transferencia bancaria', Icons.account_balance_rounded);

  const SimulatedPaymentMethod(this.label, this.icon);

  final String label;
  final IconData icon;
}

Future<bool> showSimulatedPaymentDialog(
  BuildContext context, {
  required String item,
  required String price,
  required Future<void> Function() onPay,
}) async =>
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _SimulatedPaymentDialog(item: item, price: price, onPay: onPay),
    ) ??
    false;

class _SimulatedPaymentDialog extends StatefulWidget {
  const _SimulatedPaymentDialog({
    required this.item,
    required this.price,
    required this.onPay,
  });

  final String item;
  final String price;
  final Future<void> Function() onPay;

  @override
  State<_SimulatedPaymentDialog> createState() =>
      _SimulatedPaymentDialogState();
}

class _SimulatedPaymentDialogState extends State<_SimulatedPaymentDialog> {
  SimulatedPaymentMethod? _selectedMethod;
  bool _isPaying = false;
  bool _paymentAccepted = false;
  String? _errorMessage;

  Future<void> _pay() async {
    final method = _selectedMethod;
    if (method == null || _isPaying) return;

    setState(() {
      _isPaying = true;
      _errorMessage = null;
    });

    try {
      await widget.onPay();
      if (!mounted) return;
      setState(() {
        _isPaying = false;
        _paymentAccepted = true;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'simulated payment',
          context: ErrorDescription('while processing a simulated payment'),
        ),
      );
      if (!mounted) return;
      setState(() {
        _isPaying = false;
        _errorMessage = 'No se pudo completar el pago. Intentá de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_isPaying && !_paymentAccepted,
      child: Dialog(
        child: LayoutBuilder(
          builder: (context, constraints) => FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: constraints.maxWidth.clamp(0, 420),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _paymentAccepted
                    ? _buildAcceptedPayment(context, colors)
                    : _buildPaymentForm(context, colors),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm(BuildContext context, ColorScheme colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_rounded, size: 36),
        const SizedBox(height: 8),
        Text(
          'Elegí un medio de pago',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(widget.item, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          widget.price,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        for (final method in SimulatedPaymentMethod.values)
          Semantics(
            inMutuallyExclusiveGroup: true,
            selected: _selectedMethod == method,
            button: true,
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(method.icon),
              title: Text(method.label),
              trailing: Icon(
                _selectedMethod == method
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: _selectedMethod == method ? colors.primary : null,
              ),
              onTap: _isPaying
                  ? null
                  : () => setState(() {
                      _selectedMethod = method;
                      _errorMessage = null;
                    }),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          'Pago de demostración: no se realiza ningún cobro real.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
        if (_errorMessage case final message?) ...[
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.error),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isPaying
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _selectedMethod == null || _isPaying ? null : _pay,
              child: _isPaying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Pagar ${widget.price}'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcceptedPayment(BuildContext context, ColorScheme colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: 56, color: colors.primary),
        const SizedBox(height: 12),
        Text(
          '¡Pago aceptado!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.item} se acreditó correctamente. '
          'El pago fue simulado y no se realizó ningún cobro.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Seguir jugando'),
        ),
      ],
    );
  }
}
