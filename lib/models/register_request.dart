class RegisterRequest {
  final String name;
  final String? email;
  final String phone;
  final String password;

  RegisterRequest({
    required this.name,
    this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'phone': phone,
      'password': password,
    };
    if (email != null && email!.isNotEmpty) {
      data['email'] = email;
    }
    return data;
  }
}
