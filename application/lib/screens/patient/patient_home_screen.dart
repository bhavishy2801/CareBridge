import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/care_plan.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/chat_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  CarePlan? _carePlan;
  bool _isLoading = true;
  int _currentIndex = 0;
  Map<String, Conversation> _doctorConversations = {};

  @override
  void initState() {
    super.initState();
    _loadCarePlan();
    _refreshProfile();
    _loadDoctorNames();
  }

  Future<void> _loadDoctorNames() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final token = auth.token;

    if (user == null || token == null) return;

    try {
      final chatService = ChatService(
        authToken: token,
        userId: user.id,
        userType: user.role.name,
      );
      final conversations = await chatService.getConversations();
      setState(() {
        _doctorConversations = {for (var c in conversations) c.partnerId: c};
      });
    } catch (e) {
      print('Failed to load doctor names: $e');
    }
  }

  Future<void> _refreshProfile() async {
    final auth = context.read<AuthProvider>();
    await auth.refreshUser();
  }

  Future<void> _loadCarePlan() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final apiService = ApiService();
      final auth = context.read<AuthProvider>();
      try {
        final carePlans = await apiService.getCarePlans(user.id, auth.token!);
        final carePlan = carePlans.isNotEmpty ? carePlans.first : null;
        setState(() {
          _carePlan = carePlan;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [_buildHomeTab(), _buildDoctorsTab(), _buildChatsTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: 'Doctors',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chats',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health'),
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
              Navigator.pushNamed(context, '/patient-notifications');
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
      body: RefreshIndicator(
        onRefresh: _loadCarePlan,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        child: Text(
                          user?.name[0].toUpperCase() ?? 'P',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user?.name ?? 'Patient'}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            const Text('How are you feeling today?'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.edit_note,
                      title: 'Report Symptoms',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(context, '/patient/symptom-form');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.medical_information,
                      title: 'My Care Plan',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, '/patient/care-plan');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.check_circle,
                      title: 'Daily Tasks',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pushNamed(context, '/patient/tasks');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.qr_code,
                      title: 'My QR Code',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Today's Care Plan Summary
              if (_carePlan != null) ...[
                Text(
                  'Today\'s Schedule',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      if (_carePlan!.medications.isNotEmpty)
                        ListTile(
                          leading: const Icon(
                            Icons.medication,
                            color: Colors.red,
                          ),
                          title: Text(
                            '${_carePlan!.medications.length} Medications',
                          ),
                          subtitle: const Text('Tap to view details'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(context, '/patient/care-plan');
                          },
                        ),
                      if (_carePlan!.exercises.isNotEmpty)
                        ListTile(
                          leading: const Icon(
                            Icons.fitness_center,
                            color: Colors.blue,
                          ),
                          title: Text(
                            '${_carePlan!.exercises.length} Exercises',
                          ),
                          subtitle: const Text('Tap to view details'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(context, '/patient/care-plan');
                          },
                        ),
                    ],
                  ),
                ),
              ],

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsTab() {
    final user = context.watch<AuthProvider>().currentUser;
    final doctors = user?.associatedDoctors ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('My Doctors')),
      body:
          doctors.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No doctors yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Show your QR code to a doctor\nto get connected',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Show My QR Code'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadDoctorNames,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    // Get the actual name from conversations if available
                    final conversation = _doctorConversations[doctor.doctorId];
                    final doctorName = conversation?.partnerName ?? doctor.name;
                    return _DoctorCard(doctor: doctor, doctorName: doctorName);
                  },
                ),
              ),
    );
  }

  Widget _buildChatsTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const _ChatListWidget(),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final AssociatedDoctor doctor;
  final String? doctorName;

  const _DoctorCard({required this.doctor, this.doctorName});

  @override
  Widget build(BuildContext context) {
    final displayName = doctorName ?? doctor.name ?? 'Doctor';

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
                  backgroundColor: Colors.green[100],
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'D',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.green[700],
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
                        'Dr. $displayName',
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
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          doctor.specialization
                                  ?.replaceAll('_', ' ')
                                  .toUpperCase() ??
                              'SPECIALIST',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Hamburger Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'book_appointment':
                        _showBookAppointmentDialog(context, displayName);
                        break;
                      case 'view_appointments':
                        Navigator.pushNamed(
                          context,
                          '/patient/doctor-detail',
                          arguments: {
                            'doctorId': doctor.doctorId,
                            'doctorName': displayName,
                            'specialization': doctor.specialization,
                            'email': doctor.email,
                            'initialTab': 1, // Appointments tab
                          },
                        );
                        break;
                      case 'view_care_plans':
                        Navigator.pushNamed(
                          context,
                          '/patient/doctor-detail',
                          arguments: {
                            'doctorId': doctor.doctorId,
                            'doctorName': displayName,
                            'specialization': doctor.specialization,
                            'email': doctor.email,
                            'initialTab': 2, // Care Plans tab
                          },
                        );
                        break;
                      case 'previsit_form':
                        Navigator.pushNamed(
                          context,
                          '/patient/doctor-detail',
                          arguments: {
                            'doctorId': doctor.doctorId,
                            'doctorName': displayName,
                            'specialization': doctor.specialization,
                            'email': doctor.email,
                            'initialTab':
                                1, // Appointments tab to fill previsit
                          },
                        );
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'book_appointment',
                          child: ListTile(
                            leading: Icon(
                              Icons.calendar_month,
                              color: Colors.blue,
                            ),
                            title: Text('Book Appointment'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'view_appointments',
                          child: ListTile(
                            leading: Icon(
                              Icons.event_note,
                              color: Colors.orange,
                            ),
                            title: Text('View Appointments'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'view_care_plans',
                          child: ListTile(
                            leading: Icon(
                              Icons.medical_services,
                              color: Colors.green,
                            ),
                            title: Text('View Care Plans'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'previsit_form',
                          child: ListTile(
                            leading: Icon(
                              Icons.edit_note,
                              color: Colors.purple,
                            ),
                            title: Text('Pre-Visit Forms'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/patient/doctor-detail',
                        arguments: {
                          'doctorId': doctor.doctorId,
                          'doctorName': displayName,
                          'specialization': doctor.specialization,
                          'email': doctor.email,
                        },
                      );
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/chat/conversation',
                        arguments: {
                          'partnerId': doctor.doctorId,
                          'partnerType': 'Doctor',
                          'partnerName': displayName,
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

  void _showBookAppointmentDialog(
    BuildContext context,
    String doctorName,
  ) async {
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
                      Text('Schedule an appointment with Dr. $doctorName'),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date'),
                        subtitle: Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
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

    if (result == true && context.mounted) {
      final dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      await _bookAppointment(context, dateTime);
    }
  }

  Future<void> _bookAppointment(BuildContext context, DateTime dateTime) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;

    if (token == null) return;

    try {
      final apiService = ApiService(authToken: token);
      await apiService.createAppointment(
        doctorId: doctor.doctorId,
        date: dateTime,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ChatListWidget extends StatefulWidget {
  const _ChatListWidget();

  @override
  State<_ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<_ChatListWidget> {
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with doctors to start chatting',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  conversation.partnerType.toLowerCase() == 'doctor'
                      ? Colors.green[100]
                      : Colors.blue[100],
              child: Text(
                conversation.partnerName.isNotEmpty
                    ? conversation.partnerName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color:
                      conversation.partnerType.toLowerCase() == 'doctor'
                          ? Colors.green
                          : Colors.blue,
                ),
              ),
            ),
            title: Text(
              conversation.partnerType.toLowerCase() == 'doctor'
                  ? 'Dr. ${conversation.partnerName}'
                  : conversation.partnerName,
            ),
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
    );
  }
}
