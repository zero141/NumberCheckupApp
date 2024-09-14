import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import "package:intl/intl.dart";
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NumberCheckup',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color:
                Colors.blueGrey.shade800, // Темно-сірий відтінок для заголовків
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black
                .withOpacity(0.8), // Текст чорний з невеликою прозорістю
          ),
          bodySmall: TextStyle(
            fontSize: 14,
            color: Colors
                .grey.shade600, // Нейтральні сірі тони для дрібного тексту
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey.shade600, // Кнопка блакитно-сіра
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.blueGrey.shade800),
          // Текст в полях вводу більш спокійного кольору
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey.shade400, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Colors.blueGrey.shade200), // Легка рамка навколо полів
          ),
          prefixIconColor:
              Colors.blueGrey.shade600, // Іконки в полях блакитно-сірі
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _phoneDetails = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add a listener to the TextEditingController
    _controller.addListener(() {
      // Clear phone details when the text changes
      setState(() {
        _phoneDetails = '';
      });
    });
  }

  Future<void> searchPhoneNumber(String phoneNumber) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://numbercheckup.com/api/phone-number/all'),
        body: jsonEncode({'number': phoneNumber}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        final data = responseBody['data'] as Map<String, dynamic>;
        final number = data['number'] ?? 'Невідомий';
        final phoneNumberId = data['id'];
        final statistic = data['statistic'] as Map<String, dynamic>?;
        final comments = data['comments'] as List<dynamic>;

        _navigateToDetails(
            context: context,
            phoneNumberId: phoneNumberId,
            number: number,
            rating: (statistic?['rating'] ?? 0).toInt(),
            commentsCount: statistic?['comments'] ?? 0,
            comments: comments);
      } else {
        setState(() {
          _phoneDetails = 'Такого номеру телефону немає в базі даних';
        });
      }
    } catch (e) {
      setState(() {
        _phoneDetails = 'Помилка: $e';
      });
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToDetails({
    required BuildContext context,
    required int phoneNumberId,
    required String number,
    required int rating,
    required int commentsCount,
    required List<dynamic> comments,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneDetailPage(
          phoneNumber: number,
          phoneNumberId: phoneNumberId,
          rating: rating,
          commentsCount: commentsCount,
          comments: comments,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: Image.asset(
              'assets/photo/NumberCheckup.png',
              // Замість заголовка вставте зображення
              height: 20, // Висота зображення
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Text(
                      'Пошук інформації за номером телефону',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: '+380 123 456 789',
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => searchPhoneNumber(_controller.text),
                      icon: _isLoading
                          ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Icon(Icons.search, color: Colors.white),
                      label: Text(
                        _isLoading ? 'Пошук...' : 'Пошук',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade600,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        disabledBackgroundColor: Colors.blueGrey.shade400,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_phoneDetails.isNotEmpty)
                      Card(
                        elevation: 5,
                        color: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Результати пошуку:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _phoneDetails,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildInfoCard('15млн', 'Номерів', Icons.contact_phone),
                        _buildInfoCard('2млн', 'Коментарів', Icons.comment),
                        _buildInfoCard('350тис', 'Шахраїв', Icons.warning),
                        _buildInfoCard('568', 'Міст', Icons.location_city),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      // Зменшено підйом
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      // Зменшено радіус округлення
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Збільшено відступи
        child: Column(
          mainAxisSize: MainAxisSize.min, // Зменшено розмір стовпця
          children: [
            Icon(icon, size: 32, color: Colors.blue), // Збільшено розмір іконки
            const SizedBox(height: 12), // Збільшено відступ
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Збільшено розмір шрифту заголовка
                  ),
            ),
            const SizedBox(height: 8), // Збільшено відступ
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 16, // Збільшено розмір шрифту значення
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneDetailPage extends StatefulWidget {
  final String phoneNumber;
  final int phoneNumberId;
  final int rating;
  final int commentsCount;
  final List<dynamic> comments;

  const PhoneDetailPage({
    Key? key,
    required this.phoneNumber,
    required this.phoneNumberId,
    required this.rating,
    required this.commentsCount,
    required this.comments,
  }) : super(key: key);

  @override
  _PhoneDetailPageState createState() => _PhoneDetailPageState();
}

class _PhoneDetailPageState extends State<PhoneDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 3;

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }

  Color _getStarColor(int rating) {
    int red = (255 * (5 - rating) / 4).round();
    int green = (255 * (rating - 1) / 4).round();
    return Color.fromARGB(255, red, green, 0);
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
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Коментар успішно додано')),
        );
        _commentController.clear();
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
              Column(
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
                    rating: widget.rating.toDouble(),
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: _getStarColor(widget.rating),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Кількість коментарів: ${widget.commentsCount}',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Коментарі:',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              ...widget.comments.map((comment) {
                final status = comment['status']; // Статус коментаря
                final text = comment['text'];
                final createdAt = comment['created_at'];
                final formattedDate = _formatDate(createdAt);
                final nickname = comment['visitor']['nickname'];
                final photo = comment['visitor']['photo'];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Фото користувача
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            image: DecorationImage(
                              image: AssetImage("assets$photo"),
                              // Використовуйте AssetImage
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    nickname,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                  ),
                                  // Виведення статусу коментаря
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      // Колір статусу
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                text,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formattedDate,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
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
              // Вибір рейтингу користувачем
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
              // Вибір рейтингу користувачем
              Text(
                'Виставити рейтинг:',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: _rating.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                // Дозволити лише цілі числа
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: _getStarColor(index < _rating ? _rating : 0),
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating.toInt(); // Оновлення рейтингу
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addComment,
                child: const Text(
                  'Надіслати коментар',
                  style: TextStyle(color: Colors.white), // Білий текст
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade600,
                  // Колір фону кнопки
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  // Відступи
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Закруглені кути
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
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
}
