import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../shared/base_notification_screen.dart';

class PatientNotificationScreen extends StatelessWidget {
  const PatientNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseNotificationScreen(
      userType: 'patient',
      loadNotifications: () => _loadPatientNotifications(context),
      markAsRead: (id) => _markAsRead(context, id),
      deleteNotification: (id) => _deleteNotification(context, id),
      onNotificationTap:
          (notification) => _handleNotificationTap(context, notification),
    );
  }

  Future<List<AppNotification>> _loadPatientNotifications(
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
      case NotificationType.reminder:
        // Navigate to daily tasks / medication reminder
        Navigator.pushNamed(context, '/daily-tasks');
        break;
      case NotificationType.appointment:
        // Navigate to appointments
        Navigator.pushNamed(context, '/appointments');
        break;
      case NotificationType.carePlan:
        // Navigate to care plan
        Navigator.pushNamed(context, '/care-plan');
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
      case NotificationType.exercise:
        // Navigate to daily tasks / exercises
        Navigator.pushNamed(context, '/daily-tasks');
        break;
      case NotificationType.vitals:
        // Navigate to vitals/symptom form
        Navigator.pushNamed(context, '/symptom-form');
        break;
      default:
        // Show notification details dialog
        _showNotificationDetails(context, notification);
    }
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
