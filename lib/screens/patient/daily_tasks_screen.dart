import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/care_plan.dart';
import '../../services/api_service.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  CarePlan? _carePlan;
  bool _isLoading = true;
  final Map<String, bool> _medicationCompletion = {};
  final Map<String, bool> _exerciseCompletion = {};

  @override
  void initState() {
    super.initState();
    _loadCarePlan();
  }

  Future<void> _loadCarePlan() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final apiService = ApiService();
      final auth = context.read<AuthProvider>();
      final carePlans = await apiService.getCarePlans(user.id, auth.token!);
      final carePlan = carePlans.isNotEmpty ? carePlans.first : null;
      setState(() {
        _carePlan = carePlan;
        if (_carePlan != null) {
          for (var med in _carePlan!.medications) {
            _medicationCompletion[med.name] = false;
          }
          for (var ex in _carePlan!.exercises) {
            _exerciseCompletion[ex.name] = false;
          }
        }
        _isLoading = false;
      });
    }
  }

  int get _completedTasks {
    return _medicationCompletion.values.where((v) => v).length +
        _exerciseCompletion.values.where((v) => v).length;
  }

  int get _totalTasks {
    return _medicationCompletion.length + _exerciseCompletion.length;
  }

  double get _completionPercentage {
    if (_totalTasks == 0) return 0;
    return (_completedTasks / _totalTasks) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _carePlan == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_outlined,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks available',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('Your care plan will appear here'),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Progress Card
                    Card(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Today\'s Progress',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              width: 120,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: _completionPercentage / 100,
                                    strokeWidth: 12,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _completionPercentage >= 80
                                          ? Colors.green
                                          : _completionPercentage >= 50
                                              ? Colors.orange
                                              : Colors.red,
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${_completionPercentage.toInt()}%',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '$_completedTasks/$_totalTasks',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _completionPercentage == 100
                                  ? 'Great job! All tasks completed!'
                                  : 'Keep going!',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Medications
                    if (_carePlan!.medications.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.medication, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Medications',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._carePlan!.medications.map((med) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: CheckboxListTile(
                            title: Text(med.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dosage: ${med.dosage}'),
                                Text('Frequency: ${med.frequency}'),
                              ],
                            ),
                            value: _medicationCompletion[med.name] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                _medicationCompletion[med.name] = value ?? false;
                              });
                            },
                            secondary: CircleAvatar(
                              backgroundColor:
                                  (_medicationCompletion[med.name] ?? false)
                                      ? Colors.green
                                      : Colors.grey,
                              child: Icon(
                                (_medicationCompletion[med.name] ?? false)
                                    ? Icons.check
                                    : Icons.medication,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    // Exercises
                    if (_carePlan!.exercises.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.fitness_center, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Exercises',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._carePlan!.exercises.map((ex) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: CheckboxListTile(
                            title: Text(ex.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Duration: ${ex.duration}'),
                                Text('Frequency: ${ex.frequency}'),
                              ],
                            ),
                            value: _exerciseCompletion[ex.name] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                _exerciseCompletion[ex.name] = value ?? false;
                              });
                            },
                            secondary: CircleAvatar(
                              backgroundColor:
                                  (_exerciseCompletion[ex.name] ?? false)
                                      ? Colors.green
                                      : Colors.grey,
                              child: Icon(
                                (_exerciseCompletion[ex.name] ?? false)
                                    ? Icons.check
                                    : Icons.fitness_center,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Progress saved successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save Progress',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
    );
  }
}
