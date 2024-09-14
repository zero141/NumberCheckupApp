// phone_number_service.dart
import 'search_phone_service.dart';

class PhoneNumberService {
  static Future<Map<String, dynamic>?> searchPhoneNumber(String phoneNumber) async {
    return await SearchPhoneService.searchPhoneNumber(phoneNumber);
  }
}
