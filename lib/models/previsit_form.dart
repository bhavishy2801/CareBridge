class PrevisitForm {
  final String? id;
  final String appointmentId;
  final List<String> symptoms;
  final List<String> reports;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PrevisitForm({
    this.id,
    required this.appointmentId,
    required this.symptoms,
    required this.reports,
    this.createdAt,
    this.updatedAt,
  });

  factory PrevisitForm.fromJson(Map<String, dynamic> json) {
    return PrevisitForm(
      id: json['_id'] ?? json['id'],
      appointmentId: json['appointmentId'],
      symptoms:
          (json['symptoms'] as List?)
              ?.map((s) => s['name'] as String)
              .toList() ??
          [],
      reports: List<String>.from(json['reports'] ?? []),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'appointmentId': appointmentId,
      'symptoms': symptoms,
      'reports': reports,
    };

    if (id != null) data['id'] = id!;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();

    return data;
  }
}
