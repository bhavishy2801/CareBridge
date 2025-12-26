class AdherenceData {
  final String patientId;
  final String patientName;
  final DateTime date;
  final Map<String, bool> medicationAdherence;
  final Map<String, bool> exerciseAdherence;
  final double overallAdherence;
  final List<String> missedTasks;

  AdherenceData({
    required this.patientId,
    required this.patientName,
    required this.date,
    required this.medicationAdherence,
    required this.exerciseAdherence,
    required this.overallAdherence,
    required this.missedTasks,
  });

  factory AdherenceData.fromJson(Map<String, dynamic> json) {
    return AdherenceData(
      patientId: json['patientId'],
      patientName: json['patientName'],
      date: DateTime.parse(json['date']),
      medicationAdherence: Map<String, bool>.from(json['medicationAdherence']),
      exerciseAdherence: Map<String, bool>.from(json['exerciseAdherence']),
      overallAdherence: json['overallAdherence'].toDouble(),
      missedTasks: List<String>.from(json['missedTasks']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'date': date.toIso8601String(),
      'medicationAdherence': medicationAdherence,
      'exerciseAdherence': exerciseAdherence,
      'overallAdherence': overallAdherence,
      'missedTasks': missedTasks,
    };
  }
}
