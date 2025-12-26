import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            _ProfileHeader(user: user),
            const SizedBox(height: 24),

            // QR Code Section (Patients only)
            if (user.role == UserRole.patient)
              _QrCodeSection(qrCodeId: user.qrCodeId ?? user.id),

            const SizedBox(height: 24),

            // Profile Details
            _ProfileDetails(user: user),

            const SizedBox(height: 24),

            // Associated Users Section
            if (user.role == UserRole.patient && user.associatedDoctors.isNotEmpty)
              _AssociatedDoctorsSection(doctors: user.associatedDoctors),

            if ((user.role == UserRole.doctor || user.role == UserRole.caregiver) && 
                user.associatedPatients.isNotEmpty)
              _AssociatedPatientsSection(patients: user.associatedPatients),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.name.toUpperCase(),
                style: TextStyle(
                  color: _getRoleColor(user.role),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return Colors.blue;
      case UserRole.doctor:
        return Colors.green;
      case UserRole.caregiver:
        return Colors.orange;
      case UserRole.admin:
        return Colors.purple;
    }
  }
}

class _QrCodeSection extends StatelessWidget {
  final String qrCodeId;

  const _QrCodeSection({required this.qrCodeId});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'My QR Code',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Show this to your doctor to connect',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrCodeId,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ID: ${qrCodeId.substring(0, 8)}...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  final User user;

  const _ProfileDetails({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            if (user.gender != null)
              _DetailRow(
                icon: Icons.person_outline,
                label: 'Gender',
                value: user.gender!.toUpperCase(),
              ),
            if (user.age != null)
              _DetailRow(
                icon: Icons.cake_outlined,
                label: 'Age',
                value: '${user.age} years',
              ),
            if (user.bloodGroup != null)
              _DetailRow(
                icon: Icons.bloodtype_outlined,
                label: 'Blood Group',
                value: user.bloodGroup!,
              ),
            if (user.specialization != null)
              _DetailRow(
                icon: Icons.medical_information_outlined,
                label: 'Specialization',
                value: user.specialization!.replaceAll('_', ' ').toUpperCase(),
              ),
            if (user.phoneNumber != null)
              _DetailRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phoneNumber!,
              ),
            if (user.address != null)
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: user.address!,
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssociatedDoctorsSection extends StatelessWidget {
  final List<AssociatedDoctor> doctors;

  const _AssociatedDoctorsSection({required this.doctors});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medical_services, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'My Doctors (${doctors.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...doctors.map((doctor) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Text(
                  doctor.name?.isNotEmpty == true 
                      ? doctor.name![0].toUpperCase() 
                      : 'D',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
              title: Text(doctor.name ?? 'Doctor'),
              subtitle: Text(
                doctor.specialization?.replaceAll('_', ' ') ?? 'Specialist',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/chat/conversation',
                    arguments: {
                      'partnerId': doctor.doctorId,
                      'partnerType': 'Doctor',
                      'partnerName': doctor.name ?? 'Doctor',
                    },
                  );
                },
              ),
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ),
    );
  }
}

class _AssociatedPatientsSection extends StatelessWidget {
  final List<AssociatedPatient> patients;

  const _AssociatedPatientsSection({required this.patients});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'My Patients (${patients.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...patients.map((patient) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  patient.name?.isNotEmpty == true 
                      ? patient.name![0].toUpperCase() 
                      : 'P',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
              title: Text(patient.name ?? 'Patient'),
              subtitle: Text(
                '${patient.age ?? '?'} yrs • ${patient.bloodGroup ?? 'Unknown'}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/chat/conversation',
                    arguments: {
                      'partnerId': patient.patientId,
                      'partnerType': 'Patient',
                      'partnerName': patient.name ?? 'Patient',
                    },
                  );
                },
              ),
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ),
    );
  }
}
