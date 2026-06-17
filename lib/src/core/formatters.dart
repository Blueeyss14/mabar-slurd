/// Helper format tampilan yang dipakai lintas fitur (tanggal, jam, rupiah).
/// Dikumpulkan di sini agar tidak ada duplikasi di tiap halaman.
class Formatters {
  Formatters._();

  static const List<String> _namaBulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// Contoh: "17 Jun 2026"
  static String tanggal(DateTime date) =>
      '${date.day} ${_namaBulan[date.month - 1]} ${date.year}';

  /// Contoh: "14:06"
  static String jam(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  /// Sisipkan titik pemisah ribuan. Contoh: 1000000 -> "1.000.000"
  static String rupiah(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
