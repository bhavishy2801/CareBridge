enum NotificationType {
  reminder,
  alert,
  info,
  medication,
  appointment,
  message,
  carePlan,
  vitals,
  exercise,
  missedTask,
  general,
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? relatedEntity;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.scheduledAt,
    this.isRead = false,
    this.data,
    this.relatedEntity,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? json['id'] ?? '',
      userId:
          json['userId'] is Map
              ? json['userId']['_id']
              : (json['userId'] ?? ''),
      type: _parseNotificationType(json['type']),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      scheduledAt:
          json['scheduledAt'] != null || json['scheduledTime'] != null
              ? DateTime.parse(json['scheduledAt'] ?? json['scheduledTime'])
              : null,
      isRead: json['isRead'] ?? json['read'] ?? false,
      data:
          json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      relatedEntity:
          json['relatedEntity'] != null
              ? Map<String, dynamic>.from(json['relatedEntity'])
              : null,
    );
  }

  static NotificationType _parseNotificationType(dynamic type) {
    if (type == null) return NotificationType.general;
    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'reminder':
        return NotificationType.reminder;
      case 'alert':
        return NotificationType.alert;
      case 'info':
        return NotificationType.info;
      case 'medication':
        return NotificationType.medication;
      case 'appointment':
        return NotificationType.appointment;
      case 'message':
        return NotificationType.message;
      case 'careplan':
      case 'care_plan':
        return NotificationType.carePlan;
      case 'vitals':
        return NotificationType.vitals;
      case 'exercise':
        return NotificationType.exercise;
      case 'missedtask':
      case 'missed_task':
        return NotificationType.missedTask;
      default:
        return NotificationType.general;
    }
  }

  String get typeString {
    switch (type) {
      case NotificationType.reminder:
        return 'reminder';
      case NotificationType.alert:
        return 'alert';
      case NotificationType.info:
        return 'info';
      case NotificationType.medication:
        return 'medication';
      case NotificationType.appointment:
        return 'appointment';
      case NotificationType.message:
        return 'message';
      case NotificationType.carePlan:
        return 'care_plan';
      case NotificationType.vitals:
        return 'vitals';
      case NotificationType.exercise:
        return 'exercise';
      case NotificationType.missedTask:
        return 'missed_task';
      case NotificationType.general:
        return 'general';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': typeString,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'isRead': isRead,
      'data': data,
      'relatedEntity': relatedEntity,
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    DateTime? scheduledAt,
    bool? isRead,
    Map<String, dynamic>? data,
    Map<String, dynamic>? relatedEntity,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      relatedEntity: relatedEntity ?? this.relatedEntity,
    );
  }
}
