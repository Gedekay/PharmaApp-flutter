class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(

      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Pharmacien {
  final int id;
  final String name;
  final String firstName;
  final String phoneNumber;
  final String? gender;
  final int? age;
  final int userId;

  Pharmacien({
    required this.id,
    required this.name,
    required this.firstName,
    required this.phoneNumber,
    this.gender,
    this.age,
    required this.userId,
  });

  factory Pharmacien.fromJson(Map<String, dynamic> json) {
    return Pharmacien(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),

      name: json['Name'] ?? json['name'] ?? '',
      firstName: json['First_name'] ?? json['first_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      gender: json['gender'],

      age: json['age'] == null
          ? null
          : (json['age'] is int
                ? json['age']
                : int.tryParse(json['age'].toString())),

      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
    );
  }
}


class AuthResponseDto {
  final String role;
  final String token;
  final User user;
  final Pharmacien? pharmacien;

  AuthResponseDto({
    required this.role,
    required this.token,
    required this.user,
    this.pharmacien,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      role: json['role'] ?? '',
      token: json['token'] ?? '',
      user: User.fromJson(json['user']),
      pharmacien: json['pharmacien'] != null
          ? Pharmacien.fromJson(json['pharmacien'])
          : null,
    );
  }
}
