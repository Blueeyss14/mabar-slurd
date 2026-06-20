import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  int _selected = 0;

  static const List<Map<String, dynamic>> _methods = [
    {'icon': Icons.payments_outlined, 'name': 'Bayar di Tempat', 'info': 'Tunai saat datang ke warnet'},
    {'icon': Icons.account_balance_wallet, 'name': 'GoPay', 'info': 'E-wallet'},
    {'icon': Icons.account_balance_wallet_outlined, 'name': 'OVO', 'info': 'E-wallet'},
    {'icon': Icons.qr_code, 'name': 'QRIS', 'info': 'Scan untuk bayar'},
    {'icon': Icons.credit_card, 'name': 'Kartu Kredit/Debit', 'info': 'Visa / Mastercard'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferred();
  }

  Future<void> _loadPreferred() async {
    final saved = await FirestoreService.getPreferredPayment();
    if (!mounted || saved == null) return;
    final idx = _methods.indexWhere((m) => m['name'] == saved);
    if (idx >= 0) setState(() => _selected = idx);
  }

  Future<void> _selectMethod(int index) async {
    setState(() => _selected = index);
    final name = _methods[index]['name'] as String;
    await FirestoreService.savePreferredPayment(name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name disimpan sebagai metode favorit.',
            style: const TextStyle(color: CustomColors.mabarTextPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: CustomColors.mabarPurpleBg,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Metode Pembayaran",
          style: TextStyle(
            color: CustomColors.mabarTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CustomColors.mabarBorderFocus.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: CustomColors.mabarBorderFocus),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pilih metode favoritmu. Metode pembayaran final dipilih '
                    'saat checkout booking.',
                    style: TextStyle(
                      fontSize: 12,
                      color: CustomColors.mabarTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _methods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _methods[index];
          final bool isActive = _selected == index;
          return GestureDetector(
            onTap: () => _selectMethod(index),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomColors.mabarSurfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? CustomColors.mabarBorderFocus
                      : CustomColors.mabarBorderSubtle,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColors.mabarPurpleBg,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: CustomColors.mabarPurpleLight,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.mabarTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['info'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: CustomColors.mabarTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isActive
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isActive
                        ? CustomColors.mabarPurpleLight
                        : CustomColors.mabarTextTertiary,
                  ),
                ],
              ),
            ),
          );
        },
            ),
          ),
        ],
      ),
    );
  }
}
