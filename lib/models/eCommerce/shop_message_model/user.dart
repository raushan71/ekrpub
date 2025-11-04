import 'dart:convert';

class User {
  int? id;
  String? name;
  String? phone;
  bool? phoneVerified;
  String? email;
  bool? emailVerified;
  bool? isActive;
  String? profilePhoto;
  dynamic gender;
  dynamic dateOfBirth;
  String? country;
  String? phoneCode;
  bool? accountVerified;
  bool? lastOnline;

  User({
    this.id,
    this.name,
    this.phone,
    this.phoneVerified,
    this.email,
    this.emailVerified,
    this.isActive,
    this.profilePhoto,
    this.gender,
    this.dateOfBirth,
    this.country,
    this.phoneCode,
    this.accountVerified,
    this.lastOnline,
  });

  factory User.fromMap(Map<String, dynamic> data) => User(
        id: data['id'] as int?,
        name: data['name'] as String?,
        phone: data['phone'] as String?,
        phoneVerified: data['phone_verified'] as bool?,
        email: data['email'] as String?,
        emailVerified: data['email_verified'] as bool?,
        isActive: data['is_active'] as bool?,
        profilePhoto: data['profile_photo'] as String?,
        gender: data['gender'] as dynamic,
        dateOfBirth: data['date_of_birth'] as dynamic,
        country: data['country'] as String?,
        phoneCode: data['phone_code'] as String?,
        accountVerified: data['account_verified'] as bool?,
        lastOnline: data['last_online'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'phone_verified': phoneVerified,
        'email': email,
        'email_verified': emailVerified,
        'is_active': isActive,
        'profile_photo': profilePhoto,
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'country': country,
        'phone_code': phoneCode,
        'account_verified': accountVerified,
        'last_online': lastOnline,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [User].
  factory User.fromJson(String data) {
    return User.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [User] to a JSON string.
  String toJson() => json.encode(toMap());
}
