enum UserRole { patient, doctor, caregiver, admin }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  // Existing optional fields
  final String? phoneNumber;
  final String? profileImage;
  final Map<String, dynamic>? metadata;

  // 🔹 NEW role-based profile fields
  final String? gender;
  final int? age;
  final String? bloodGroup;
  final String? specialization;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.profileImage,
    this.metadata,
    this.gender,
    this.age,
    this.bloodGroup,
    this.specialization,
  });

  // =====================
  // FROM JSON (Backend → App)
  // =====================
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      email: json['email'],
      role: _parseRole(json['role']),
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      metadata: json['metadata'],
      gender: json['gender'],
      age: json['age'],
      bloodGroup: json['bloodGroup'],
      specialization: json['specialization'],
    );
  }

  // =====================
  // TO JSON (App → Storage)
  // =====================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'metadata': metadata,
      'gender': gender,
      'age': age,
      'bloodGroup': bloodGroup,
      'specialization': specialization,
    };
  }

  // =====================
  // ROLE PARSER (SAFE)
  // =====================
  static UserRole _parseRole(dynamic roleValue) {
    if (roleValue is String) {
      switch (roleValue.toLowerCase()) {
        case 'patient':
          return UserRole.patient;
        case 'doctor':
          return UserRole.doctor;
        case 'caregiver':
          return UserRole.caregiver;
        case 'admin':
          return UserRole.admin;
        default:
          return UserRole.patient;
      }
    }
    return UserRole.patient;
  }
}
