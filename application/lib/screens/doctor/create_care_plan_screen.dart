import 'package:flutter/material.dart';
import '../../models/patient_summary.dart';
import '../../models/care_plan.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class CreateCarePlanScreen extends StatefulWidget {
  final PatientSummary patient;

  const CreateCarePlanScreen({super.key, required this.patient});

  @override
  State<CreateCarePlanScreen> createState() => _CreateCarePlanScreenState();
}

class _CreateCarePlanScreenState extends State<CreateCarePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Medication> _medications = [];
  final List<Exercise> _exercises = [];
  final List<String> _instructions = [];
  bool _isSubmitting = false;

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final dosageController = TextEditingController();
        final frequencyController = TextEditingController();
        final durationController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Medication'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Medication Name'),
                ),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(labelText: 'Dosage (e.g., 100mg)'),
                ),
                TextField(
                  controller: frequencyController,
                  decoration: const InputDecoration(labelText: 'Frequency (e.g., Once daily)'),
                ),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Duration (e.g., 30 days)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    dosageController.text.isNotEmpty &&
                    frequencyController.text.isNotEmpty) {
                  setState(() {
                    _medications.add(Medication(
                      name: nameController.text,
                      dosage: dosageController.text,
                      frequency: frequencyController.text,
                      duration: durationController.text.isEmpty
                          ? null
                          : durationController.text,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final durationController = TextEditingController();
        final frequencyController = TextEditingController(text: 'Daily');

        return AlertDialog(
          title: const Text('Add Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Exercise Name'),
                ),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Duration (e.g., 30 minutes)'),
                ),
                TextField(
                  controller: frequencyController,
                  decoration: const InputDecoration(labelText: 'Frequency (e.g., Daily)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    durationController.text.isNotEmpty) {
                  setState(() {
                    _exercises.add(Exercise(
                      name: nameController.text,
                      duration: durationController.text,
                      frequency: frequencyController.text,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addInstruction() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();

        return AlertDialog(
          title: const Text('Add Instruction'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Instruction'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _instructions.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitCarePlan() async {
    if (_medications.isEmpty && _exercises.isEmpty && _instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one item to the care plan')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = AuthService();
      final token = await authService.getToken();
      
      final apiService = ApiService(authToken: token);
      await apiService.createCarePlan(
        appointmentId: widget.patient.lastAppointmentId,
        patientId: widget.patient.patientId,
        medications: _medications.map((m) => m.toJson()).toList(),
        exercises: _exercises.map((e) => e.toJson()).toList(),
        instructions: _instructions.join('\\n'), // Convert list to string
        warningSigns: 'Contact doctor if symptoms worsen', // Add default or make it a form field
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Care plan created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Care Plan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Patient Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient: ${widget.patient.patientName}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('Severity: ${widget.patient.severity}'),
                    Text('Symptoms: ${widget.patient.keySymptoms.join(", ")}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Medications Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addMedication,
                ),
              ],
            ),
            if (_medications.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No medications added'),
                ),
              )
            else
              ..._medications.asMap().entries.map((entry) {
                final index = entry.key;
                final med = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(med.name),
                    subtitle: Text('${med.dosage} - ${med.frequency}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _medications.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),

            // Exercises Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercises',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addExercise,
                ),
              ],
            ),
            if (_exercises.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No exercises added'),
                ),
              )
            else
              ..._exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final ex = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(ex.name),
                    subtitle: Text(ex.duration),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _exercises.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),

            // Instructions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addInstruction,
                ),
              ],
            ),
            if (_instructions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No instructions added'),
                ),
              )
            else
              ..._instructions.asMap().entries.map((entry) {
                final index = entry.key;
                final instruction = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(instruction),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _instructions.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitCarePlan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Care Plan', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper screen that reads arguments from route and creates a PatientSummary
class CreateCarePlanFromArgsScreen extends StatelessWidget {
  const CreateCarePlanFromArgsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    
    // If we have route arguments (from patient card)
    if (args is Map<String, dynamic>) {
      final patientId = args['patientId'] as String? ?? '';
      final patientName = args['patientName'] as String? ?? 'Patient';
      
      // Create a minimal PatientSummary for the care plan screen
      final patient = PatientSummary(
        patientId: patientId,
        patientName: patientName,
        lastReportDate: DateTime.now(),
        severity: 'Unknown',
        timeline: 'Ongoing',
        keySymptoms: [],
        needsConsultation: false,
      );
      
      return CreateCarePlanScreen(patient: patient);
    }
    
    // If we have a PatientSummary directly
    if (args is PatientSummary) {
      return CreateCarePlanScreen(patient: args);
    }
    
    // Fallback - show error
    return Scaffold(
      appBar: AppBar(title: const Text('Create Care Plan')),
      body: const Center(
        child: Text('Error: No patient information provided'),
      ),
    );
  }
}
