import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/care_plan.dart';
import '../../services/api_service.dart';
import '../../services/pdf_service.dart';

class CarePlanViewScreen extends StatefulWidget {
  const CarePlanViewScreen({super.key});

  @override
  State<CarePlanViewScreen> createState() => _CarePlanViewScreenState();
}

class _CarePlanViewScreenState extends State<CarePlanViewScreen> {
  CarePlan? _carePlan;
  bool _isLoading = true;

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
      final carePlans = await apiService.getCarePlans(user.id,auth.token!,);
      final carePlan = carePlans.isNotEmpty ? carePlans.first : null;
      setState(() {
        _carePlan = carePlan;
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePdf() async {
    if (_carePlan != null) {
      final user = context.read<AuthProvider>().currentUser;
      final pdfService = PdfService();
      try {
        await pdfService.generateCarePlanPdf(_carePlan!, user?.name ?? 'Patient');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF generated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error generating PDF: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Care Plan'),
        actions: [
          if (_carePlan != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generatePdf,
              tooltip: 'Download PDF',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _carePlan == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_information_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No care plan available',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your doctor will create a care plan for you',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCarePlan,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Care Plan Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Care Plan',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Created: ${_carePlan!.createdAt.toString().split(' ')[0]}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Medications
                      Text(
                        'Medications',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (_carePlan!.medications.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No medications prescribed'),
                          ),
                        )
                      else
                        ..._carePlan!.medications.map(
                          (med) => Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.medication),
                              ),
                              title: Text(med.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dosage: ${med.dosage}'),
                                  Text('Frequency: ${med.frequency}'),
                                  if (med.duration != null)
                                    Text('Duration: ${med.duration}'),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Exercises
                      Text(
                        'Exercises',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (_carePlan!.exercises.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No exercises recommended'),
                          ),
                        )
                      else
                        ..._carePlan!.exercises.map(
                          (ex) => Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.fitness_center),
                              ),
                              title: Text(ex.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Duration: ${ex.duration}'),
                                  Text('Frequency: ${ex.frequency}'),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Instructions
                      if (_carePlan!.instructions.isNotEmpty) ...[
                        Text(
                          'General Instructions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _carePlan!.instructions
                                  .split('\n')
                                  .where((line) => line.trim().isNotEmpty)
                                  .map(
                                    (instruction) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('• '),
                                          Expanded(child: Text(instruction)),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
