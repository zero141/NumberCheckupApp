import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'Надійний':
      return Colors.lightGreen;
    case 'Корисний':
      return  Colors.green[300]!;
    case 'Нейтральний':
      return Colors.orange[200]!;
    case 'Підозрілий':
      return Colors.red[200]!;
    case 'Небезпечний':
      return Colors.red[400]!;
    default:
      return Colors.grey[400]!;
  }
}


