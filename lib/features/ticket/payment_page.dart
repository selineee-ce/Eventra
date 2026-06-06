import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/home/models/ticket_type.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    required this.event,
    required this.tickets,
    required this.onBack,
    required this.onPaymentComplete,
  });

  final NearbyEvent event;
  final List<TicketType> tickets;
  final VoidCallback onBack;
  final void Function(Map<String, dynamic> payment) onPaymentComplete;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  String _paymentMethod = 'qris';
  bool _isChangingMethod = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  int get subtotal => widget.tickets.fold(
    0,
    (sum, ticket) => sum + ticket.price * ticket.quantity,
  );

  int get serviceFee => (subtotal * 0.035).round();

  int get total => subtotal + serviceFee;

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp. ${buffer.toString()}';
  }

  Future<void> _submitPayment() async {
    if (_paymentMethod == 'visa' &&
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final payment = await EventraDatabase.instance.checkoutPayment(
        eventId: widget.event.id,
        paymentMethod: _paymentMethod,
        items: widget.tickets
            .map(
              (ticket) => {
                'ticketTypeId': ticket.id,
                'quantity': ticket.quantity,
              },
            )
            .toList(),
        card: _paymentMethod == 'visa'
            ? {
                'cardHolder': _cardHolderController.text.trim(),
                'cardNumber': _cardNumberController.text.trim(),
                'expiry': _expiryController.text.trim(),
                'cvv': _cvvController.text.trim(),
              }
            : null,
      );

      if (!mounted) return;
      widget.onPaymentComplete(payment);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 26, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            'Review Order',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check your details before finalizing the payment.',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 18),
          _buildOrderSummary(),
          const SizedBox(height: 24),
          _buildPaymentMethod(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF6B7A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.white70, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'SECURE CHECKOUT POWERED BY EVENTRA ENCRYPTION',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0BCFF),
                foregroundColor: const Color(0xFF241B32),
                disabledBackgroundColor: Colors.white12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: const StadiumBorder(),
              ),
              label: Text(
                _isSubmitting ? 'Processing...' : 'Confirm & Pay',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              icon: const Icon(Icons.arrow_forward, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_cart_checkout,
                color: Color(0xFFD0BCFF),
                size: 26,
              ),
              const SizedBox(width: 10),
              Text(
                'Order Summary',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.tickets.map(_buildTicketLine),
          _buildPriceLine('Subtotal', _formatRupiah(subtotal)),
          const SizedBox(height: 8),
          _buildPriceLine('Service Fee (3.5%)', _formatRupiah(serviceFee)),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD0BCFF),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatRupiah(total),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD0BCFF),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'All taxes included',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketLine(TicketType ticket) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              widget.event.image,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 54,
                height: 54,
                color: const Color(0xFF2A2035),
                child: const Icon(
                  Icons.confirmation_number,
                  color: Colors.white24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ticket.name.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD0BCFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Quantity: ${ticket.quantity}',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatRupiah(ticket.price * ticket.quantity),
            style: GoogleFonts.poppins(
              color: const Color(0xFFD0BCFF),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _isChangingMethod = !_isChangingMethod);
                },
                child: Text(
                  _isChangingMethod ? 'DONE' : 'CHANGE',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD0BCFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSelectedMethodCard(),
          if (_isChangingMethod) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildMethodButton('qris', 'QRIS', Icons.qr_code_2),
                _buildMethodButton(
                  'gopay',
                  'GoPay',
                  Icons.account_balance_wallet,
                ),
                _buildMethodButton('ovo', 'OVO', Icons.wallet),
                _buildMethodButton('visa', 'Visa', Icons.credit_card),
              ],
            ),
          ],
          if (_paymentMethod == 'qris') ...[
            const SizedBox(height: 18),
            _buildQrisBox(),
          ],
          if (_paymentMethod == 'visa') ...[
            const SizedBox(height: 18),
            _buildVisaForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildMethodButton(String value, String label, IconData icon) {
    final selected = _paymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethod = value;
          _isChangingMethod = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0x33D0BCFF) : const Color(0xFF2A2035),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFD0BCFF) : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFD0BCFF), size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMethodCard() {
    final details = switch (_paymentMethod) {
      'qris' => ('QRIS', 'Scan QR to complete payment', Icons.qr_code_2),
      'gopay' => (
        'GoPay',
        'Pay with your GoPay wallet',
        Icons.account_balance_wallet,
      ),
      'ovo' => ('OVO', 'Pay with your OVO wallet', Icons.wallet),
      'visa' => ('Visa Card', 'Enter card details below', Icons.credit_card),
      _ => ('Payment', 'Choose payment method', Icons.payments),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33D0BCFF)),
      ),
      child: Row(
        children: [
          Icon(details.$3, color: const Color(0xFFD0BCFF), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.$1,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  details.$2,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFFD0BCFF),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildQrisBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2035),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_2,
              color: Color(0xFF0E0717),
              size: 120,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Dummy QRIS for prototype checkout',
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVisaForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildInput(
            controller: _cardHolderController,
            label: 'Card Holder',
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          _buildInput(
            controller: _cardNumberController,
            label: 'Card Number',
            keyboardType: TextInputType.number,
            validator: (value) {
              final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
              if (digits.length < 13 || digits.length > 19) {
                return 'Invalid card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  controller: _expiryController,
                  label: 'MM/YY',
                  validator: (value) =>
                      RegExp(r'^\d{2}/\d{2}$').hasMatch(value ?? '')
                      ? null
                      : 'MM/YY',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInput(
                  controller: _cvvController,
                  label: 'CVV',
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      RegExp(r'^\d{3,4}$').hasMatch(value ?? '') ? null : 'CVV',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF2A2035),
        errorStyle: GoogleFonts.poppins(fontSize: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPriceLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: const Color(0xFF1B1526),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white10),
    );
  }
}
