import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentStatusPage extends StatelessWidget {
  const PaymentStatusPage({
    super.key,
    required this.payment,
    required this.onViewTickets,
    required this.onBackHome,
  });

  final Map<String, dynamic> payment;
  final VoidCallback onViewTickets;
  final VoidCallback onBackHome;

  String _formatRupiah(dynamic amount) {
    final value = int.tryParse(amount.toString()) ?? 0;
    final str = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp. ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final status = payment['status']?.toString() ?? 'SUCCESS';
    final method = payment['method']?.toString().toUpperCase() ?? '-';

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1526),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  color: Color(0x3322C55E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF22C55E),
                  size: 54,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Payment $status',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your ticket has been generated and added to Tickets.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              _buildInfoRow('Payment ID', '#${payment['id']}'),
              _buildInfoRow('Method', method),
              _buildInfoRow('Total', _formatRupiah(payment['total'])),
              if (payment['qrisPayload'] != null)
                _buildInfoRow('QRIS Ref', payment['qrisPayload'].toString()),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onViewTickets,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0BCFF),
                    foregroundColor: const Color(0xFF241B32),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.confirmation_number, size: 18),
                  label: Text(
                    'View My Tickets',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              TextButton(
                onPressed: onBackHome,
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
