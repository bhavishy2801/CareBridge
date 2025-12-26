import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/appointment.dart';
import '../../models/care_plan.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({super.key});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Appointment> _appointments = [];
  List<CarePlan> _carePlans = [];

  late String _doctorId;
  late String _doctorName;
  late String? _specialization;
  late String? _email;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _doctorId = args['doctorId'];
    _doctorName = args['doctorName'] ?? 'Doctor';
    _specialization = args['specialization'];
    _email = args['email'];
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    final user = auth.currentUser;

    if (token == null || user == null) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService(authToken: token);

      // Load appointments for patient
      final appointments = await apiService.getPatientAppointments();
      // Filter appointments for this doctor
      final doctorAppointments =
          appointments.where((a) => a.doctorId == _doctorId).toList();

      // Load care plans
      final carePlans = await apiService.getCarePlans(user.id, token);
      // Filter care plans from this doctor
      final doctorCarePlans =
          carePlans.where((c) => c.doctorId == _doctorId).toList();

      setState(() {
        _appointments = doctorAppointments;
        _carePlans = doctorCarePlans;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading doctor data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. $_doctorName'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Info', icon: Icon(Icons.person)),
            Tab(text: 'Appointments', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Care Plans', icon: Icon(Icons.medical_services)),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildInfoTab(),
                  _buildAppointmentsTab(),
                  _buildCarePlansTab(),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookAppointmentDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Book Appointment'),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Doctor Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.green[100],
            child: Text(
              _doctorName.isNotEmpty ? _doctorName[0].toUpperCase() : 'D',
              style: TextStyle(
                fontSize: 48,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Doctor Name
          Text(
            'Dr. $_doctorName',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Specialization
          if (_specialization != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _specialization!.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Contact Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  if (_email != null)
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.green),
                      title: const Text('Email'),
                      subtitle: Text(_email!),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ListTile(
                    leading: const Icon(Icons.badge, color: Colors.green),
                    title: const Text('Doctor ID'),
                    subtitle: Text(_doctorId),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistics Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your History with Dr. $_doctorName',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.calendar_today,
                        value: _appointments.length.toString(),
                        label: 'Appointments',
                        color: Colors.blue,
                      ),
                      _StatItem(
                        icon: Icons.medical_services,
                        value: _carePlans.length.toString(),
                        label: 'Care Plans',
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.chat, color: Colors.green),
                    title: const Text('Send Message'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat/conversation',
                        arguments: {
                          'partnerId': _doctorId,
                          'partnerType': 'Doctor',
                          'partnerName': _doctorName,
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_month,
                      color: Colors.blue,
                    ),
                    title: const Text('Book Appointment'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showBookAppointmentDialog(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    if (_appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No appointments yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Book your first appointment with Dr. $_doctorName',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showBookAppointmentDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Book Appointment'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return _AppointmentCard(
            appointment: appointment,
            doctorName: _doctorName,
            onViewPrevisit: () => _viewPrevisitForm(appointment),
            onFillPrevisit: () => _fillPrevisitForm(appointment),
          );
        },
      ),
    );
  }

  Widget _buildCarePlansTab() {
    if (_carePlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No care plans yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Dr. $_doctorName will create a care plan after your appointment',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _carePlans.length,
        itemBuilder: (context, index) {
          final carePlan = _carePlans[index];
          return _CarePlanCard(carePlan: carePlan);
        },
      ),
    );
  }

  Future<void> _showBookAppointmentDialog() async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Book Appointment'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Schedule an appointment with Dr. $_doctorName'),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date'),
                        subtitle: Text(
                          DateFormat('MMM dd, yyyy').format(selectedDate),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() => selectedDate = date);
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Time'),
                        subtitle: Text(selectedTime.format(context)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setState(() => selectedTime = time);
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Book'),
                    ),
                  ],
                ),
          ),
    );

    if (result == true) {
      await _bookAppointment(
        DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        ),
      );
    }
  }

  Future<void> _bookAppointment(DateTime dateTime) async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (token == null) return;

    try {
      final apiService = ApiService(authToken: token);
      await apiService.createAppointment(doctorId: _doctorId, date: dateTime);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewPrevisitForm(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PrevisitFormScreen(
              appointmentId: appointment.id,
              doctorName: _doctorName,
              appointmentDate: appointment.date,
              isViewOnly: true,
            ),
      ),
    );
  }

  void _fillPrevisitForm(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PrevisitFormScreen(
              appointmentId: appointment.id,
              doctorName: _doctorName,
              appointmentDate: appointment.date,
              isViewOnly: false,
            ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String doctorName;
  final VoidCallback onViewPrevisit;
  final VoidCallback onFillPrevisit;

  const _AppointmentCard({
    required this.appointment,
    required this.doctorName,
    required this.onViewPrevisit,
    required this.onFillPrevisit,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = appointment.date.isBefore(DateTime.now());
    final isToday = DateUtils.isSameDay(appointment.date, DateTime.now());

    Color statusColor;
    String statusText;
    if (appointment.status == 'completed') {
      statusColor = Colors.green;
      statusText = 'Completed';
    } else if (appointment.status == 'cancelled') {
      statusColor = Colors.red;
      statusText = 'Cancelled';
    } else if (isPast) {
      statusColor = Colors.grey;
      statusText = 'Past';
    } else if (isToday) {
      statusColor = Colors.orange;
      statusText = 'Today';
    } else {
      statusColor = Colors.blue;
      statusText = 'Upcoming';
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'view_previsit') {
                      onViewPrevisit();
                    } else if (value == 'fill_previsit') {
                      onFillPrevisit();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'fill_previsit',
                          child: ListTile(
                            leading: Icon(Icons.edit_note),
                            title: Text('Fill Pre-Visit Form'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'view_previsit',
                          child: ListTile(
                            leading: Icon(Icons.description),
                            title: Text('View Pre-Visit Form'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
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
                const Icon(Icons.access_time, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('hh:mm a').format(appointment.date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (!isPast && appointment.status != 'cancelled') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onFillPrevisit,
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text('Pre-Visit Form'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CarePlanCard extends StatelessWidget {
  final CarePlan carePlan;

  const _CarePlanCard({required this.carePlan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          'Care Plan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          carePlan.createdAt != null
              ? 'Created: ${DateFormat('MMM dd, yyyy').format(carePlan.createdAt!)}'
              : 'Care plan from doctor',
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.medical_services, color: Colors.green[700]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medications
                if (carePlan.medications.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.medication,
                    title: 'Medications',
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  ...carePlan.medications.map(
                    (med) => _DetailItem(
                      title: med.name,
                      subtitle: '${med.dosage} - ${med.frequency}',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Exercises
                if (carePlan.exercises.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.fitness_center,
                    title: 'Exercises',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  ...carePlan.exercises.map(
                    (ex) => _DetailItem(
                      title: ex.name,
                      subtitle: '${ex.duration} - ${ex.frequency}',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Instructions
                if (carePlan.instructions.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.info,
                    title: 'Instructions',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Text(carePlan.instructions),
                  const SizedBox(height: 16),
                ],

                // Warning Signs
                if (carePlan.warningSigns.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.warning,
                    title: 'Warning Signs',
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(carePlan.warningSigns),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _DetailItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Pre-Visit Form Screen
class PrevisitFormScreen extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final DateTime appointmentDate;
  final bool isViewOnly;

  const PrevisitFormScreen({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.appointmentDate,
    this.isViewOnly = false,
  });

  @override
  State<PrevisitFormScreen> createState() => _PrevisitFormScreenState();
}

class _PrevisitFormScreenState extends State<PrevisitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final List<String> _symptoms = [];
  final List<String> _reports = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasExistingForm = false;

  final List<String> _commonSymptoms = [
    'Headache',
    'Fever',
    'Cough',
    'Fatigue',
    'Nausea',
    'Body Pain',
    'Dizziness',
    'Shortness of Breath',
    'Chest Pain',
    'Loss of Appetite',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingForm();
  }

  Future<void> _loadExistingForm() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final apiService = ApiService(authToken: token);
      final form = await apiService.getPrevisitForm(widget.appointmentId);

      if (form != null) {
        setState(() {
          _symptoms.addAll(form.symptoms);
          _reports.addAll(form.reports);
          _hasExistingForm = true;
        });
      }
    } catch (e) {
      print('Error loading previsit form: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveForm() async {
    if (_symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one symptom'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Debug: Print _symptoms and its type
    print('DEBUG: _symptoms runtimeType: \'${_symptoms.runtimeType}\'');
    print('DEBUG: _symptoms value: $_symptoms');

    // Map symptoms to list of objects for API, with default severity
    final symptomsForApi =
        _symptoms.map((s) => {'name': s, 'severity': 5}).toList();

    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (token == null) return;

    setState(() => _isSaving = true);

    try {
      final apiService = ApiService(authToken: token);
      // Debug: Print JSON body
      final jsonBody = {
        'appointmentId': widget.appointmentId,
        'symptoms': symptomsForApi,
        'reports': _reports,
      };
      print('DEBUG: JSON body to be sent: ' + jsonBody.toString());
      await apiService.createPrevisitForm(
        appointmentId: widget.appointmentId,
        symptoms: symptomsForApi,
        reports: _reports,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pre-visit form submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit form: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isSaving = false);
  }

  void _addSymptom(String symptom) {
    if (symptom.isNotEmpty) {
      // Split by comma, trim, and add only unique, non-empty symptoms
      final parts = symptom
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty);
      setState(() {
        for (final part in parts) {
          if (!_symptoms.contains(part)) {
            _symptoms.add(part);
          }
        }
        _symptomsController.clear();
      });
    }
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isViewOnly ? 'View Pre-Visit Form' : 'Pre-Visit Form',
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Appointment Info Card
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Appointment with Dr. ${widget.doctorName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat(
                                'EEEE, MMM dd, yyyy - hh:mm a',
                              ).format(widget.appointmentDate),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Symptoms Section
                    Text(
                      'Symptoms',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select or add symptoms you are experiencing',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),

                    // Common Symptoms Chips
                    if (!widget.isViewOnly)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _commonSymptoms.map((symptom) {
                              final isSelected = _symptoms.contains(symptom);
                              return FilterChip(
                                label: Text(symptom),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _symptoms.add(symptom);
                                    } else {
                                      _symptoms.remove(symptom);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),
                    const SizedBox(height: 12),

                    // Custom Symptom Input
                    if (!widget.isViewOnly)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _symptomsController,
                              decoration: const InputDecoration(
                                hintText: 'Add custom symptom',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: _addSymptom,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: Colors.green,
                            onPressed:
                                () => _addSymptom(_symptomsController.text),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),

                    // Selected Symptoms
                    if (_symptoms.isNotEmpty) ...[
                      const Text(
                        'Selected Symptoms:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _symptoms.map((symptom) {
                              return Chip(
                                label: Text(symptom),
                                deleteIcon:
                                    widget.isViewOnly
                                        ? null
                                        : const Icon(Icons.close, size: 18),
                                onDeleted:
                                    widget.isViewOnly
                                        ? null
                                        : () {
                                          setState(
                                            () => _symptoms.remove(symptom),
                                          );
                                        },
                              );
                            }).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Reports Section (for future file uploads)
                    Text(
                      'Reports / Documents',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload any relevant reports or documents',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),

                    if (!widget.isViewOnly)
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement file upload
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('File upload coming soon!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Report'),
                      ),

                    if (_reports.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...List.generate(
                        _reports.length,
                        (index) => ListTile(
                          leading: const Icon(Icons.description),
                          title: Text('Report ${index + 1}'),
                          subtitle: Text(_reports[index]),
                        ),
                      ),
                    ],

                    if (_reports.isEmpty && widget.isViewOnly)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No reports uploaded'),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Submit Button
                    if (!widget.isViewOnly)
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child:
                            _isSaving
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  _hasExistingForm
                                      ? 'Update Form'
                                      : 'Submit Form',
                                ),
                      ),
                  ],
                ),
              ),
    );
  }
}
