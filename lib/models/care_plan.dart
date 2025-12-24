class CarePlan {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime createdAt;
  final List<Medication> medications;
  final List<Exercise> exercises;
  final List<String> instructions;
  final String? pdfUrl;

  CarePlan({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.createdAt,
    required this.medications,
    required this.exercises,
    required this.instructions,
    this.pdfUrl,
  });

  factory CarePlan.fromJson(Map<String, dynamic> json) {
    return CarePlan(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      createdAt: DateTime.parse(json['createdAt']),
      medications: (json['medications'] as List)
          .map((m) => Medication.fromJson(m))
          .toList(),
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      instructions: List<String>.from(json['instructions']),
      pdfUrl: json['pdfUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'createdAt': createdAt.toIso8601String(),
      'medications': medications.map((m) => m.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'instructions': instructions,
      'pdfUrl': pdfUrl,
    };
  }
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String? instructions;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.instructions,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'instructions': instructions,
    };
  }
}

class Exercise {
  final String name;
  final String duration;
  final String? description;

  Exercise({
    required this.name,
    required this.duration,
    this.description,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      duration: json['duration'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration': duration,
      'description': description,
    };
  }
}
