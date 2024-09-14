import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchPhoneService {
  static Future<Map<String, dynamic>?> searchPhoneNumber(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('https://numbercheckup.com/api/phone-number/all'),
        body: jsonEncode({'number': phoneNumber}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        final data = responseBody['data'] as Map<String, dynamic>;

        return {
          'phoneNumberId': data['id'],
          'number': data['number'] ?? 'Невідомий',
          'rating': (data['statistic']?['rating'] ?? 0).toInt(),
          'commentsCount': data['statistic']?['comments'] ?? 0,
          'comments': data['comments'] as List<dynamic>,
        };
      }
    } catch (e) {
      print('Помилка: $e');
    }
    return null;
  }
}
