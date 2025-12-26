class Symptom {
  final String name;
  final int severity;

  Symptom({required this.name, required this.severity});

  Map<String, dynamic> toJson() => {'name': name, 'severity': severity};

  factory Symptom.fromJson(Map<String, dynamic> json) =>
      Symptom(name: json['name'], severity: json['severity']);
}

class Report {
  final String? id;
  final String patient;
  final List<Symptom> symptoms;
  final String? customMessage;
  final DateTime? createdAt;

  Report({
    this.id,
    required this.patient,
    required this.symptoms,
    this.customMessage,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'patient': patient,
    'symptoms': symptoms.map((s) => s.toJson()).toList(),
    if (customMessage != null) 'customMessage': customMessage,
  };

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['_id'],
    patient:
        json['patient'] is String ? json['patient'] : json['patient']['_id'],
    symptoms:
        (json['symptoms'] as List).map((s) => Symptom.fromJson(s)).toList(),
    customMessage: json['customMessage'],
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}
