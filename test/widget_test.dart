// Smoke test dasar untuk MabarKeun.
//
// Memverifikasi widget reusable inti ter-render dengan benar.
// Sengaja memakai widget tanpa efek samping (Timer/Firebase) agar
// test deterministik dan tidak butuh inisialisasi Firebase.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mabar_slurd/src/shared/buttons/mabar_button.dart';

void main() {
  testWidgets('MabarButton menampilkan teks dan menanggapi tap', (
    WidgetTester tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MabarButton(
            text: 'Booking Sekarang',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Booking Sekarang'), findsOneWidget);

    await tester.tap(find.text('Booking Sekarang'));
    expect(tapped, isTrue);
  });
}
