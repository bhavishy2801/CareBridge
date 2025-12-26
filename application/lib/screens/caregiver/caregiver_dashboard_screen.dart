import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/adherence_data.dart';
import '../../services/api_service.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  List<AdherenceData> _adherenceDataList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdherenceData();
  }

  Future<void> _loadAdherenceData() async {
    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final apiService = ApiService();
      final data = await apiService.getAdherenceData(user.id);
      setState(() {
        _adherenceDataList = data;
        _isLoading = false;
      });
    }
  }

  Color _getAdherenceColor(double adherence) {
    if (adherence >= 80) return Colors.green;
    if (adherence >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/caregiver-notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    user?.name[0].toUpperCase() ?? 'C',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Caregiver',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Monitoring ${_adherenceDataList.length} patients',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Patient Adherence List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _adherenceDataList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No patients assigned',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAdherenceData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _adherenceDataList.length,
                          itemBuilder: (context, index) {
                            final adherenceData = _adherenceDataList[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getAdherenceColor(
                                      adherenceData.overallAdherence),
                                  child: Text(
                                    '${adherenceData.overallAdherence.toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(adherenceData.patientName),
                                subtitle: Text(
                                  'Last updated: ${adherenceData.date.toString().split(' ')[0]}',
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Medication Adherence
                                        if (adherenceData
                                            .medicationAdherence.isNotEmpty) ...[
                                          const Text(
                                            'Medications:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          ...adherenceData.medicationAdherence
                                              .entries
                                              .map(
                                                (entry) => Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 4.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        entry.value
                                                            ? Icons.check_circle
                                                            : Icons.cancel,
                                                        size: 16,
                                                        color: entry.value
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(entry.key),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          const SizedBox(height: 12),
                                        ],

                                        // Exercise Adherence
                                        if (adherenceData
                                            .exerciseAdherence.isNotEmpty) ...[
                                          const Text(
                                            'Exercises:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          ...adherenceData.exerciseAdherence
                                              .entries
                                              .map(
                                                (entry) => Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 4.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        entry.value
                                                            ? Icons.check_circle
                                                            : Icons.cancel,
                                                        size: 16,
                                                        color: entry.value
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(entry.key),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          const SizedBox(height: 12),
                                        ],

                                        // Missed Tasks
                                        if (adherenceData
                                            .missedTasks.isNotEmpty) ...[
                                          const Text(
                                            'Missed Tasks:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...adherenceData.missedTasks.map(
                                            (task) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4.0),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.warning,
                                                    size: 16,
                                                    color: Colors.red,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(task),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              // TODO: Send reminder
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Reminder sent to patient'),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.notifications),
                                            label: const Text('Send Reminder'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
