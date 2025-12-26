import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../shared/base_notification_screen.dart';

class DoctorNotificationScreen extends StatelessWidget {
  const DoctorNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseNotificationScreen(
      userType: 'doctor',
      loadNotifications: () => _loadDoctorNotifications(context),
      markAsRead: (id) => _markAsRead(context, id),
      deleteNotification: (id) => _deleteNotification(context, id),
      onNotificationTap:
          (notification) => _handleNotificationTap(context, notification),
    );
  }

  Future<List<AppNotification>> _loadDoctorNotifications(
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
      case NotificationType.alert:
      case NotificationType.missedTask:
        // Navigate to patient details/emergency view
        if (notification.data != null) {
          _showPatientAlertDialog(context, notification);
        }
        break;
      case NotificationType.appointment:
        // Navigate to doctor appointments
        Navigator.pushNamed(context, '/doctor-appointments');
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
      case NotificationType.vitals:
        // Navigate to patient vitals view
        if (notification.data != null) {
          _showVitalsDialog(context, notification);
        }
        break;
      default:
        _showNotificationDetails(context, notification);
    }
  }

  void _showPatientAlertDialog(
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
                Icon(Icons.warning_amber, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Expanded(child: Text(notification.title)),
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
                  // Navigate to patient details
                  if (notification.data != null) {
                    Navigator.pushNamed(
                      context,
                      '/patient-details',
                      arguments: notification.data,
                    );
                  }
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('View Patient'),
              ),
            ],
          ),
    );
  }

  void _showVitalsDialog(BuildContext context, AppNotification notification) {
    final patientName = notification.data?['patientName'] ?? 'Patient';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.favorite, color: Colors.red[400]),
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
                    color: Colors.red.withOpacity(0.1),
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
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  if (notification.data != null) {
                    Navigator.pushNamed(
                      context,
                      '/patient-vitals',
                      arguments: notification.data,
                    );
                  }
                },
                icon: const Icon(Icons.show_chart, size: 18),
                label: const Text('View Vitals'),
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
