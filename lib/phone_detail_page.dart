import 'package:NumberCheckup/phone_number_service.dart';
import 'package:flutter/material.dart';
import 'package:NumberCheckup/widgets/comment_card.dart';
import 'package:NumberCheckup/widgets/rating_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PhoneDetailPage extends StatefulWidget {
  final String phoneNumber;
  final int phoneNumberId;
  final int rating;
  final int commentsCount;
  final List<dynamic> comments;
  final VoidCallback onUpdate;

  const PhoneDetailPage({
    Key? key,
    required this.phoneNumber,
    required this.phoneNumberId,
    required this.rating,
    required this.commentsCount,
    required this.comments,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _PhoneDetailPageState createState() => _PhoneDetailPageState();
}

class _PhoneDetailPageState extends State<PhoneDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 3;
  late List<dynamic> _comments;

  @override
  void initState() {
    super.initState();
    _comments = widget.comments;
  }

  Future<void> addComment() async {
    final newComment = _commentController.text.trim();

    if (newComment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Коментар не може бути порожнім'),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://numbercheckup.com/api/comments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': newComment,
          'phone_number_id': widget.phoneNumberId,
          'status': _rating.toString(),
          'source': 3,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Коментар успішно додано'),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _commentController.clear();
        final result =
            await PhoneNumberService.searchPhoneNumber(widget.phoneNumber);
        if (result != null) {
          setState(() {
            _comments = result['comments'];
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не вдалося додати коментар'),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка: $e'),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Color _getStarColor(int rating) {
  //   int red = (255 * (5 - rating) / 4).round();
  //   int green = (255 * (rating - 1) / 4).round();
  //   return Color.fromARGB(255, red, green, 0);
  // }

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black87),
          title: Image.asset(
            'assets/photo/NumberCheckup.png',
            height: 24,
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24.0),
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text(
                    widget.phoneNumber,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  CustomRatingWidget(rating: widget.rating),
                  SizedBox(height: 8),
                  Text(
                    'Кількість коментарів: ${widget.commentsCount}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Коментарі',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 16),
                  ..._comments.map((comment) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CommentCard(comment: comment),
                    );
                  }).toList(),
                ],
              ),
            ),
            if (widget.comments.length == 7)
              Container(
                margin: EdgeInsets.only(bottom: 24),
                child: InkWell(
                  onTap: () {
                    launch(
                        'https://numbercheckup.com/phone-number/${widget.phoneNumber}');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Більше коментарів на сайті',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Залиште коментар',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Досвід спілкування з номером',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.black87, width: 1),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  Center(
                      child: RatingBar.builder(
                    initialRating: _rating.toDouble(),
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 36,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: _getStarColor(index < _rating ? _rating : 0),
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating.toInt();
                      });
                    },
                  )),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: addComment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.black45, width: 1)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Надіслати коментар',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
