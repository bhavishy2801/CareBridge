class SymptomReport {
  final String id;
  final String patientId;
  final DateTime timestamp;
  final Map<String, dynamic> symptoms;
  final List<String>? attachments;
  final bool isSynced;
  final String? severity;

  SymptomReport({
    required this.id,
    required this.patientId,
    required this.timestamp,
    required this.symptoms,
    this.attachments,
    this.isSynced = false,
    this.severity,
  });

  factory SymptomReport.fromJson(Map<String, dynamic> json) {
    return SymptomReport(
      id: json['id'],
      patientId: json['patientId'],
      timestamp: DateTime.parse(json['timestamp']),
      symptoms: json['symptoms'],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      isSynced: json['isSynced'] ?? false,
      severity: json['severity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'timestamp': timestamp.toIso8601String(),
      'symptoms': symptoms,
      'attachments': attachments,
      'isSynced': isSynced,
      'severity': severity,
    };
  }
}
