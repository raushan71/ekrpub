import 'dart:convert';

class SingUp {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String country;
  final String phoneCode;
  SingUp({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.country,
    required this.phoneCode,
  });

  SingUp copyWith({
    String? name,
    String? phone,
    String? email,
    String? password,
    String? country,
    String? phoneCode,
  }) {
    return SingUp(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      country: country ?? this.country,
      phoneCode: phoneCode ?? this.phoneCode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'country': country,
      'phone_code': phoneCode,
    };
  }

  factory SingUp.fromMap(Map<String, dynamic> map) {
    return SingUp(
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      country: map['country'] as String,
      phoneCode: map['phone_code'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SingUp.fromJson(String source) =>
      SingUp.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SingUp(name: $name, phone: $phone, email: $email, password: $password,country: $country phoneCode: $phoneCode)';

  @override
  bool operator ==(covariant SingUp other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.phone == phone &&
        other.password == password;
  }

  @override
  int get hashCode => name.hashCode ^ phone.hashCode ^ password.hashCode;
}
