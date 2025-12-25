class CarePlan {
  final String id;
  final String patientId;
  final String doctorId;
  final String? appointmentId;
  final DateTime createdAt;
  final List<Medication> medications;
  final List<Exercise> exercises;
  final String instructions;
  final String warningSigns;
  final String? pdfUrl;
  final String? doctorName;
  final String? patientName;

  CarePlan({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.appointmentId,
    required this.createdAt,
    required this.medications,
    required this.exercises,
    required this.instructions,
    required this.warningSigns,
    this.pdfUrl,
    this.doctorName,
    this.patientName,
  });

  factory CarePlan.fromJson(Map<String, dynamic> json) {
    return CarePlan(
      id: json['_id'] ?? json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      appointmentId: json['appointmentId'],
      createdAt: DateTime.parse(json['createdAt']),
      medications:
          (json['medications'] as List)
              .map((m) => Medication.fromJson(m))
              .toList(),
      exercises:
          (json['exercises'] as List).map((e) => Exercise.fromJson(e)).toList(),
      instructions: json['instructions'] ?? '',
      warningSigns: json['warningSigns'] ?? '',
      pdfUrl: json['pdfUrl'],
      doctorName: json['doctorName'],
      patientName: json['patientName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentId': appointmentId,
      'createdAt': createdAt.toIso8601String(),
      'medications': medications.map((m) => m.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'instructions': instructions,
      'warningSigns': warningSigns,
      'pdfUrl': pdfUrl,
      'doctorName': doctorName,
      'patientName': patientName,
    };
  }
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String? duration;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.duration,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    };
  }
}

class Exercise {
  final String name;
  final String duration;
  final String frequency;

  Exercise({
    required this.name,
    required this.duration,
    required this.frequency,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      duration: json['duration'],
      frequency: json['frequency'] ?? 'Daily',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'duration': duration, 'frequency': frequency};
  }
}
