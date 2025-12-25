import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/patient_summary.dart';
import '../../models/user.dart';
import '../../models/appointment.dart';
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
          _AppointmentsTab(),
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
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Appointments',
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

class _PatientsTab extends StatefulWidget {
  final VoidCallback? onScanQr;

  const _PatientsTab({this.onScanQr});

  @override
  State<_PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends State<_PatientsTab> {
  Map<String, String> _patientNames = {};
  bool _isLoadingNames = true;

  @override
  void initState() {
    super.initState();
    _loadPatientNames();
  }

  Future<void> _loadPatientNames() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final token = auth.token;

    if (user == null || token == null) {
      setState(() => _isLoadingNames = false);
      return;
    }

    try {
      final chatService = ChatService(
        authToken: token,
        userId: user.id,
        userType: user.role.name,
      );
      final conversations = await chatService.getConversations();

      // Build a map of partnerId -> partnerName
      final names = <String, String>{};
      for (final conv in conversations) {
        names[conv.partnerId] = conv.partnerName;
      }

      setState(() {
        _patientNames = names;
        _isLoadingNames = false;
      });
    } catch (e) {
      print('Failed to load patient names: $e');
      setState(() => _isLoadingNames = false);
    }
  }

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
                widget.onScanQr ??
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
                          widget.onScanQr ??
                          () {
                            Navigator.pushNamed(context, '/doctor/scan-qr');
                          },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR Code'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadPatientNames,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    // Get name from conversations API or fall back to stored name
                    final actualName =
                        _patientNames[patient.patientId] ??
                        patient.name ??
                        'Patient';
                    return _PatientCard(
                      patient: patient,
                      patientName: actualName,
                      isLoadingName: _isLoadingNames,
                    );
                  },
                ),
              ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final AssociatedPatient patient;
  final String patientName;
  final bool isLoadingName;

  const _PatientCard({
    required this.patient,
    required this.patientName,
    this.isLoadingName = false,
  });

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
                        'patientName': patientName,
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
                        'patientName': patientName,
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
                        'patientName': patientName,
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
              'Are you sure you want to disconnect $patientName? '
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
                    patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
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
                      Row(
                        children: [
                          Expanded(
                            child:
                                isLoadingName
                                    ? const SizedBox(
                                      height: 20,
                                      width: 100,
                                      child: LinearProgressIndicator(),
                                    )
                                    : Text(
                                      patientName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                          // Hamburger menu
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              switch (value) {
                                case 'details':
                                  Navigator.pushNamed(
                                    context,
                                    '/doctor/patient-detail',
                                    arguments: {
                                      'patientId': patient.patientId,
                                      'patientName': patientName,
                                      'age': patient.age,
                                      'bloodGroup': patient.bloodGroup,
                                      'gender': patient.gender,
                                      'email': patient.email,
                                    },
                                  );
                                  break;
                                case 'appointments':
                                  Navigator.pushNamed(
                                    context,
                                    '/doctor/patient-detail',
                                    arguments: {
                                      'patientId': patient.patientId,
                                      'patientName': patientName,
                                      'age': patient.age,
                                      'bloodGroup': patient.bloodGroup,
                                      'gender': patient.gender,
                                      'email': patient.email,
                                      'initialTab': 1, // Appointments tab
                                    },
                                  );
                                  break;
                                case 'previsit':
                                  Navigator.pushNamed(
                                    context,
                                    '/doctor/patient-detail',
                                    arguments: {
                                      'patientId': patient.patientId,
                                      'patientName': patientName,
                                      'age': patient.age,
                                      'bloodGroup': patient.bloodGroup,
                                      'gender': patient.gender,
                                      'email': patient.email,
                                      'initialTab': 2, // Pre-Visit Forms tab
                                    },
                                  );
                                  break;
                                case 'careplan':
                                  Navigator.pushNamed(
                                    context,
                                    '/doctor/patient-detail',
                                    arguments: {
                                      'patientId': patient.patientId,
                                      'patientName': patientName,
                                      'age': patient.age,
                                      'bloodGroup': patient.bloodGroup,
                                      'gender': patient.gender,
                                      'email': patient.email,
                                      'initialTab': 3, // Care Plans tab
                                    },
                                  );
                                  break;
                                case 'logs':
                                  Navigator.pushNamed(
                                    context,
                                    '/doctor/patient-logs',
                                    arguments: {
                                      'patientId': patient.patientId,
                                      'patientName': patientName,
                                    },
                                  );
                                  break;
                              }
                            },
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'details',
                                    child: ListTile(
                                      leading: Icon(Icons.person),
                                      title: Text('View Details'),
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'appointments',
                                    child: ListTile(
                                      leading: Icon(Icons.calendar_today),
                                      title: Text('View Appointments'),
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'previsit',
                                    child: ListTile(
                                      leading: Icon(Icons.description),
                                      title: Text('Pre-Visit Forms'),
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'careplan',
                                    child: ListTile(
                                      leading: Icon(Icons.medical_services),
                                      title: Text('Care Plans'),
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'logs',
                                    child: ListTile(
                                      leading: Icon(Icons.note),
                                      title: Text('Daily Logs'),
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                    ),
                                  ),
                                ],
                          ),
                        ],
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
            // Action buttons row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/doctor/patient-detail',
                        arguments: {
                          'patientId': patient.patientId,
                          'patientName': patientName,
                          'age': patient.age,
                          'bloodGroup': patient.bloodGroup,
                          'gender': patient.gender,
                          'email': patient.email,
                        },
                      );
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Details'),
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
                          'patientName': patientName,
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
                          'partnerName': patientName,
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

class _AppointmentsTab extends StatefulWidget {
  @override
  State<_AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<_AppointmentsTab> {
  List<Appointment> _appointments = [];
  Map<String, String> _patientNames = {};
  bool _isLoading = true;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    final user = auth.currentUser;

    if (token == null || user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final apiService = ApiService(authToken: token);
      final appointments = await apiService.getDoctorAppointments();

      // Load patient names from conversations
      final chatService = ChatService(
        authToken: token,
        userId: user.id,
        userType: user.role.name,
      );
      final conversations = await chatService.getConversations();

      final names = <String, String>{};
      for (final conv in conversations) {
        names[conv.partnerId] = conv.partnerName;
      }

      setState(() {
        _appointments = appointments;
        _patientNames = names;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Appointment> get _filteredAppointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_filter) {
      case 'Today':
        return _appointments.where((a) {
          final appDate = DateTime(a.date.year, a.date.month, a.date.day);
          return appDate.isAtSameMomentAs(today);
        }).toList();
      case 'Upcoming':
        return _appointments.where((a) => a.date.isAfter(now)).toList();
      case 'Past':
        return _appointments.where((a) => a.date.isBefore(now)).toList();
      default:
        return _appointments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: Column(
        children: [
          // Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'All', label: Text('All')),
                  ButtonSegment(value: 'Today', label: Text('Today')),
                  ButtonSegment(value: 'Upcoming', label: Text('Upcoming')),
                  ButtonSegment(value: 'Past', label: Text('Past')),
                ],
                selected: {_filter},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _filter = newSelection.first;
                  });
                },
              ),
            ),
          ),

          // Appointments List
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredAppointments.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No $_filter appointments',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Appointments will appear here when patients book',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _filteredAppointments[index];
                          final patientName =
                              _patientNames[appointment.patientId] ?? 'Patient';
                          return _AppointmentCard(
                            appointment: appointment,
                            patientName: patientName,
                            onViewPatient: () {
                              Navigator.pushNamed(
                                context,
                                '/doctor/patient-detail',
                                arguments: {
                                  'patientId': appointment.patientId,
                                  'patientName': patientName,
                                },
                              );
                            },
                            onViewPrevisit: () {
                              Navigator.pushNamed(
                                context,
                                '/doctor/patient-detail',
                                arguments: {
                                  'patientId': appointment.patientId,
                                  'patientName': patientName,
                                  'initialTab': 2, // Pre-Visit Forms tab
                                },
                              );
                            },
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

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String patientName;
  final VoidCallback onViewPatient;
  final VoidCallback onViewPrevisit;

  const _AppointmentCard({
    required this.appointment,
    required this.patientName,
    required this.onViewPatient,
    required this.onViewPrevisit,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = appointment.date.isBefore(DateTime.now());
    final isToday = DateUtils.isSameDay(appointment.date, DateTime.now());

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (appointment.status == 'completed') {
      statusColor = Colors.green;
      statusText = 'Completed';
      statusIcon = Icons.check_circle;
    } else if (appointment.status == 'cancelled') {
      statusColor = Colors.red;
      statusText = 'Cancelled';
      statusIcon = Icons.cancel;
    } else if (isPast) {
      statusColor = Colors.grey;
      statusText = 'Past';
      statusIcon = Icons.history;
    } else if (isToday) {
      statusColor = Colors.orange;
      statusText = 'Today';
      statusIcon = Icons.today;
    } else {
      statusColor = Colors.blue;
      statusText = 'Upcoming';
      statusIcon = Icons.event;
    }

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
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'patient':
                        onViewPatient();
                        break;
                      case 'previsit':
                        onViewPrevisit();
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'patient',
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text('View Patient'),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'previsit',
                          child: ListTile(
                            leading: Icon(Icons.description),
                            title: Text('Pre-Visit Form'),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(appointment.date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  DateFormat('hh:mm a').format(appointment.date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewPrevisit,
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('Pre-Visit Form'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewPatient,
                    icon: const Icon(Icons.person, size: 18),
                    label: const Text('View Patient'),
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
      body:
          _isLoading
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
                        backgroundColor:
                            conversation.partnerType.toLowerCase() == 'patient'
                                ? Colors.blue[100]
                                : Colors.green[100],
                        child: Text(
                          conversation.partnerName.isNotEmpty
                              ? conversation.partnerName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color:
                                conversation.partnerType.toLowerCase() ==
                                        'patient'
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
                      trailing:
                          conversation.unreadCount > 0
                              ? CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Text(
                                  conversation.unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
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
