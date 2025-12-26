import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/report.dart';
import '../../services/api_service.dart';
import '../../services/offline_service.dart';
import 'package:image_picker/image_picker.dart';

class SymptomFormScreen extends StatefulWidget {
  const SymptomFormScreen({super.key});

  @override
  State<SymptomFormScreen> createState() => _SymptomFormScreenState();
}

class _SymptomFormScreenState extends State<SymptomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  String _severity = 'Mild';
  final List<String> _attachments = [];
  bool _isSubmitting = false;

  final Map<String, bool> _symptoms = {
    'Fever': false,
    'Cough': false,
    'Fatigue': false,
    'Headache': false,
    'Nausea': false,
    'Chest Pain': false,
    'Shortness of Breath': false,
    'Body Ache': false,
  };

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _attachments.add(image.path);
      });
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final user = context.read<AuthProvider>().currentUser;
        final token = context.read<AuthProvider>().token;
        if (user == null || token == null) return;

        final selectedSymptoms =
            _symptoms.entries
                .where((e) => e.value)
                .map(
                  (e) => Symptom(
                    name: e.key,
                    severity:
                        _severity == 'Mild'
                            ? 3
                            : _severity == 'Moderate'
                            ? 6
                            : 9,
                  ),
                )
                .toList();

        if (_symptomsController.text.trim().isNotEmpty) {
          selectedSymptoms.add(
            Symptom(
              name: 'Other',
              severity:
                  _severity == 'Mild'
                      ? 3
                      : _severity == 'Moderate'
                      ? 6
                      : 9,
            ),
          );
        }

        final report = Report(
          patient: user.id,
          symptoms: selectedSymptoms,
          customMessage:
              _symptomsController.text.trim().isNotEmpty
                  ? _symptomsController.text.trim()
                  : null,
        );

        final apiService = ApiService(authToken: token);
        await apiService.submitReport(report);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Symptoms reported successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Symptoms')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Severity Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Severity Level',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'Mild',
                          label: Text('Mild'),
                          icon: Icon(Icons.sentiment_satisfied),
                        ),
                        ButtonSegment(
                          value: 'Moderate',
                          label: Text('Moderate'),
                          icon: Icon(Icons.sentiment_neutral),
                        ),
                        ButtonSegment(
                          value: 'Severe',
                          label: Text('Severe'),
                          icon: Icon(Icons.sentiment_dissatisfied),
                        ),
                      ],
                      selected: {_severity},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _severity = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Common Symptoms Checklist
            Text(
              'Common Symptoms',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children:
                    _symptoms.keys.map((symptom) {
                      return CheckboxListTile(
                        title: Text(symptom),
                        value: _symptoms[symptom],
                        onChanged: (bool? value) {
                          setState(() {
                            _symptoms[symptom] = value ?? false;
                          });
                        },
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Additional Details
            TextFormField(
              controller: _symptomsController,
              decoration: const InputDecoration(
                labelText: 'Additional Details',
                hintText: 'Describe any other symptoms or concerns',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // Attachments
            Text(
              'Attachments (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_attachments.isNotEmpty)
              Card(
                child: Column(
                  children:
                      _attachments
                          .map(
                            (path) => ListTile(
                              leading: const Icon(Icons.image),
                              title: Text(path.split('/').last),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _attachments.remove(path);
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Photo'),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text(
                        'Submit Report',
                        style: TextStyle(fontSize: 16),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
