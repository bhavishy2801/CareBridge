import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/care_plan.dart';
import '../../services/api_service.dart';

/// ----------------------------
/// MODEL USED ONLY FOR UI
/// ----------------------------
class DailyTask {
  final String id;
  final String name;
  final String type; // medication | exercise
  final String doctorName;
  final String details;

  DailyTask({
    required this.id,
    required this.name,
    required this.type,
    required this.doctorName,
    required this.details,
  });
}

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  bool _isLoading = true;

  /// All tasks for today grouped by doctor
  final Map<String, List<DailyTask>> _tasksByDoctor = {};

  /// FRONTEND-ONLY completion state
  final Map<String, bool> _completion = {};

  @override
  void initState() {
    super.initState();
    _loadTodayTasks();
  }

  /// ----------------------------
  /// FREQUENCY MATCHER
  /// ----------------------------
  bool _isForToday(String frequency) {
    final weekday =
        [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday',
          'sunday',
        ][DateTime.now().weekday - 1];

    final freq = frequency.toLowerCase().trim();
    if (freq == 'daily') return true;
    return freq.contains(weekday);
  }

  /// ----------------------------
  /// LOAD + TRANSFORM DATA
  /// ----------------------------
  Future<void> _loadTodayTasks() async {
    final user = context.read<AuthProvider>().currentUser;
    final token = context.read<AuthProvider>().token;

    if (user == null || token == null) return;

    final apiService = ApiService();
    final carePlans = await apiService.getCarePlans(user.id, token);

    final Map<String, List<DailyTask>> grouped = {};

    for (final plan in carePlans) {
      final doctor = plan.doctorName ?? 'Unknown Doctor';

      for (final med in plan.medications) {
        if (_isForToday(med.frequency)) {
          final task = DailyTask(
            id: 'med-${plan.id}-${med.name}',
            name: med.name,
            type: 'medication',
            doctorName: doctor,
            details: '${med.dosage} • ${med.frequency}',
          );
          grouped.putIfAbsent(doctor, () => []).add(task);
          _completion[task.id] = false;
        }
      }

      for (final ex in plan.exercises) {
        if (_isForToday(ex.frequency)) {
          final task = DailyTask(
            id: 'ex-${plan.id}-${ex.name}',
            name: ex.name,
            type: 'exercise',
            doctorName: doctor,
            details: '${ex.duration} • ${ex.frequency}',
          );
          grouped.putIfAbsent(doctor, () => []).add(task);
          _completion[task.id] = false;
        }
      }
    }

    setState(() {
      _tasksByDoctor.clear();
      _tasksByDoctor.addAll(grouped);
      _isLoading = false;
    });
  }

  /// ----------------------------
  /// PROGRESS METRICS
  /// ----------------------------
  int get _completed => _completion.values.where((v) => v).length;

  int get _total => _completion.length;

  double get _progress => _total == 0 ? 0 : _completed / _total;

  /// ----------------------------
  /// UI
  /// ----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Plan')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tasksByDoctor.isEmpty
              ? _emptyState()
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _progressCard(),
                  const SizedBox(height: 24),
                  ..._tasksByDoctor.entries.map(
                    (entry) =>
                        _doctorSection(doctor: entry.key, tasks: entry.value),
                  ),
                ],
              ),
    );
  }

  /// ----------------------------
  /// COMPONENTS
  /// ----------------------------
  Widget _progressCard() {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Today's Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              width: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[300],
                  ),
                  Center(
                    child: Text(
                      '${(_progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('$_completed / $_total completed'),
          ],
        ),
      ),
    );
  }

  Widget _doctorSection({
    required String doctor,
    required List<DailyTask> tasks,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dr. $doctor', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _taskCard(tasks[index]);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _taskCard(DailyTask task) {
    final isMed = task.type == 'medication';

    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isMed ? Colors.red[50] : Colors.blue[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isMed ? Icons.medication : Icons.fitness_center,
                color: isMed ? Colors.red : Colors.blue,
              ),
              const Spacer(),
              Checkbox(
                value: _completion[task.id],
                onChanged: (v) {
                  setState(() {
                    _completion[task.id] = v ?? false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(task.details),
          const Spacer(),
          Text(
            task.doctorName,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text('No tasks for today', style: TextStyle(fontSize: 18)),
    );
  }
}
