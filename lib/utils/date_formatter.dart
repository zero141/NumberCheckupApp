import "package:intl/intl.dart";

String formatDate(String isoDate) {
  final date = DateTime.parse(isoDate);
  final formatter = DateFormat('dd MMM yyyy');
  return formatter.format(date);
}
