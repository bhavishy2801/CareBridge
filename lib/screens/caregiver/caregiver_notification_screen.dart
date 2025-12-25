import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../shared/base_notification_screen.dart';

class CaregiverNotificationScreen extends StatelessWidget {
  const CaregiverNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseNotificationScreen(
      userType: 'caregiver',
      loadNotifications: () => _loadCaregiverNotifications(context),
      markAsRead: (id) => _markAsRead(context, id),
      deleteNotification: (id) => _deleteNotification(context, id),
      onNotificationTap:
          (notification) => _handleNotificationTap(context, notification),
    );
  }

  Future<List<AppNotification>> _loadCaregiverNotifications(
    BuildContext context,
  ) async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    if (token == null) {
      throw Exception('User not logged in');
    }

    try {
      final apiService = ApiService();
      final notifications = await apiService.getNotifications(token);
      return notifications;
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      rethrow;
    }
  }

  Future<void> _markAsRead(BuildContext context, String id) async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    if (token == null) return;

    try {
      final apiService = ApiService();
      await apiService.markNotificationAsRead(token, id);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _deleteNotification(BuildContext context, String id) async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    if (token == null) return;

    try {
      final apiService = ApiService();
      await apiService.deleteNotification(token, id);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  void _handleNotificationTap(
    BuildContext context,
    AppNotification notification,
  ) {
    switch (notification.type) {
      case NotificationType.medication:
      case NotificationType.missedTask:
        // Show medication alert dialog
        _showMedicationAlertDialog(context, notification);
        break;
      case NotificationType.alert:
        // Show emergency/vital alert dialog
        _showVitalAlertDialog(context, notification);
        break;
      case NotificationType.vitals:
        // Navigate to patient vitals
        if (notification.data != null) {
          _showVitalsUpdateDialog(context, notification);
        }
        break;
      case NotificationType.exercise:
        // Show exercise reminder dialog
        _showExerciseDialog(context, notification);
        break;
      case NotificationType.message:
        // Navigate to chat
        if (notification.data != null) {
          Navigator.pushNamed(
            context,
            '/conversation',
            arguments: notification.data,
          );
        } else {
          Navigator.pushNamed(context, '/chat');
        }
        break;
      case NotificationType.appointment:
        // Show appointment reminder
        _showAppointmentDialog(context, notification);
        break;
      default:
        _showNotificationDetails(context, notification);
    }
  }

  void _showMedicationAlertDialog(
    BuildContext context,
    AppNotification notification,
  ) {
    final patientName = notification.data?['patientName'] ?? 'Patient';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.medication, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text('Medication Alert'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Patient: $patientName',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please ensure the patient takes their medication.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Mark as handled or navigate to medication schedule
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder acknowledged')),
                  );
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Acknowledge'),
              ),
            ],
          ),
    );
  }

  void _showVitalAlertDialog(
    BuildContext context,
    AppNotification notification,
  ) {
    final patientName = notification.data?['patientName'] ?? 'Patient';
    final vitalType = notification.data?['vitalType'] ?? 'vitals';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Expanded(child: Text('Vital Signs Alert')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Patient: $patientName',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.monitor_heart, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Type: ${vitalType.toString().replaceAll('_', ' ').toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Consider contacting the doctor if readings remain abnormal.',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/chat');
                },
                icon: const Icon(Icons.message, size: 18),
                label: const Text('Contact Doctor'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alert acknowledged')),
                  );
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Acknowledge'),
              ),
            ],
          ),
    );
  }

  void _showVitalsUpdateDialog(
    BuildContext context,
    AppNotification notification,
  ) {
    final patientName = notification.data?['patientName'] ?? 'Patient';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.favorite, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text('Vitals Update'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Patient: $patientName',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to view full vitals history
                  Navigator.pushNamed(
                    context,
                    '/patient-vitals',
                    arguments: notification.data,
                  );
                },
                icon: const Icon(Icons.show_chart, size: 18),
                label: const Text('View Details'),
              ),
            ],
          ),
    );
  }

  void _showExerciseDialog(BuildContext context, AppNotification notification) {
    final patientName = notification.data?['patientName'] ?? 'Patient';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.fitness_center, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text('Exercise Reminder'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Patient: $patientName',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exercise reminder acknowledged'),
                    ),
                  );
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Mark Done'),
              ),
            ],
          ),
    );
  }

  void _showAppointmentDialog(
    BuildContext context,
    AppNotification notification,
  ) {
    final patientName = notification.data?['patientName'] ?? 'Patient';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text('Appointment Reminder'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Patient: $patientName',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please ensure the patient is prepared for their appointment.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder acknowledged')),
                  );
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Acknowledge'),
              ),
            ],
          ),
    );
  }

  void _showNotificationDetails(
    BuildContext context,
    AppNotification notification,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(notification.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message),
                const SizedBox(height: 16),
                Text(
                  'Received: ${_formatDateTime(notification.createdAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
