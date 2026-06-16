import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/features/home/models/nearby_event.dart';
import 'package:eventra/features/home/models/ticket_type.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _transferProof;
  bool _isPickingProof = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  int get subtotal => widget.tickets.fold(
    0,
    (sum, ticket) => sum + ticket.price * ticket.quantity,
  );

  int get serviceFee => (subtotal * 0.035).round();

  int get total => subtotal + serviceFee;

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp. ${buffer.toString()}';
  }

  Future<void> _pickTransferProof() async {
    if (_isPickingProof) return;

    setState(() {
      _isPickingProof = true;
      _errorMessage = null;
    });

    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (!mounted || picked == null) return;
      setState(() => _transferProof = picked);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to upload transfer proof. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isPickingProof = false);
    }
  }

  Future<void> _checkStatus() async {
    if (_transferProof == null) {
      setState(() {
        _errorMessage = 'Please upload your transfer proof first.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final payment = await EventraDatabase.instance.checkoutPayment(
        eventId: widget.event.id,
        paymentMethod: 'manual_transfer',
        items: widget.tickets
            .map(
              (ticket) => {
                'ticketTypeId': ticket.id,
                'quantity': ticket.quantity,
              },
            )
            .toList(),
        proof: {'fileName': _transferProof!.name, 'status': 'uploaded'},
      );

      if (!mounted) return;
      widget.onPaymentComplete(payment);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
            'Manual Payment',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Transfer to the Eventra BCA account, then upload your proof.',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 18),
          _buildOrderSummary(),
          const SizedBox(height: 24),
          _buildBankTransferPanel(),
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
              const Icon(Icons.verified_user, color: Colors.white70, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'DUMMY VERIFICATION: CHECK STATUS WILL AUTO APPROVE',
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
              onPressed: _isSubmitting ? null : _checkStatus,
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
                _isSubmitting ? 'Checking...' : 'Check Status',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              icon: const Icon(Icons.fact_check_outlined, size: 18),
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
          _buildPriceLine('Total', _formatRupiah(total), highlight: true),
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

  Widget _buildBankTransferPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Transfer',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2035),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x33D0BCFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBankRow('Bank', 'BCA'),
                _buildBankRow('Account Name', 'Edwin Winarto'),
                _buildBankRow('Account Number', '8085413291'),
                _buildBankRow('Amount', _formatRupiah(total)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isPickingProof ? null : _pickTransferProof,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD0BCFF),
              side: const BorderSide(color: Color(0x66D0BCFF)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(
              _transferProof == null
                  ? Icons.upload_file
                  : Icons.check_circle_outline,
              size: 18,
            ),
            label: Text(
              _isPickingProof
                  ? 'Uploading...'
                  : _transferProof == null
                  ? 'Upload Transfer Proof'
                  : _transferProof!.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLine(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: highlight ? const Color(0xFFD0BCFF) : Colors.white70,
            fontSize: highlight ? 20 : 13,
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: highlight ? const Color(0xFFD0BCFF) : Colors.white,
            fontSize: highlight ? 20 : 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: const Color(0xFF1B1526),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white10),
    );
  }
}
