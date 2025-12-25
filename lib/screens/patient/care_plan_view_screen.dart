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
  Map<String, List<CarePlan>> _groupedCarePlans = {};
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
      final carePlans = await apiService.getCarePlans(user.id, auth.token!);

      // Group care plans by doctor
      final Map<String, List<CarePlan>> groupedCarePlans = {};
      for (var plan in carePlans) {
        final doctorName = plan.doctorId ?? 'Unknown Doctor';
        groupedCarePlans.putIfAbsent(doctorName, () => []).add(plan);
      }

      setState(() {
        _groupedCarePlans = groupedCarePlans;
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePdf() async {
    if (_groupedCarePlans.isNotEmpty) {
      final user = context.read<AuthProvider>().currentUser;
      final pdfService = PdfService();
      try {
        for (var carePlanList in _groupedCarePlans.values) {
          for (var carePlan in carePlanList) {
            await pdfService.generateCarePlanPdf(
              carePlan,
              user?.name ?? 'Patient',
            );
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDFs generated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error generating PDFs: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Care Plans')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : DefaultTabController(
                length: _groupedCarePlans.keys.length,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabs:
                          _groupedCarePlans.keys
                              .map((doctorName) => Tab(text: doctorName))
                              .toList(),
                    ),
                    Expanded(
                      child: TabBarView(
                        children:
                            _groupedCarePlans.keys.map((doctorName) {
                              final plans = _groupedCarePlans[doctorName]!;
                              return ListView.builder(
                                itemCount: plans.length,
                                itemBuilder: (context, index) {
                                  final plan = plans[index];
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Care Plan ${index + 1}',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleLarge,
                                          ),
                                          const SizedBox(height: 8),
                                          Text('Created: ${plan.createdAt}'),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Medications',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                          ),
                                          ...plan.medications.map(
                                            (med) => ListTile(
                                              leading: const Icon(
                                                Icons.medication,
                                              ),
                                              title: Text(med.name),
                                              subtitle: Text(
                                                'Dosage: ${med.dosage}, Frequency: ${med.frequency}, Duration: ${med.duration}',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Exercises',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                          ),
                                          ...plan.exercises.map(
                                            (ex) => ListTile(
                                              leading: const Icon(
                                                Icons.fitness_center,
                                              ),
                                              title: Text(ex.name),
                                              subtitle: Text(
                                                'Duration: ${ex.duration}, Frequency: ${ex.frequency}',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Instructions',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                          ),
                                          Text(plan.instructions),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Warning Signs',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                          ),
                                          Text(plan.warningSigns),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
