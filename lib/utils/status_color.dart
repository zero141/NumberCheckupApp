import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'Надійний':
      return Colors.green;
    case 'Корисний':
      return Colors.greenAccent;
    case 'Нейтральний':
      return Colors.orange;
    case 'Підозрілий':
      return Colors.deepPurpleAccent;
    case 'Небезпечний':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
