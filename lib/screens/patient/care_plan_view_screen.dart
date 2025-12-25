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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCarePlan();
  }

  Future<void> _loadCarePlan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        final apiService = ApiService();
        final auth = context.read<AuthProvider>();

        print('🔄 Loading care plans for patient: ${user.id}');
        final carePlans = await apiService.getCarePlans(user.id, auth.token!);
        print('✅ Received ${carePlans.length} care plans');

        // Group care plans by doctor
        final Map<String, List<CarePlan>> groupedCarePlans = {};
        for (var plan in carePlans) {
          print(
            '📋 Care plan: doctorId=${plan.doctorId}, doctorName=${plan.doctorName}',
          );
          final doctorName = plan.doctorName ?? 'Unknown Doctor';
          groupedCarePlans.putIfAbsent(doctorName, () => []).add(plan);
        }

        print(
          '👥 Grouped into ${groupedCarePlans.keys.length} doctors: ${groupedCarePlans.keys}',
        );

        if (mounted) {
          setState(() {
            _groupedCarePlans = groupedCarePlans;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in';
        });
      }
    } catch (e) {
      print('Error loading care plan: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load care plan: $e';
        });
      }
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
          ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Care Plans'),
        actions: [
          if (_groupedCarePlans.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generatePdf,
              tooltip: 'Download PDF',
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCarePlan,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _groupedCarePlans.isEmpty
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
                      'No care plans available',
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
                                padding: const EdgeInsets.all(16),
                                itemCount: plans.length,
                                itemBuilder: (context, index) {
                                  final plan = plans[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Care Plan ${index + 1}',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleLarge,
                                              ),
                                              Text(
                                                plan.createdAt.toString().split(
                                                  ' ',
                                                )[0],
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          if (plan.medications.isNotEmpty) ...[
                                            Text(
                                              'Medications',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                            ),
                                            ...plan.medications.map(
                                              (med) => ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(
                                                  Icons.medication,
                                                ),
                                                title: Text(med.name),
                                                subtitle: Text(
                                                  '${med.dosage}, ${med.frequency}${med.duration != null ? ', ${med.duration}' : ''}',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                          if (plan.exercises.isNotEmpty) ...[
                                            Text(
                                              'Exercises',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                            ),
                                            ...plan.exercises.map(
                                              (ex) => ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(
                                                  Icons.fitness_center,
                                                ),
                                                title: Text(ex.name),
                                                subtitle: Text(
                                                  '${ex.duration}, ${ex.frequency}',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                          if (plan.instructions.isNotEmpty) ...[
                                            Text(
                                              'Instructions',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(plan.instructions),
                                            const SizedBox(height: 8),
                                          ],
                                          if (plan.warningSigns.isNotEmpty) ...[
                                            Text(
                                              'Warning Signs',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                color: Colors.red[700],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              plan.warningSigns,
                                              style: TextStyle(
                                                color: Colors.red[700],
                                              ),
                                            ),
                                          ],
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
