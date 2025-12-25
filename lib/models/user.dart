enum UserRole { patient, doctor, caregiver, admin }

// Associated Doctor info for patients
class AssociatedDoctor {
  final String doctorId;
  final String? name;
  final String? specialization;
  final String? phone;
  final String? email;
  final DateTime? associatedAt;
  final bool isActive;

  AssociatedDoctor({
    required this.doctorId,
    this.name,
    this.specialization,
    this.phone,
    this.email,
    this.associatedAt,
    this.isActive = true,
  });

  factory AssociatedDoctor.fromJson(Map<String, dynamic> json) {
    // Handle both populated and non-populated responses
    final doctorData = json['doctorId'];
    if (doctorData is Map<String, dynamic>) {
      return AssociatedDoctor(
        doctorId: doctorData['_id'] ?? doctorData['id'] ?? '',
        name: doctorData['name'],
        specialization: json['specialization'] ?? doctorData['specialization'],
        phone: doctorData['phone'],
        email: doctorData['email'],
        associatedAt: json['associatedAt'] != null 
            ? DateTime.parse(json['associatedAt']) 
            : null,
        isActive: json['isActive'] ?? true,
      );
    }
    return AssociatedDoctor(
      doctorId: doctorData?.toString() ?? '',
      specialization: json['specialization'],
      associatedAt: json['associatedAt'] != null 
          ? DateTime.parse(json['associatedAt']) 
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'doctorId': doctorId,
    'name': name,
    'specialization': specialization,
    'phone': phone,
    'email': email,
    'associatedAt': associatedAt?.toIso8601String(),
    'isActive': isActive,
  };
}

// Associated Patient info for doctors/caretakers
class AssociatedPatient {
  final String patientId;
  final String? patientQrCodeId;
  final String? name;
  final int? age;
  final String? bloodGroup;
  final String? gender;
  final String? phone;
  final String? email;
  final String? diagnosis;
  final String? notes;
  final DateTime? associatedAt;
  final DateTime? lastVisit;
  final bool isActive;

  AssociatedPatient({
    required this.patientId,
    this.patientQrCodeId,
    this.name,
    this.age,
    this.bloodGroup,
    this.gender,
    this.phone,
    this.email,
    this.diagnosis,
    this.notes,
    this.associatedAt,
    this.lastVisit,
    this.isActive = true,
  });

  factory AssociatedPatient.fromJson(Map<String, dynamic> json) {
    // Handle both populated and non-populated responses
    final patientData = json['patientId'];
    if (patientData is Map<String, dynamic>) {
      return AssociatedPatient(
        patientId: patientData['_id'] ?? patientData['id'] ?? '',
        patientQrCodeId: json['patientQrCodeId'],
        name: patientData['name'],
        age: patientData['age'],
        bloodGroup: patientData['bloodGroup'],
        gender: patientData['gender'],
        phone: patientData['phone'],
        email: patientData['email'],
        diagnosis: json['diagnosis'],
        notes: json['notes'],
        associatedAt: json['associatedAt'] != null 
            ? DateTime.parse(json['associatedAt']) 
            : null,
        lastVisit: json['lastVisit'] != null 
            ? DateTime.parse(json['lastVisit']) 
            : null,
        isActive: json['isActive'] ?? true,
      );
    }
    return AssociatedPatient(
      patientId: patientData?.toString() ?? '',
      patientQrCodeId: json['patientQrCodeId'],
      diagnosis: json['diagnosis'],
      notes: json['notes'],
      associatedAt: json['associatedAt'] != null 
          ? DateTime.parse(json['associatedAt']) 
          : null,
      lastVisit: json['lastVisit'] != null 
          ? DateTime.parse(json['lastVisit']) 
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'patientQrCodeId': patientQrCodeId,
    'name': name,
    'age': age,
    'bloodGroup': bloodGroup,
    'gender': gender,
    'phone': phone,
    'email': email,
    'diagnosis': diagnosis,
    'notes': notes,
    'associatedAt': associatedAt?.toIso8601String(),
    'lastVisit': lastVisit?.toIso8601String(),
    'isActive': isActive,
  };
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  // Common optional fields
  final String? phoneNumber;
  final String? profileImage;
  final Map<String, dynamic>? metadata;

  // Role-based profile fields
  final String? gender;
  final int? age;
  final String? bloodGroup;
  final String? specialization;
  final String? address;

  // Patient-specific: QR Code ID for identification
  final String? qrCodeId;

  // Associations
  final List<AssociatedDoctor> associatedDoctors;
  final List<AssociatedPatient> associatedPatients;

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
    this.address,
    this.qrCodeId,
    this.associatedDoctors = const [],
    this.associatedPatients = const [],
  });

  // FROM JSON (Backend → App)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
      phoneNumber: json['phone'] ?? json['phoneNumber'],
      profileImage: json['profileImage'],
      metadata: json['metadata'],
      gender: json['gender'],
      age: json['age'],
      bloodGroup: json['bloodGroup'],
      specialization: json['specialization'],
      address: json['address'],
      qrCodeId: json['qrCodeId'],
      associatedDoctors: (json['associatedDoctors'] as List<dynamic>?)
          ?.map((e) => AssociatedDoctor.fromJson(e as Map<String, dynamic>))
          .where((d) => d.isActive)
          .toList() ?? [],
      associatedPatients: (json['associatedPatients'] as List<dynamic>?)
          ?.map((e) => AssociatedPatient.fromJson(e as Map<String, dynamic>))
          .where((p) => p.isActive)
          .toList() ?? [],
    );
  }

  // TO JSON (App → Storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'phone': phoneNumber,
      'profileImage': profileImage,
      'metadata': metadata,
      'gender': gender,
      'age': age,
      'bloodGroup': bloodGroup,
      'specialization': specialization,
      'address': address,
      'qrCodeId': qrCodeId,
      'associatedDoctors': associatedDoctors.map((d) => d.toJson()).toList(),
      'associatedPatients': associatedPatients.map((p) => p.toJson()).toList(),
    };
  }

  // Create a copy with updated associations
  User copyWith({
    List<AssociatedDoctor>? associatedDoctors,
    List<AssociatedPatient>? associatedPatients,
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      phoneNumber: phoneNumber,
      profileImage: profileImage,
      metadata: metadata,
      gender: gender,
      age: age,
      bloodGroup: bloodGroup,
      specialization: specialization,
      address: address,
      qrCodeId: qrCodeId,
      associatedDoctors: associatedDoctors ?? this.associatedDoctors,
      associatedPatients: associatedPatients ?? this.associatedPatients,
    );
  }

  // ROLE PARSER (SAFE)
  static UserRole _parseRole(dynamic roleValue) {
    if (roleValue is String) {
      switch (roleValue.toLowerCase()) {
        case 'patient':
          return UserRole.patient;
        case 'doctor':
          return UserRole.doctor;
        case 'caregiver':
        case 'caretaker':
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
