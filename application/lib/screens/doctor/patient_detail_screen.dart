import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/appointment.dart';
import '../../models/care_plan.dart';
import '../../models/previsit_form.dart';
import '../../models/daily_log.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Appointment> _appointments = [];
  List<CarePlan> _carePlans = [];
  List<DailyLog> _dailyLogs = [];

  late String _patientId;
  late String _patientName;
  String? _age;
  String? _bloodGroup;
  String? _gender;
  String? _email;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _patientId = args['patientId'];
    _patientName = args['patientName'] ?? 'Patient';
    _age = args['age']?.toString();
    _bloodGroup = args['bloodGroup'];
    _gender = args['gender'];
    _email = args['email'];

    final initialTab = args['initialTab'] as int?;
    if (initialTab != null && initialTab < 4) {
      _tabController.index = initialTab;
    }

    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (token == null) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService(authToken: token);

      // Load appointments for doctor
      final appointments = await apiService.getDoctorAppointments();
      // Filter appointments for this patient
      final patientAppointments =
          appointments.where((a) => a.patientId == _patientId).toList();

      // Load care plans for this patient
      final carePlans = await apiService.getCarePlans(_patientId, token);

      // Load daily logs for this patient
      List<DailyLog> dailyLogs = [];
      try {
        dailyLogs = await apiService.getDailyLogs(_patientId);
      } catch (e) {
        print('Error loading daily logs: $e');
      }

      setState(() {
        _appointments = patientAppointments;
        _carePlans = carePlans;
        _dailyLogs = dailyLogs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading patient data: $e');
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
        title: Text(_patientName),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Info', icon: Icon(Icons.person)),
            Tab(text: 'Appointments', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Pre-Visit Forms', icon: Icon(Icons.description)),
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
                  _buildPrevisitFormsTab(),
                  _buildCarePlansTab(),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCarePlanDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Create Care Plan'),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Patient Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue[100],
            child: Text(
              _patientName.isNotEmpty ? _patientName[0].toUpperCase() : 'P',
              style: TextStyle(
                fontSize: 48,
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Patient Name
          Text(
            _patientName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Patient Info Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (_age != null)
                Chip(
                  avatar: const Icon(Icons.cake, size: 18),
                  label: Text('$_age years'),
                ),
              if (_bloodGroup != null)
                Chip(
                  avatar: const Icon(Icons.bloodtype, size: 18),
                  label: Text(_bloodGroup!),
                ),
              if (_gender != null)
                Chip(
                  avatar: const Icon(Icons.person, size: 18),
                  label: Text(_gender!),
                ),
            ],
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
                    'Patient Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  if (_email != null)
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: const Text('Email'),
                      subtitle: Text(_email!),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ListTile(
                    leading: const Icon(Icons.badge, color: Colors.blue),
                    title: const Text('Patient ID'),
                    subtitle: Text(_patientId),
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
                    'Patient Statistics',
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
                      _StatItem(
                        icon: Icons.note,
                        value: _dailyLogs.length.toString(),
                        label: 'Daily Logs',
                        color: Colors.orange,
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
                    leading: const Icon(Icons.chat, color: Colors.blue),
                    title: const Text('Send Message'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat/conversation',
                        arguments: {
                          'partnerId': _patientId,
                          'partnerType': 'Patient',
                          'partnerName': _patientName,
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.note_add, color: Colors.green),
                    title: const Text('Create Care Plan'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showCreateCarePlanDialog(),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_month,
                      color: Colors.orange,
                    ),
                    title: const Text('View Daily Logs'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _tabController.animateTo(3);
                    },
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
              'No appointments scheduled with $_patientName',
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
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return _AppointmentCard(
            appointment: appointment,
            patientName: _patientName,
            onViewPrevisit: () => _viewPrevisitForm(appointment),
          );
        },
      ),
    );
  }

  Widget _buildPrevisitFormsTab() {
    // Show previsit forms for appointments
    final appointmentsWithForms = _appointments;

    if (appointmentsWithForms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No pre-visit forms',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Pre-visit forms will appear here when $_patientName fills them',
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
        itemCount: appointmentsWithForms.length,
        itemBuilder: (context, index) {
          final appointment = appointmentsWithForms[index];
          return _PrevisitCard(
            appointment: appointment,
            patientName: _patientName,
            onView: () => _viewPrevisitForm(appointment),
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
              'Create a care plan for $_patientName',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateCarePlanDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Create Care Plan'),
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

  void _viewPrevisitForm(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ViewPrevisitFormScreen(
              appointmentId: appointment.id,
              patientName: _patientName,
              appointmentDate: appointment.date,
            ),
      ),
    );
  }

  void _showCreateCarePlanDialog() {
    Navigator.pushNamed(
      context,
      '/doctor/create-care-plan',
      arguments: {'patientId': _patientId, 'patientName': _patientName},
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
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String patientName;
  final VoidCallback onViewPrevisit;

  const _AppointmentCard({
    required this.appointment,
    required this.patientName,
    required this.onViewPrevisit,
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
                IconButton(
                  icon: const Icon(Icons.description),
                  tooltip: 'View Pre-Visit Form',
                  onPressed: onViewPrevisit,
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
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onViewPrevisit,
              icon: const Icon(Icons.description, size: 18),
              label: const Text('View Pre-Visit Form'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrevisitCard extends StatelessWidget {
  final Appointment appointment;
  final String patientName;
  final VoidCallback onView;

  const _PrevisitCard({
    required this.appointment,
    required this.patientName,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple[100],
          child: Icon(Icons.description, color: Colors.purple[700]),
        ),
        title: Text(
          'Appointment: ${DateFormat('MMM dd, yyyy').format(appointment.date)}',
        ),
        subtitle: Text(
          'Time: ${DateFormat('hh:mm a').format(appointment.date)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onView,
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
        title: const Text(
          'Care Plan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          carePlan.createdAt != null
              ? 'Created: ${DateFormat('MMM dd, yyyy').format(carePlan.createdAt!)}'
              : 'Care plan',
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

// View Pre-visit Form Screen (Doctor's view)
class ViewPrevisitFormScreen extends StatefulWidget {
  final String appointmentId;
  final String patientName;
  final DateTime appointmentDate;

  const ViewPrevisitFormScreen({
    super.key,
    required this.appointmentId,
    required this.patientName,
    required this.appointmentDate,
  });

  @override
  State<ViewPrevisitFormScreen> createState() => _ViewPrevisitFormScreenState();
}

class _ViewPrevisitFormScreenState extends State<ViewPrevisitFormScreen> {
  bool _isLoading = true;
  PrevisitForm? _form;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Not authenticated';
      });
      return;
    }

    try {
      final apiService = ApiService(authToken: token);
      final form = await apiService.getPrevisitForm(widget.appointmentId);

      setState(() {
        _form = form;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading previsit form: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load form';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Visit Form')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _form == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pre-visit form submitted',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.patientName} has not submitted a pre-visit form\nfor this appointment yet.',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView(
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
                                'Appointment with ${widget.patientName}',
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
                    'Reported Symptoms',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_form!.symptoms.isEmpty)
                    const Text('No symptoms reported')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _form!.symptoms.map((symptom) {
                            return Chip(
                              label: Text(symptom),
                              backgroundColor: Colors.orange[100],
                            );
                          }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // Reports Section
                  Text(
                    'Uploaded Reports',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_form!.reports.isEmpty)
                    const Text('No reports uploaded')
                  else
                    ...List.generate(
                      _form!.reports.length,
                      (index) => ListTile(
                        leading: const Icon(Icons.description),
                        title: Text('Report ${index + 1}'),
                        subtitle: Text(_form!.reports[index]),
                      ),
                    ),

                  if (_form!.createdAt != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Submitted on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(_form!.createdAt!)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
    );
  }
}
