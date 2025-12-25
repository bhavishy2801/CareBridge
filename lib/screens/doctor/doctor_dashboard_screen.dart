import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/patient_summary.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/chat_service.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _currentIndex = 0;

  Future<void> _scanQrCode() async {
    final result = await Navigator.pushNamed(context, '/doctor/scan-qr');
    if (result == true && mounted) {
      // Refresh user data after successful scan
      await context.read<AuthProvider>().refreshUser();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(onScanQr: _scanQrCode),
          _PatientsTab(onScanQr: _scanQrCode),
          _ChatsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chats',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanQrCode,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan Patient QR'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  final VoidCallback? onScanQr;

  const _DashboardTab({this.onScanQr});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  List<PatientSummary> _patientSummaries = [];
  bool _isLoading = true;
  String _filterSeverity = 'All';

  @override
  void initState() {
    super.initState();
    _refreshProfile();
    _loadPatientSummaries();
  }

  Future<void> _refreshProfile() async {
    await context.read<AuthProvider>().refreshUser();
  }

  Future<void> _loadPatientSummaries() async {
    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      try {
        final apiService = ApiService();
        final summaries = await apiService.getPatientSummaries(user.id);
        setState(() {
          _patientSummaries = summaries;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
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
    final associatedPatientsCount = user?.associatedPatients.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/doctor-notifications');
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
                            '$associatedPatientsCount Connected Patients',
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
                        count:
                            _patientSummaries
                                .where((s) => s.severity == 'Severe')
                                .length,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'Moderate',
                        count:
                            _patientSummaries
                                .where((s) => s.severity == 'Moderate')
                                .length,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'Mild',
                        count:
                            _patientSummaries
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
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredSummaries.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No patient reports yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Scan a patient\'s QR code to connect',
                            style: TextStyle(color: Colors.grey[600]),
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
                                backgroundColor: _getSeverityColor(
                                  patient.severity,
                                ),
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
                                    'Symptoms: ${patient.keySymptoms.join(", ")}',
                                  ),
                                ],
                              ),
                              trailing:
                                  patient.needsConsultation
                                      ? const Icon(
                                        Icons.priority_high,
                                        color: Colors.red,
                                      )
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

class _PatientsTab extends StatelessWidget {
  final VoidCallback? onScanQr;

  const _PatientsTab({this.onScanQr});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final patients = user?.associatedPatients ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Patient QR',
            onPressed:
                onScanQr ??
                () {
                  Navigator.pushNamed(context, '/doctor/scan-qr');
                },
          ),
        ],
      ),
      body:
          patients.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No patients yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scan a patient\'s QR code to connect',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed:
                          onScanQr ??
                          () {
                            Navigator.pushNamed(context, '/doctor/scan-qr');
                          },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR Code'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return _PatientCard(patient: patient);
                },
              ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final AssociatedPatient patient;

  const _PatientCard({required this.patient});

  void _showPatientOptions(BuildContext context, AssociatedPatient patient) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text('View Medical Records'),
                  subtitle: const Text('Patient history and documents'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to patient records
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Medical records coming soon'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('View Daily Logs'),
                  subtitle: const Text('Patient\'s daily health logs'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/doctor/patient-logs',
                      arguments: {
                        'patientId': patient.patientId,
                        'patientName': patient.name ?? 'Patient',
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment_outlined),
                  title: const Text('Create Care Plan'),
                  subtitle: const Text('Add treatment and medications'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/doctor/create-care-plan',
                      arguments: {
                        'patientId': patient.patientId,
                        'patientName': patient.name ?? 'Patient',
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined),
                  title: const Text('Upload Pre-Visit Summary'),
                  subtitle: const Text('Add documents for next visit'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/doctor/upload-previsit',
                      arguments: {
                        'patientId': patient.patientId,
                        'patientName': patient.name ?? 'Patient',
                      },
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.link_off, color: Colors.red[400]),
                  title: Text(
                    'Disconnect Patient',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                  subtitle: const Text('Remove from your patient list'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDisconnect(context, patient);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  void _confirmDisconnect(BuildContext context, AssociatedPatient patient) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Disconnect Patient?'),
            content: Text(
              'Are you sure you want to disconnect ${patient.name ?? 'this patient'}? '
              'You will no longer be able to view their records or communicate with them.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement disconnect API call
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Disconnect feature coming soon'),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Disconnect'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    patient.name?.isNotEmpty == true
                        ? patient.name![0].toUpperCase()
                        : 'P',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name ?? 'Patient',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.cake_outlined,
                            label: '${patient.age ?? '?'} yrs',
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.bloodtype_outlined,
                            label: patient.bloodGroup ?? '?',
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.person_outline,
                            label:
                                patient.gender?.substring(0, 1).toUpperCase() ??
                                '?',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (patient.diagnosis != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.medical_information,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        patient.diagnosis!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Action buttons row 1
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showPatientOptions(context, patient);
                    },
                    icon: const Icon(Icons.more_horiz, size: 18),
                    label: const Text('More'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/doctor/create-care-plan',
                        arguments: {
                          'patientId': patient.patientId,
                          'patientName': patient.name ?? 'Patient',
                        },
                      );
                    },
                    icon: const Icon(Icons.note_add_outlined, size: 18),
                    label: const Text('Care Plan'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/chat/conversation',
                        arguments: {
                          'partnerId': patient.patientId,
                          'partnerType': 'Patient',
                          'partnerName': patient.name ?? 'Patient',
                        },
                      );
                    },
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('Chat'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}

class _ChatsTab extends StatefulWidget {
  @override
  State<_ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<_ChatsTab> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final token = auth.token;

    if (user == null || token == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final chatService = ChatService(
        authToken: token,
        userId: user.id,
        userType: user.role.name,
      );
      final conversations = await chatService.getConversations();
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load conversations: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connect with patients to start chatting',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: conversation.partnerType.toLowerCase() == 'patient'
                              ? Colors.blue[100]
                              : Colors.green[100],
                          child: Text(
                            conversation.partnerName.isNotEmpty
                                ? conversation.partnerName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: conversation.partnerType.toLowerCase() == 'patient'
                                  ? Colors.blue
                                  : Colors.green,
                            ),
                          ),
                        ),
                        title: Text(conversation.partnerName),
                        subtitle: Text(
                          conversation.lastMessageContent ?? 'No messages yet',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: conversation.unreadCount > 0
                            ? CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Text(
                                  conversation.unreadCount.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/chat/conversation',
                            arguments: {
                              'partnerId': conversation.partnerId,
                              'partnerType': conversation.partnerType,
                              'partnerName': conversation.partnerName,
                            },
                          );
                        },
                      );
                    },
                  ),
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
