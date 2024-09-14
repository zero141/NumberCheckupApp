import 'package:flutter/material.dart';
import 'phone_number_service.dart';  // Import the new service
import 'phone_detail_page.dart';
import 'info_card.dart';

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
    _controller.addListener(() {
      setState(() {
        _phoneDetails = '';
      });
    });
  }

  Future<void> searchPhoneNumber(String phoneNumber) async {
    setState(() {
      _isLoading = true;
    });

    final result = await PhoneNumberService.searchPhoneNumber(phoneNumber);
    if (result != null) {
      _navigateToDetails(
        context: context,
        phoneNumberId: result['phoneNumberId'],
        number: result['number'],
        rating: result['rating'],
        commentsCount: result['commentsCount'],
        comments: result['comments'],
      );
    } else {
      setState(() {
        _phoneDetails = 'Такого номеру телефону немає в базі даних';
      });
    }

    setState(() {
      _isLoading = false;
    });
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
          onUpdate: () => searchPhoneNumber(_controller.text),
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
            height: 20,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
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
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return InfoCard(title: title, value: value, icon: icon);
  }
}
