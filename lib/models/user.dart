enum UserRole { patient, doctor, caregiver, admin }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phoneNumber;
  final String? profileImage;
  final Map<String, dynamic>? metadata;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.profileImage,
    this.metadata,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
      ),
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'metadata': metadata,
    };
  }
}
