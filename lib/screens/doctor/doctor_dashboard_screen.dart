import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/patient_summary.dart';
import '../../services/api_service.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  List<PatientSummary> _patientSummaries = [];
  bool _isLoading = true;
  String _filterSeverity = 'All';

  @override
  void initState() {
    super.initState();
    _loadPatientSummaries();
  }

  Future<void> _loadPatientSummaries() async {
    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final apiService = ApiService();
      final summaries = await apiService.getPatientSummaries(user.id);
      setState(() {
        _patientSummaries = summaries;
        _isLoading = false;
      });
    }
  }

  List<PatientSummary> get _filteredSummaries {
    if (_filterSeverity == 'All') return _patientSummaries;
    return _patientSummaries
        .where((s) => s.severity == _filterSeverity)
        .toList();
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'mild':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
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
          // Welcome & Stats
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Text(
                        user?.name[0].toUpperCase() ?? 'D',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${user?.name ?? 'Doctor'}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${_patientSummaries.length} Active Patients',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Severe',
                        count: _patientSummaries
                            .where((s) => s.severity == 'Severe')
                            .length,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'Moderate',
                        count: _patientSummaries
                            .where((s) => s.severity == 'Moderate')
                            .length,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'Mild',
                        count: _patientSummaries
                            .where((s) => s.severity == 'Mild')
                            .length,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Filter: '),
                const SizedBox(width: 8),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'All', label: Text('All')),
                      ButtonSegment(value: 'Severe', label: Text('Severe')),
                      ButtonSegment(value: 'Moderate', label: Text('Moderate')),
                      ButtonSegment(value: 'Mild', label: Text('Mild')),
                    ],
                    selected: {_filterSeverity},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _filterSeverity = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Patient List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSummaries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No patients found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPatientSummaries,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _filteredSummaries.length,
                          itemBuilder: (context, index) {
                            final patient = _filteredSummaries[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      _getSeverityColor(patient.severity),
                                  child: Text(
                                    patient.patientName[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(patient.patientName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Severity: ${patient.severity}'),
                                    Text('Timeline: ${patient.timeline}'),
                                    Text(
                                        'Symptoms: ${patient.keySymptoms.join(", ")}'),
                                  ],
                                ),
                                trailing: patient.needsConsultation
                                    ? const Icon(Icons.priority_high,
                                        color: Colors.red)
                                    : const Icon(Icons.chevron_right),
                                isThreeLine: true,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/doctor/patient-detail',
                                    arguments: patient,
                                  );
                                },
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

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
