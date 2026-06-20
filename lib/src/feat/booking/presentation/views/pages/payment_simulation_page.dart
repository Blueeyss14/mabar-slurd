import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/core/formatters.dart';
import 'package:mabar_slurd/src/feat/common/presentation/views/main_shell.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';

class PaymentSimulationPage extends StatefulWidget {
  final String bookingId;
  final int amount;
  final String paymentMethod;
  final String venueName;

  const PaymentSimulationPage({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.venueName,
  });

  @override
  State<PaymentSimulationPage> createState() => _PaymentSimulationPageState();
}

enum _PayState { waiting, processing, success }

class _PaymentSimulationPageState extends State<PaymentSimulationPage>
    with SingleTickerProviderStateMixin {
  _PayState _payState = _PayState.waiting;
  late AnimationController _checkAnim;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScale = CurvedAnimation(parent: _checkAnim, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _checkAnim.dispose();
    super.dispose();
  }

  IconData get _methodIcon {
    switch (widget.paymentMethod) {
      case 'GoPay':
        return Icons.account_balance_wallet;
      case 'OVO':
        return Icons.account_balance_wallet_outlined;
      case 'QRIS':
        return Icons.qr_code_2_rounded;
      case 'Kartu Kredit/Debit':
        return Icons.credit_card;
      default:
        return Icons.payments_outlined;
    }
  }

  Color get _methodColor {
    switch (widget.paymentMethod) {
      case 'GoPay':
        return const Color(0xFF00AED6);
      case 'OVO':
        return const Color(0xFF4C3494);
      case 'QRIS':
        return CustomColors.mabarCyan;
      case 'Kartu Kredit/Debit':
        return const Color(0xFFFF6B35);
      default:
        return CustomColors.mabarBorderFocus;
    }
  }

  Future<void> _confirmPayment() async {
    setState(() => _payState = _PayState.processing);
    await Future.delayed(const Duration(milliseconds: 1800));
    try {
      await FirestoreService.markPaymentPaid(widget.bookingId);
    } catch (_) {}
    if (!mounted) return;
    setState(() => _payState = _PayState.success);
    _checkAnim.forward();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Get.offAll(() => const MainShell(initialIndex: 1));
  }

  @override
  Widget build(BuildContext context) {
    switch (_payState) {
      case _PayState.processing:
        return _buildProcessing();
      case _PayState.success:
        return _buildSuccess();
      case _PayState.waiting:
        return _buildWaiting();
    }
  }

  // ─── State: Waiting ──────────────────────────────────────────────────────

  Widget _buildWaiting() {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: CustomColors.mabarTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.offAll(() => const MainShell(initialIndex: 1)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountCard(),
            const SizedBox(height: 20),
            _buildMethodCard(),
            const SizedBox(height: 16),
            _buildStatusBadge(),
            const SizedBox(height: 32),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomColors.mabarBorderFocus,
            CustomColors.mabarBorderFocus.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CustomColors.mabarBorderFocus.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${Formatters.rupiah(widget.amount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.venueName,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _methodColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_methodIcon, color: _methodColor, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      color: CustomColors.mabarTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    widget.paymentMethod,
                    style: const TextStyle(
                      color: CustomColors.mabarTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: CustomColors.mabarBorderSubtle),
          const SizedBox(height: 16),
          const Text(
            'Cara Pembayaran',
            style: TextStyle(
              color: CustomColors.mabarTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildSteps(),
        ],
      ),
    );
  }

  List<Widget> _buildSteps() {
    final steps = _instructionSteps();
    return steps.asMap().entries.map((e) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _methodColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${e.key + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                e.value,
                style: const TextStyle(
                  color: CustomColors.mabarTextSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<String> _instructionSteps() {
    final amount = 'Rp ${Formatters.rupiah(widget.amount)}';
    switch (widget.paymentMethod) {
      case 'GoPay':
        return [
          'Buka aplikasi Gojek di smartphone kamu',
          'Pilih GoPay → Transfer ke merchant',
          'Masukkan nominal $amount',
          'Konfirmasi dengan PIN GoPay kamu',
          'Kembali ke sini lalu tekan Konfirmasi Pembayaran',
        ];
      case 'OVO':
        return [
          'Buka aplikasi OVO di smartphone kamu',
          'Pilih Transfer → ke nomor merchant',
          'Masukkan nominal $amount',
          'Konfirmasi dengan PIN OVO kamu',
          'Kembali ke sini lalu tekan Konfirmasi Pembayaran',
        ];
      case 'QRIS':
        return [
          'Buka aplikasi e-wallet atau m-banking kamu',
          'Pilih menu Scan QR / QRIS',
          'Scan kode QR yang ditampilkan kasir warnet',
          'Pastikan nominal sesuai: $amount',
          'Tekan Konfirmasi Pembayaran setelah transfer berhasil',
        ];
      case 'Kartu Kredit/Debit':
        return [
          'Siapkan kartu Kredit atau Debit kamu',
          'Informasikan ke kasir warnet untuk diproses',
          'Konfirmasi transaksi sebesar $amount',
          'Tanda tangani struk atau masukkan PIN',
          'Tekan Konfirmasi Pembayaran setelah selesai',
        ];
      default:
        return ['Selesaikan pembayaran sesuai metode yang dipilih'];
    }
  }

  Widget _buildStatusBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_outlined, color: Colors.orange, size: 16),
          SizedBox(width: 8),
          Text(
            'Menunggu Pembayaran',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _methodColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: _confirmPayment,
        child: const Text(
          'Konfirmasi Pembayaran',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ─── State: Processing ───────────────────────────────────────────────────

  Widget _buildProcessing() {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                color: _methodColor,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Memproses Pembayaran...',
              style: TextStyle(
                color: CustomColors.mabarTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mohon tunggu sebentar',
              style: TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── State: Success ──────────────────────────────────────────────────────

  Widget _buildSuccess() {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _checkScale,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CustomColors.mabarGreen.withValues(alpha: 0.15),
                  border: Border.all(
                    color: CustomColors.mabarGreen.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 64,
                  color: CustomColors.mabarGreen,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(
                color: CustomColors.mabarTextPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Booking kamu sudah dikonfirmasi.',
              style: TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mengarahkan ke Riwayat...',
              style: TextStyle(
                color: CustomColors.mabarTextTertiary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
