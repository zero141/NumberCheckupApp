import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CustomRatingWidget extends StatelessWidget {
  final int rating;

  const CustomRatingWidget({Key? key, required this.rating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Рейтинг',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        RatingBarIndicator(
          rating: rating.toDouble(),
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: _getStarColor(rating),
          ),
        ),
      ],
    );
  }

  Color _getStarColor(int rating) {
    switch (rating) {
      case 5:
        return Colors.lightGreen;
      case 4:
        return Colors.green[300]!;
      case 3:
        return Colors.orange[200]!;
      case 2:
        return Colors.red[200]!;
      case 1:
        return Colors.red[400]!;
      default:
        return Colors.grey[400]!;
    }
  }
}
