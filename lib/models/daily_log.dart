class DailyLog {
  final String? id;
  final String carePlanId;
  final DateTime date;
  final bool medicationTaken;
  final bool exerciseDone;
  final int symptomRating;
  final String? clientId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DailyLog({
    this.id,
    required this.carePlanId,
    required this.date,
    required this.medicationTaken,
    required this.exerciseDone,
    required this.symptomRating,
    this.clientId,
    this.createdAt,
    this.updatedAt,
  });

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      id: json['_id'] ?? json['id'],
      carePlanId: json['carePlanId'],
      date: DateTime.parse(json['date']),
      medicationTaken: json['medicationTaken'] ?? false,
      exerciseDone: json['exerciseDone'] ?? false,
      symptomRating: json['symptomRating'] ?? 0,
      clientId: json['clientId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'carePlanId': carePlanId,
      'date': date.toIso8601String(),
      'medicationTaken': medicationTaken,
      'exerciseDone': exerciseDone,
      'symptomRating': symptomRating,
    };
    
    if (id != null) data['id'] = id!;
    if (clientId != null) data['clientId'] = clientId!;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    
    return data;
  }
}
