# CareBridge - Healthcare Management System

A comprehensive Flutter healthcare management application that connects patients, doctors, caregivers, and administrators in a seamless healthcare ecosystem.

## Features

### 🔐 Authentication & Role Management
- Multi-role login system (Patient, Doctor, Caregiver, Admin)
- Secure authentication with role-based access control
- User registration with role selection

### 🏥 Patient Module
- **Symptom Reporting**: Fill detailed symptom forms with severity levels
- **Offline Support**: Reports saved locally and synced when online
- **Care Plan Viewing**: Access personalized care plans from doctors
- **Daily Tasks**: Track medication and exercise adherence
- **Photo Attachments**: Add photos to symptom reports
- **Progress Tracking**: Visual progress indicators for daily tasks

### 👨‍⚕️ Doctor Module
- **Patient Dashboard**: View all patients with severity-based filtering
- **Patient Summaries**: Timeline, symptoms, and severity information
- **Care Plan Creation**: Create structured care plans with medications, exercises, and instructions
- **Focused Consultation**: Flag patients needing immediate attention
- **PDF Generation**: Generate printable care plans

### 👨‍👩‍👧 Caregiver Module
- **Adherence Monitoring**: Track patient medication and exercise compliance
- **Real-time Alerts**: Get notified about missed tasks
- **Detailed Tracking**: View medication and exercise completion status
- **Visual Reports**: Color-coded adherence percentages

### ⚙️ Admin Module
- **Clinic Settings**: Manage clinic metadata
- **User Statistics**: View system statistics
- **System Management**: Access to user and report management

## Getting Started

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

### Default Login Credentials (Demo Mode)
- Patient: any email + password (select Patient role)
- Doctor: any email + password (select Doctor role)
- Caregiver: any email + password (select Caregiver role)
- Admin: any email + password (select Admin role)

## Architecture

The app follows a clean architecture pattern with:
- **Models**: Data structures for all entities
- **Services**: Business logic and API integration
- **Providers**: State management using Provider pattern
- **Screens**: UI components organized by user role

## Tech Stack
- Flutter 3.10+
- Provider (State Management)
- GoRouter (Navigation)
- SQLite (Offline Storage)
- flutter_local_notifications
- PDF generation
- fl_chart (Charts)

## Note
This is a demonstration application. For production use, implement proper backend authentication, data encryption, and follow HIPAA compliance guidelines.
