class PatientSummary {
  final String patientId;
  final String patientName;
  final DateTime lastReportDate;
  final String severity;
  final String timeline;
  final List<String> keySymptoms;
  final bool needsConsultation;

  PatientSummary({
    required this.patientId,
    required this.patientName,
    required this.lastReportDate,
    required this.severity,
    required this.timeline,
    required this.keySymptoms,
    this.needsConsultation = false,
  });

  factory PatientSummary.fromJson(Map<String, dynamic> json) {
    return PatientSummary(
      patientId: json['patientId'],
      patientName: json['patientName'],
      lastReportDate: DateTime.parse(json['lastReportDate']),
      severity: json['severity'],
      timeline: json['timeline'],
      keySymptoms: List<String>.from(json['keySymptoms']),
      needsConsultation: json['needsConsultation'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'lastReportDate': lastReportDate.toIso8601String(),
      'severity': severity,
      'timeline': timeline,
      'keySymptoms': keySymptoms,
      'needsConsultation': needsConsultation,
    };
  }
}
