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
        const SnackBar(content: Text('Коментар не може бути порожнім')),
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
          const SnackBar(content: Text('Коментар успішно додано')),
        );
        _commentController.clear();
        final result = await PhoneNumberService.searchPhoneNumber(widget.phoneNumber);
        if (result != null) {
          setState(() {
            _comments = result['comments'];
          });
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не вдалося додати коментар')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/photo/NumberCheckup.png',
            height: 20,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              Text(
                widget.phoneNumber,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomRatingWidget(rating: widget.rating),
              const SizedBox(height: 20),
              Text(
                'Кількість коментарів: ${widget.commentsCount}',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Коментарі:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._comments.map((comment) {
                return CommentCard(comment: comment);
              }).toList(),
              const SizedBox(height: 20),
              if (widget.comments.length == 7)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () {
                      launch(
                          'https://numbercheckup.com/phone-number/${widget.phoneNumber}');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Більше коментарів на сайті',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Залиште коментар:',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Досвід спілкування з номером',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              RatingBar.builder(
                initialRating: _rating.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
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
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addComment,
                child: const Text(
                  'Надіслати коментар',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade600,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStarColor(int rating) {
    int red = (255 * (5 - rating) / 4).round();
    int green = (255 * (rating - 1) / 4).round();
    return Color.fromARGB(255, red, green, 0);
  }
}
