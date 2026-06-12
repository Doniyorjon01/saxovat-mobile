/// Formats integer tiyin into a space-separated UZS amount.
/// 50000000 tiyin -> "500 000"
String formatUzs(int tiyin) {
  final s = (tiyin ~/ 100).toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}