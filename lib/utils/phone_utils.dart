class PhoneUtils {
  static String formatIndianPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length == 10) {
      return '+91$cleanPhone';
    } else if (cleanPhone.length == 12 && cleanPhone.startsWith('91')) {
      return '+$cleanPhone';
    }
    return phone;
  }
}
