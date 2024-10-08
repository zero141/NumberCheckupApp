import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'phone_number_service.dart';
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
  InterstitialAd? _interstitialAd;
  List<Map<String, String>> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _phoneDetails = '';
      });
    });

    MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory =
          (prefs.getStringList('search_history') ?? []).map((item) {
        final parts = item.split('|');
        return {
          'number': parts[0],
          'date': parts.length > 1
              ? parts[1]
              : DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
        };
      }).toList();
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = _searchHistory
        .map((item) => '${item['number']}|${item['date']}')
        .toList();
    await prefs.setStringList('search_history', historyList);
  }

  void _addToSearchHistory(String phoneNumber) {
    final now = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());
    setState(() {
      _searchHistory.removeWhere((item) => item['number'] == phoneNumber);
      _searchHistory.insert(0, {'number': phoneNumber, 'date': now});
      if (_searchHistory.length > 10) {
        _searchHistory.removeLast();
      }
    });
    _saveSearchHistory();
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    setState(() {
      _searchHistory.clear();
    });
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-9872067665936559/3331202586',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('Failed to show interstitial ad: $error');
          ad.dispose();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  Future<void> searchPhoneNumber(String phoneNumber) async {
    setState(() {
      _isLoading = true;
    });

    final result = await PhoneNumberService.searchPhoneNumber(phoneNumber);
    if (result != null) {
      _addToSearchHistory(phoneNumber);
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
    _showInterstitialAd();

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
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Image.asset(
            'assets/photo/NumberCheckup.png',
            height: 24,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 24),
                Text(
                  'Пошук інформації за номером телефону',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: '+380 66 456 789',
                      labelStyle:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
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
                      prefixIcon: Icon(Icons.phone, color: Colors.black87),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => searchPhoneNumber(_controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.black45, width: 1)
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        Icon(Icons.search, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isLoading ? 'Пошук...' : 'Пошук',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_phoneDetails.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Результати пошуку:',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _phoneDetails,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.black87,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_searchHistory.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Історія пошуків',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        _searchHistory.length >= 5 ? 5 : _searchHistory.length,
                    itemBuilder: (context, index) {
                      final item = _searchHistory[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.phone,
                                color: Colors.white, size: 16),
                          ),
                          title: Text(
                            item['number']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            item['date']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          onTap: () {
                            _controller.text = item['number']!;
                            searchPhoneNumber(item['number']!);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _clearSearchHistory,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('Очистити історію'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
                if (_searchHistory.isEmpty) ...[
                  const SizedBox(height: 32),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _controller.dispose();
    super.dispose();
  }
}
