<h1 id="carebridge" align="center">CareBridge</h1>

<p align="center">
    <img src="images/logo.png" alt="CareBridge Logo" width="200" height="200">
</p>

<p align="center">
    <strong>🏥 Bridging the Gap Between Healthcare Providers and Patients</strong>
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
    <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white" alt="Node.js">
    <img src="https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=express&logoColor=white" alt="Express">
    <img src="https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white" alt="MongoDB">
    <img src="https://img.shields.io/badge/Socket.IO-010101?style=for-the-badge&logo=socket.io&logoColor=white" alt="Socket.IO">
    <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License">
    <img src="https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge" alt="Version">
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge" alt="Platforms">
</p>

---

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Overview](#overview)
- [Mission \& Vision](#mission--vision)
  - [Our Mission](#our-mission)
  - [Our Vision](#our-vision)
- [Key Features](#key-features)
  - [Patient Features](#patient-features)
  - [Doctor Features](#doctor-features)
  - [Caregiver Features](#caregiver-features)
  - [Admin Features](#admin-features)
- [Tech Stack](#tech-stack)
  - [Frontend (Flutter Application)](#frontend-flutter-application)
  - [Backend (Node.js Server)](#backend-nodejs-server)
- [Project Architecture](#project-architecture)
- [How It Works](#how-it-works)
  - [1. Registration \& Identity](#1-registration--identity)
  - [2. Secure Association](#2-secure-association)
  - [3. Care Plan Management](#3-care-plan-management)
  - [4. Real-time Monitoring \& Chat](#4-real-time-monitoring--chat)
  - [5. Data-Driven Insights](#5-data-driven-insights)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [API Documentation](#api-documentation)
  - [Authentication](#authentication)
  - [Associations \& QR](#associations--qr)
  - [Real-time Chat](#real-time-chat)
- [WebSocket Integration](#websocket-integration)
  - [Key Events:](#key-events)
- [Database Schema](#database-schema)
  - [Patient Schema](#patient-schema)
  - [Care Plan Schema](#care-plan-schema)
- [Screenshots](#screenshots)
  - [Doctor Experience](#doctor-experience)
  - [Patient Experience](#patient-experience)
- [Demo Video](#demo-video)
- [Security \& Performance](#security--performance)
- [Future Roadmap](#future-roadmap)
- [Troubleshooting \& FAQ](#troubleshooting--faq)
  - [FAQ](#faq)
  - [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Complete API Reference](#complete-api-reference)
  - [Care Plans API (`/api/careplan`)](#care-plans-api-apicareplan)
  - [Appointments API (`/api/appointments`)](#appointments-api-apiappointments)
  - [Daily Logs API (`/api/dailylog`)](#daily-logs-api-apidailylog)
  - [Reports API (`/api/reports`)](#reports-api-apireports)
  - [Notifications API (`/api/notifications`)](#notifications-api-apinotifications)
  - [Pre-visit Forms API (`/api/previsit`)](#pre-visit-forms-api-apiprevisit)
  - [Dashboard API (`/api/dashboard`)](#dashboard-api-apidashboard)
  - [Sync API (`/api/sync`)](#sync-api-apisync)
- [Complete Database Schemas](#complete-database-schemas)
  - [Patient Model (MongoDB)](#patient-model-mongodb)
  - [Doctor Model](#doctor-model)
  - [Caretaker Model](#caretaker-model)
  - [Care Plan Model](#care-plan-model)
  - [Appointment Model](#appointment-model)
  - [Symptom Report Model](#symptom-report-model)
  - [Daily Log Model](#daily-log-model)
  - [Association Model](#association-model)
  - [Message Model](#message-model)
  - [Notification Model](#notification-model)
- [Deployment Guide](#deployment-guide)
  - [Deploying Backend to Render](#deploying-backend-to-render)
  - [Deploying Frontend to Vercel](#deploying-frontend-to-vercel)
  - [Deploying to Firebase Hosting](#deploying-to-firebase-hosting)
  - [Docker Deployment](#docker-deployment)
- [Testing](#testing)
  - [Flutter Unit Tests](#flutter-unit-tests)
  - [Flutter Widget Tests](#flutter-widget-tests)
  - [Backend API Tests (with Jest)](#backend-api-tests-with-jest)
  - [Integration Testing](#integration-testing)
  - [Test Coverage Report](#test-coverage-report)
- [Performance Optimization](#performance-optimization)
  - [Flutter Performance](#flutter-performance)
  - [Backend Performance](#backend-performance)
  - [Network Optimization](#network-optimization)
- [Security Best Practices](#security-best-practices)
  - [Authentication \& Authorization](#authentication--authorization)
  - [Data Protection](#data-protection)
  - [HIPAA Compliance (Future)](#hipaa-compliance-future)
- [Internationalization (i18n)](#internationalization-i18n)
  - [Supported Languages (Planned)](#supported-languages-planned)
  - [Implementation](#implementation)
- [Platform-Specific Features](#platform-specific-features)
  - [Android](#android)
  - [iOS](#ios)
  - [Web](#web)
  - [Windows/macOS/Linux](#windowsmacoslinux)
- [Design System](#design-system)
  - [Color Palette](#color-palette)
  - [Typography](#typography)
  - [Components](#components)
- [Data Synchronization](#data-synchronization)
  - [Offline-First Architecture](#offline-first-architecture)
  - [Sync Flow](#sync-flow)
- [Analytics \& Monitoring](#analytics--monitoring)
  - [Metrics Tracked](#metrics-tracked)
  - [Tools](#tools)
- [Contributing Guidelines](#contributing-guidelines)
  - [Code Style](#code-style)
  - [Commit Messages](#commit-messages)
  - [Pull Request Process](#pull-request-process)
- [License](#license)
- [Support \& Contact](#support--contact)
- [Acknowledgments](#acknowledgments)
- [Team](#team)
- [🌟 Star History](#-star-history)

---

## Overview

**CareBridge** is a state-of-the-art, unified healthcare management ecosystem designed to streamline the interaction between patients, medical professionals, and caregivers. In an era where digital health is paramount, CareBridge provides a secure, real-time, and cross-platform solution that ensures medical data is accessible, communication is instantaneous, and patient care is continuous.

Built with a focus on **reliability**, **security**, and **user experience**, CareBridge leverages the power of Flutter for a consistent UI across all devices and a high-performance Node.js backend to handle complex medical workflows and real-time data synchronization.

---

## Mission & Vision

### Our Mission
To empower healthcare providers and patients by breaking down communication barriers and providing tools that enhance the quality of care, adherence to treatment, and overall health outcomes.

### Our Vision
To become the global standard for integrated healthcare management, where every patient has a direct, secure, and intelligent link to their entire care team.

---

## Key Features

### Patient Features
- **Symptom Reporting**: Log daily symptoms with severity levels, descriptions, and photo attachments.
- **Care Plan Adherence**: View and track medications, exercises, and dietary plans assigned by doctors.
- **Daily Task Checklist**: Interactive daily logs to ensure no part of the treatment is missed.
- **QR Identity**: Unique QR code for instant, secure association with doctors.
- **Appointment Management**: Book, view, and manage medical consultations.
- **Real-time Chat**: Direct line of communication with associated doctors and caregivers.
- **Health Insights**: Visual charts showing adherence trends and health progress.
- **Offline Mode**: Access your care plan and log symptoms even without an internet connection.

### Doctor Features
- **Patient Dashboard**: Comprehensive overview of all associated patients and their current status.
- **Dynamic Care Plans**: Create and update personalized treatment plans (meds, exercises, diet).
- **QR Scanner**: Instantly link with new patients by scanning their unique QR code.
- **Medical Reports**: Access and review patient-submitted symptom reports and history.
- **PDF Generation**: Generate and download professional medical reports and care plans.
- **Appointment Scheduling**: Manage consultation slots and patient visits.
- **Patient Monitoring**: Real-time alerts for critical symptom reports.
- **Patient Detail View**: Deep dive into patient history, vitals, and adherence data.

### Caregiver Features
- **Adherence Monitoring**: Track if patients are following their prescribed care plans.
- **Compliance Alerts**: Receive notifications when a patient misses a task or reports severe symptoms.
- **Daily Log Access**: Review the patient's daily activities and health logs.
- **Direct Communication**: Coordinate care with both the patient and the doctor.

### Admin Features
- **User Management**: Oversee all accounts and roles within the system.
- **Clinic Configuration**: Manage clinic-wide settings and resources.
- **System Analytics**: Monitor platform usage, health statistics, and performance metrics.
- **Audit Logs**: Maintain security and compliance through detailed system logs.

---

## Tech Stack

### Frontend (Flutter Application)
| Category | Technology | Purpose |
|----------|------------|---------|
| **Framework** | [Flutter 3.10+](https://flutter.dev/) | Cross-platform UI development |
| **Language** | [Dart ^3.7.2](https://dart.dev/) | Core programming language |
| **State Management** | [Provider](https://pub.dev/packages/provider) | Reactive state handling |
| **Navigation** | [GoRouter](https://pub.dev/packages/go_router) | Declarative routing system |
| **Local Database** | [sqflite](https://pub.dev/packages/sqflite) | Offline data persistence |
| **Real-time** | [Socket.IO Client](https://pub.dev/packages/socket_io_client) | WebSocket communication |
| **Charts** | [FL Chart](https://pub.dev/packages/fl_chart) | Data visualization |
| **PDF/Print** | [pdf](https://pub.dev/packages/pdf) & [printing](https://pub.dev/packages/printing) | Document generation |
| **QR System** | [qr_flutter](https://pub.dev/packages/qr_flutter) & [mobile_scanner](https://pub.dev/packages/mobile_scanner) | QR generation and scanning |

### Backend (Node.js Server)
| Category | Technology | Purpose |
|----------|------------|---------|
| **Runtime** | [Node.js 18.x+](https://nodejs.org/) | Server-side execution |
| **Framework** | [Express 5.x](https://expressjs.com/) | Web API framework |
| **Database** | [MongoDB](https://www.mongodb.com/) | NoSQL document storage |
| **ODM** | [Mongoose ^9.0.2](https://mongoosejs.com/) | Object Data Modeling |
| **Real-time** | [Socket.IO ^4.7.4](https://socket.io/) | WebSocket server |
| **Auth** | [JWT](https://jwt.io/) | Secure token-based authentication |
| **Security** | [Bcrypt.js](https://www.npmjs.com/package/bcryptjs) | Password hashing |

---

## Project Architecture

```text
CareBridge/
├── 📁 application/                 # Flutter Cross-Platform App
│   ├── 📁 lib/
│   │   ├── 📁 models/              # Data structures (CarePlan, User, etc.)
│   │   ├── 📁 providers/           # State management logic
│   │   ├── 📁 screens/             # UI Layers (Patient, Doctor, Admin)
│   │   ├── 📁 services/            # API & Business logic (Auth, Chat, PDF)
│   │   └── 📄 main.dart            # App entry point
│   └── 📄 pubspec.yaml             # App dependencies
│
├── 📁 backend/                    # Node.js REST & WebSocket Server
│   ├── 📁 config/                  # Database & Environment config
│   ├── 📁 controllers/             # Request handling logic
│   ├── 📁 middleware/              # Auth & Role-based protection
│   ├── 📁 models/                  # Mongoose Schemas
│   ├── 📁 routes/                  # API Endpoints
│   ├── 📁 socket/                  # WebSocket event handlers
│   └── 📄 server.js                # Server entry point
│
├── 📁 images/                      # Assets & Screenshots
└── 📁 videos/                      # Demo & Tutorial videos
```

---

## How It Works

### 1. Registration & Identity
Every user registers with a specific role. **Patients** are automatically assigned a unique **QR Code ID** upon registration, which serves as their digital medical identity within the CareBridge ecosystem.

### 2. Secure Association
Doctors and Caregivers link with patients by scanning the patient's QR code. This creates a secure, bidirectional association in the database, granting the provider access to the patient's health data and enabling real-time communication.

### 3. Care Plan Management
Doctors design personalized care plans including medications, exercises, and dietary restrictions. These plans are instantly synced to the patient's device.

### 4. Real-time Monitoring & Chat
Patients log their daily adherence and report symptoms. If a critical symptom is reported, the doctor receives an instant notification. Both parties can communicate via the built-in WebSocket chat for immediate clarification or support.

### 5. Data-Driven Insights
The system aggregates adherence data and symptom reports into visual charts, allowing doctors to make informed decisions during follow-up visits.

---

## Getting Started

### Prerequisites
- **Flutter SDK**: `^3.10.0`
- **Node.js**: `^18.0.0`
- **MongoDB**: Local instance or Atlas URI
- **Git**: For version control

### Backend Setup
1. **Navigate to backend**:
   ```bash
   cd backend
   ```
2. **Install dependencies**:
   ```bash
   npm install
   ```
3. **Environment Config**:
   Create a `.env` file:
   ```env
   PORT=5000
   MONGODB_URI=your_mongodb_uri
   JWT_SECRET=your_secret_key
   JWT_EXPIRE=30d
   ```
4. **Run Server**:
   ```bash
   npm start
   ```

### Frontend Setup
1. **Navigate to application**:
   ```bash
   cd application
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configure API**:
   Update `lib/services/api_service.dart` with your server IP.
4. **Run App**:
   ```bash
   flutter run
   ```

---

## API Documentation

### Authentication
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/signup` | `POST` | Register as Patient, Doctor, or Caretaker |
| `/api/auth/login` | `POST` | Authenticate and receive JWT |
| `/api/auth/profile` | `GET` | Retrieve current user details |

### Associations & QR
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/associations/scan` | `POST` | Link Doctor to Patient via QR ID |
| `/api/associations/` | `GET` | List all active associations |
| `/api/associations/patient/:qrId` | `GET` | Preview patient info before linking |

### Real-time Chat
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/chat/conversations` | `GET` | List all active chat threads |
| `/api/chat/:id/:type` | `GET` | Fetch message history |
| `/api/chat/send` | `POST` | Send a message (REST fallback) |

---

## WebSocket Integration

CareBridge uses **Socket.io** for low-latency, real-time features.

### Key Events:
- `join_conversation`: Enter a specific chat room.
- `send_message`: Broadcast message to the recipient.
- `typing_start` / `typing_stop`: Real-time typing indicators.
- `new_message`: Listener for incoming messages.
- `online_status`: Track availability of doctors/patients.

---

## Database Schema

### Patient Schema
- `qrCodeId`: Unique UUID for scanning.
- `medicalHistory`: Array of allergies, conditions, and meds.
- `associatedDoctors`: References to Doctor models.

### Care Plan Schema
- `medications`: List of meds with dosage and timing.
- `exercises`: List of physical activities with duration.
- `diet`: Nutritional recommendations.
- `status`: Active / Completed / Cancelled.

---

## Screenshots

### Doctor Experience
<p align="center">
    <img src="images/dashboard(doctor).jpeg" width="250" alt="Doctor Dashboard">
    &nbsp;&nbsp;
    <img src="images/careplan(doctor).jpeg" width="250" alt="Care Plan Creation">
    &nbsp;&nbsp;
    <img src="images/chatdoctor).jpeg" width="250" alt="Doctor Chat">
</p>

### Patient Experience
<p align="center">
    <img src="images/appointments(patient).jpeg" width="250" alt="Patient Appointments">
    &nbsp;&nbsp;
    <img src="images/careplan(patient).jpeg" width="250" alt="Patient Care Plan">
    &nbsp;&nbsp;
    <img src="images/dailyplan(patient).jpeg" width="250" alt="Daily Tasks">
</p>

<p align="center">
    <img src="images/chat(patient).jpeg" width="250" alt="Patient Chat">
    &nbsp;&nbsp;
    <img src="images/profile(patient).jpeg" width="250" alt="Patient Profile">
</p>

---

## Demo Video

Experience CareBridge in action! Watch our comprehensive walkthrough:

<p align="center">
  <a href="videos/demo_video.mp4">
    <img src="images/logo.png" width="150" alt="Watch Demo">
    <br>
    <strong>📺 Click to Play Demo Video</strong>
  </a>
</p>

---

## Security & Performance

- **JWT Protection**: All sensitive routes are guarded by JSON Web Token middleware.
- **Role-Based Access (RBAC)**: Strict separation of data between roles.
- **Data Encryption**: Passwords are salted and hashed using Bcrypt.
- **Offline Sync**: Local SQLite storage ensures the app works in low-connectivity areas.
- **Optimized Queries**: MongoDB indexing for fast retrieval of medical records.
- **Socket.io Security**: Authentication handshake for WebSocket connections.

---

## Future Roadmap

- [ ] **AI Symptom Analysis**: Integration of ML models to predict potential health risks based on symptom history.
- [ ] **Video Consultations**: Built-in WebRTC video calling for remote check-ups.
- [ ] **Wearable Integration**: Sync data from Apple Health and Google Fit.
- [ ] **Multi-Language Support**: Localizing the app for global accessibility.
- [ ] **Blockchain for Records**: Implementing decentralized storage for immutable medical records.

---

## Troubleshooting & FAQ

### FAQ
**Q: Can a patient have multiple doctors?**
A: Yes, a patient can be associated with multiple doctors across different specializations.

**Q: Is my data secure?**
A: Absolutely. We use industry-standard JWT authentication and Bcrypt hashing. All data transmission is encrypted.

**Q: Does the app work offline?**
A: Yes, patients can view their care plans and log symptoms offline. Data will sync automatically once a connection is restored.

### Troubleshooting
- **Connection Refused**: Ensure the backend server is running and the `baseUrl` in Flutter matches your machine's IP.
- **MongoDB Error**: Verify your connection string in the `.env` file.
- **Flutter Build Issues**: Run `flutter clean` followed by `flutter pub get`.

---

## Contributing

1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## Complete API Reference

### Care Plans API (`/api/careplan`)

| Method | Endpoint | Description | Auth | Request Body |
|--------|----------|-------------|------|-------------|
| `GET` | `/` | Get all care plans | ✅ | - |
| `GET` | `/:id` | Get specific care plan | ✅ | - |
| `POST` | `/` | Create new care plan | ✅ (Doctor) | `{ patientId, title, medications[], exercises[], diet[], instructions }` |
| `PUT` | `/:id` | Update care plan | ✅ (Doctor) | `{ medications[], exercises[], status, ... }` |
| `DELETE` | `/:id` | Delete care plan | ✅ (Doctor) | - |
| `GET` | `/patient/:patientId` | Get patient's care plans | ✅ | - |

### Appointments API (`/api/appointments`)

| Method | Endpoint | Description | Auth | Request Body |
|--------|----------|-------------|------|-------------|
| `GET` | `/` | Get all appointments | ✅ | - |
| `POST` | `/` | Book new appointment | ✅ | `{ doctorId, date, time, reason, type }` |
| `PUT` | `/:id` | Update appointment | ✅ | `{ date, time, status }` |
| `DELETE` | `/:id` | Cancel appointment | ✅ | - |
| `GET` | `/upcoming` | Get upcoming appointments | ✅ | - |
| `GET` | `/doctor/:doctorId` | Get doctor's appointments | ✅ (Doctor) | - |

### Daily Logs API (`/api/dailylog`)

| Method | Endpoint | Description | Auth | Request Body |
|--------|----------|-------------|------|-------------|
| `GET` | `/` | Get all daily logs | ✅ | - |
| `POST` | `/` | Create daily log | ✅ (Patient) | `{ date, medications[], exercises[], notes }` |
| `GET` | `/patient/:patientId` | Get patient's logs | ✅ | - |
| `GET` | `/date/:date` | Get logs by date | ✅ | - |

### Reports API (`/api/reports`)

| Method | Endpoint | Description | Auth | Request Body |
|--------|----------|-------------|------|-------------|
| `GET` | `/` | Get all symptom reports | ✅ | - |
| `POST` | `/` | Submit symptom report | ✅ (Patient) | `{ symptomName, severity, description, duration, photoUrl }` |
| `GET` | `/patient/:patientId` | Get patient's reports | ✅ | - |
| `GET` | `/:id` | Get specific report | ✅ | - |

### Notifications API (`/api/notifications`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `GET` | `/` | Get all notifications | ✅ |
| `PATCH` | `/:id/read` | Mark as read | ✅ |
| `DELETE` | `/:id` | Delete notification | ✅ |
| `GET` | `/unread/count` | Get unread count | ✅ |

### Pre-visit Forms API (`/api/previsit`)

| Method | Endpoint | Description | Auth | Request Body |
|--------|----------|-------------|------|-------------|
| `GET` | `/` | Get pre-visit forms | ✅ | - |
| `POST` | `/` | Submit form | ✅ (Patient) | `{ appointmentId, symptoms, medications, questions }` |
| `GET` | `/:id` | Get specific form | ✅ | - |

### Dashboard API (`/api/dashboard`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `GET` | `/stats` | Get dashboard statistics | ✅ |
| `GET` | `/doctor/overview` | Get doctor overview | ✅ (Doctor) |
| `GET` | `/patient/adherence` | Get adherence data | ✅ (Patient) |

### Sync API (`/api/sync`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `POST` | `/` | Sync offline data | ✅ |
| `GET` | `/status` | Get sync status | ✅ |

---

## Complete Database Schemas

### Patient Model (MongoDB)

```javascript
{
  qrCodeId: {
    type: String,
    unique: true,
    required: true,
    default: () => uuidv4()
  },
  name: { type: String, required: true },
  email: { type: String, unique: true, required: true },
  password: { type: String, required: true },
  phone: String,
  gender: { 
    type: String, 
    enum: ['male', 'female', 'other'],
    required: true 
  },
  age: { type: Number, required: true },
  bloodGroup: { 
    type: String, 
    enum: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
    required: true 
  },
  address: String,
  emergencyContact: {
    name: String,
    phone: String,
    relation: String
  },
  medicalHistory: {
    allergies: [String],
    chronicConditions: [String],
    medications: [String]
  },
  associatedDoctors: [{
    doctorId: { type: ObjectId, ref: 'Doctor' },
    specialization: String,
    associatedAt: { type: Date, default: Date.now },
    isActive: { type: Boolean, default: true }
  }],
  associatedCaretakers: [{
    caretakerId: { type: ObjectId, ref: 'Caretaker' },
    relation: String,
    associatedAt: { type: Date, default: Date.now },
    isActive: { type: Boolean, default: true }
  }],
  profileImage: String,
  lastActive: Date,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}
```

### Doctor Model

```javascript
{
  name: { type: String, required: true },
  email: { type: String, unique: true, required: true },
  password: { type: String, required: true },
  phone: String,
  gender: { 
    type: String, 
    enum: ['male', 'female', 'other'],
    required: true 
  },
  specialization: {
    type: String,
    enum: [
      'ophthalmologist', 'gynaecologist', 'paediatrician',
      'general_surgeon', 'physician', 'orthopaedic',
      'dermatologist', 'psychiatrist', 'ent'
    ],
    required: true
  },
  qualifications: [{
    degree: String,
    institution: String,
    year: Number
  }],
  experience: Number,
  clinicAddress: String,
  consultationFee: Number,
  associatedPatients: [{
    patientId: { type: ObjectId, ref: 'Patient' },
    associatedAt: { type: Date, default: Date.now },
    lastVisit: Date,
    isActive: { type: Boolean, default: true }
  }],
  profileImage: String,
  rating: { type: Number, default: 0 },
  reviewCount: { type: Number, default: 0 },
  availability: [{
    day: String,
    slots: [{ start: String, end: String }]
  }],
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}
```

### Caretaker Model

```javascript
{
  name: { type: String, required: true },
  email: { type: String, unique: true, required: true },
  password: { type: String, required: true },
  phone: String,
  gender: { type: String, enum: ['male', 'female', 'other'] },
  qualification: String,
  experience: Number,
  specializations: [{
    type: String,
    enum: ['elderly_care', 'chronic_illness_care', 'post_surgery_care', 'pediatric_care']
  }],
  availability: {
    type: String,
    enum: ['full_time', 'part_time', 'on_call']
  },
  associatedPatients: [{
    patientId: { type: ObjectId, ref: 'Patient' },
    relation: String,
    associatedAt: { type: Date, default: Date.now },
    isActive: { type: Boolean, default: true }
  }],
  profileImage: String,
  createdAt: { type: Date, default: Date.now }
}
```

### Care Plan Model

```javascript
{
  patientId: { type: ObjectId, ref: 'Patient', required: true },
  doctorId: { type: ObjectId, ref: 'Doctor', required: true },
  title: { type: String, required: true },
  description: String,
  medications: [{
    name: { type: String, required: true },
    dosage: String,
    frequency: String,
    timing: [{
      type: String,
      enum: ['morning', 'afternoon', 'evening', 'night']
    }],
    instructions: String,
    startDate: Date,
    endDate: Date,
    duration: String
  }],
  exercises: [{
    name: { type: String, required: true },
    duration: String,
    frequency: String,
    repetitions: Number,
    instructions: String,
    videoUrl: String
  }],
  diet: [{
    mealType: {
      type: String,
      enum: ['breakfast', 'lunch', 'dinner', 'snack']
    },
    recommendations: String,
    restrictions: String,
    calories: Number
  }],
  startDate: { type: Date, required: true },
  endDate: Date,
  status: {
    type: String,
    enum: ['active', 'completed', 'cancelled', 'paused'],
    default: 'active'
  },
  instructions: String,
  goals: [String],
  precautions: [String],
  followUpDate: Date,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}
```

### Appointment Model

```javascript
{
  patientId: { type: ObjectId, ref: 'Patient', required: true },
  doctorId: { type: ObjectId, ref: 'Doctor', required: true },
  date: { type: Date, required: true },
  time: { type: String, required: true },
  duration: { type: Number, default: 30 },
  type: {
    type: String,
    enum: ['consultation', 'follow_up', 'emergency', 'routine_checkup'],
    required: true
  },
  status: {
    type: String,
    enum: ['scheduled', 'confirmed', 'completed', 'cancelled', 'rescheduled'],
    default: 'scheduled'
  },
  reason: String,
  notes: String,
  prescription: String,
  diagnosis: String,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}
```

### Symptom Report Model

```javascript
{
  patientId: { type: ObjectId, ref: 'Patient', required: true },
  symptomName: { type: String, required: true },
  severity: {
    type: String,
    enum: ['mild', 'moderate', 'severe', 'critical'],
    required: true
  },
  description: String,
  duration: String,
  frequency: String,
  triggers: [String],
  photoUrl: String,
  attachments: [String],
  vitals: {
    temperature: Number,
    bloodPressure: String,
    heartRate: Number,
    oxygenLevel: Number
  },
  createdAt: { type: Date, default: Date.now }
}
```

### Daily Log Model

```javascript
{
  patientId: { type: ObjectId, ref: 'Patient', required: true },
  carePlanId: { type: ObjectId, ref: 'CarePlan' },
  date: { type: Date, required: true },
  medications: [{
    medicationId: String,
    name: String,
    taken: { type: Boolean, default: false },
    time: String,
    notes: String
  }],
  exercises: [{
    exerciseId: String,
    name: String,
    completed: { type: Boolean, default: false },
    duration: String,
    notes: String
  }],
  meals: [{
    mealType: String,
    items: [String],
    time: String,
    calories: Number
  }],
  symptoms: [String],
  mood: {
    type: String,
    enum: ['excellent', 'good', 'fair', 'poor']
  },
  sleepHours: Number,
  waterIntake: Number,
  notes: String,
  adherenceScore: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
}
```

### Association Model

```javascript
{
  patientId: { type: ObjectId, ref: 'Patient', required: true },
  associatedUserId: { type: ObjectId, required: true },
  associatedUserType: {
    type: String,
    enum: ['Doctor', 'Caretaker'],
    required: true
  },
  notes: String,
  isActive: { type: Boolean, default: true },
  associationDate: { type: Date, default: Date.now },
  lastInteraction: Date,
  deactivatedAt: Date,
  deactivationReason: String
}
```

### Message Model

```javascript
{
  conversationId: { type: String, required: true, index: true },
  senderId: { type: ObjectId, required: true },
  senderType: {
    type: String,
    enum: ['Patient', 'Doctor', 'Caretaker'],
    required: true
  },
  receiverId: { type: ObjectId, required: true },
  receiverType: {
    type: String,
    enum: ['Patient', 'Doctor', 'Caretaker'],
    required: true
  },
  content: { type: String, required: true },
  messageType: {
    type: String,
    enum: ['text', 'image', 'file', 'voice'],
    default: 'text'
  },
  fileUrl: String,
  isRead: { type: Boolean, default: false },
  readAt: Date,
  isDeleted: { type: Boolean, default: false },
  deletedAt: Date,
  createdAt: { type: Date, default: Date.now }
}
```

### Notification Model

```javascript
{
  userId: { type: ObjectId, required: true },
  userType: {
    type: String,
    enum: ['Patient', 'Doctor', 'Caretaker', 'Admin']
  },
  title: { type: String, required: true },
  message: { type: String, required: true },
  type: {
    type: String,
    enum: ['appointment', 'symptom_alert', 'medication_reminder', 'message', 'system'],
    required: true
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high', 'urgent'],
    default: 'medium'
  },
  isRead: { type: Boolean, default: false },
  readAt: Date,
  actionUrl: String,
  metadata: Object,
  createdAt: { type: Date, default: Date.now }
}
```

---

## Deployment Guide

### Deploying Backend to Render

1. **Create Render Account**:
   - Sign up at [render.com](https://render.com)

2. **Create New Web Service**:
   - Connect your GitHub repository
   - Select the `backend` directory

3. **Configure Environment**:
   ```env
   NODE_ENV=production
   PORT=5000
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/carebridge
   JWT_SECRET=your_production_secret_key
   JWT_EXPIRE=30d
   ```

4. **Build Command**:
   ```bash
   npm install
   ```

5. **Start Command**:
   ```bash
   npm start
   ```

### Deploying Frontend to Vercel

1. **Build Flutter Web App**:
   ```bash
   cd application
   flutter build web --release
   ```

2. **Deploy to Vercel**:
   ```bash
   cd build/web
   vercel --prod
   ```

### Deploying to Firebase Hosting

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Initialize Firebase**:
   ```bash
   firebase init hosting
   ```

3. **Deploy**:
   ```bash
   firebase deploy --only hosting
   ```

### Docker Deployment

**Backend Dockerfile**:
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 5000
CMD ["npm", "start"]
```

**Docker Compose**:
```yaml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "5000:5000"
    environment:
      - MONGODB_URI=mongodb://mongo:27017/carebridge
      - JWT_SECRET=your_secret
    depends_on:
      - mongo
  
  mongo:
    image: mongo:latest
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db

volumes:
  mongo-data:
```

---

## Testing

### Flutter Unit Tests

```bash
cd application
flutter test
```

### Flutter Widget Tests

```bash
flutter test test/widget_test.dart
```

### Backend API Tests (with Jest)

```bash
cd backend
npm test
```

### Integration Testing

```bash
cd application
flutter drive --target=test_driver/app.dart
```

### Test Coverage Report

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Performance Optimization

### Flutter Performance

- **Code Splitting**: Lazy loading of routes using `GoRouter`
- **Image Optimization**: Using `CachedNetworkImage` for efficient image loading
- **State Management**: Provider pattern for minimal rebuilds
- **Database Indexing**: SQLite indexes for faster offline queries

### Backend Performance

- **MongoDB Indexing**: Indexes on frequently queried fields
- **Connection Pooling**: Mongoose connection pooling for efficient DB access
- **Caching**: Redis caching for frequently accessed data (future enhancement)
- **Load Balancing**: Nginx reverse proxy for production deployments

### Network Optimization

- **API Response Compression**: GZIP compression for API responses
- **Pagination**: Limit data transfer with paginated responses
- **WebSocket Optimization**: Socket.IO rooms for efficient message broadcasting

---

## Security Best Practices

### Authentication & Authorization

- **JWT Tokens**: Secure, stateless authentication
- **Token Expiration**: 30-day expiration with refresh token support
- **Password Policy**: Minimum 8 characters with complexity requirements
- **Bcrypt Hashing**: 10 salt rounds for password hashing
- **Role-Based Access**: Middleware-enforced role checking

### Data Protection

- **HTTPS Only**: Enforce SSL/TLS in production
- **Input Validation**: Server-side validation using Joi/Validator
- **XSS Protection**: Sanitize user inputs
- **CSRF Tokens**: Cross-Site Request Forgery protection
- **Rate Limiting**: Prevent brute-force attacks

### HIPAA Compliance (Future)

- **Audit Logs**: Track all data access and modifications
- **Data Encryption**: At-rest and in-transit encryption
- **Access Controls**: Fine-grained permission system
- **Data Backup**: Regular automated backups

---

## Internationalization (i18n)

### Supported Languages (Planned)

- 🇺🇸 English (Default)
- 🇪🇸 Spanish
- 🇫🇷 French
- 🇮🇳 Hindi
- 🇨🇳 Chinese

### Implementation

```dart
// Using Flutter Intl package
MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
  ],
)
```

---

## Platform-Specific Features

### Android

- **Material Design 3**: Modern UI components
- **Background Services**: Medication reminders via WorkManager
- **Biometric Auth**: Fingerprint/Face unlock
- **Push Notifications**: FCM integration

### iOS

- **Cupertino Widgets**: Native iOS look and feel
- **HealthKit Integration**: Sync vitals with Apple Health
- **Face ID/Touch ID**: Biometric authentication
- **APNs**: Apple Push Notification Service

### Web

- **Responsive Design**: Mobile-first approach
- **PWA Support**: Installable web app
- **Service Workers**: Offline capability
- **Web Notifications**: Browser push notifications

### Windows/macOS/Linux

- **Native Window Controls**: Platform-specific UI
- **File System Access**: Local file operations
- **System Tray**: Background app presence
- **Desktop Notifications**: Native notification system

---

## Design System

### Color Palette

```dart
Primary: #02569B (Flutter Blue)
Secondary: #47A248 (Health Green)
Accent: #339933 (Success)
Error: #D32F2F (Critical)
Warning: #FFA000 (Caution)
Info: #0175C2 (Information)
```

### Typography

- **Headings**: Roboto Bold
- **Body**: Roboto Regular
- **Captions**: Roboto Light

### Components

- **Buttons**: Rounded corners (8px), Material elevation
- **Cards**: Shadow elevation, 12px border radius
- **Input Fields**: Outlined style with validation states
- **Navigation**: Bottom navigation bar for mobile, side drawer for desktop

---

## Data Synchronization

### Offline-First Architecture

1. **Local Storage**: All data stored in SQLite
2. **Change Tracking**: Track local modifications with timestamps
3. **Conflict Resolution**: Last-write-wins strategy
4. **Batch Sync**: Upload changes when connection restored
5. **Delta Sync**: Only sync changed records

### Sync Flow

```
1. User makes changes offline → Stored in SQLite
2. Connection detected → Trigger sync service
3. Upload local changes → POST /api/sync
4. Download server changes → GET /api/sync/status
5. Merge conflicts → Apply resolution strategy
6. Update local DB → Notify UI to refresh
```

---

## Analytics & Monitoring

### Metrics Tracked

- **User Engagement**: Daily active users, session duration
- **Feature Usage**: Most used features, screen views
- **Performance**: App load time, API response times
- **Errors**: Crash reports, error logs
- **Health Metrics**: Adherence rates, symptom reporting frequency

### Tools

- **Firebase Analytics**: User behavior tracking
- **Sentry**: Error monitoring and crash reporting
- **Google Analytics**: Web traffic analysis
- **MongoDB Atlas Monitoring**: Database performance

---

## Contributing Guidelines

### Code Style

**Flutter (Dart)**:
```dart
// Use effective dart guidelines
// Run formatter before commit
dart format .
flutter analyze
```

**Node.js**:
```javascript
// Use ESLint configuration
// Follow Airbnb style guide
npm run lint
```

### Commit Messages

```
feat: Add video consultation feature
fix: Resolve QR scanner crash on Android
docs: Update API documentation
test: Add unit tests for auth service
refactor: Optimize database queries
```

### Pull Request Process

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'feat: Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request with detailed description
6. Wait for code review and address feedback
7. Merge after approval

---

## License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2025 CareBridge Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Support & Contact

- **Email**: bhavishyrocker2801@gmail.com
- **Issues**: [GitHub Issues](https://github.com/bhavishy2801/CareBridge/issues)
- **Discussions**: [GitHub Discussions](https://github.com/bhavishy2801/CareBridge/discussions)
<!-- - **Documentation**: [docs.carebridge.com](https://docs.carebridge.com) -->
<!-- - **Website**: [carebridge.com](https://carebridge.com) -->
---

## Acknowledgments

- **Flutter Team** - For the amazing cross-platform framework
- **Node.js Community** - For robust backend tools
- **MongoDB** - For flexible NoSQL database
- **Socket.IO** - For real-time communication
- **Open Source Community** - For countless libraries and tools

---

## Team

<p align="center">
    • <strong><a href="https://github.com/bhavishy2801/">Bhavishy Agrawal</a></strong> <br>  • <strong><a href="https://github.com/kushagra0902/">Kushagra Kinra</a></strong> <br>  • <strong><a href="https://github.com/suparnagrawal/">Suparn Agrawal</a></strong> <br>  • <strong><a href="https://github.com/Zephyr-sue/">Rupesh Poonia</a></strong>
</p>

---

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=bhavishy2801/CareBridge&type=Date)](https://star-history.com/#bhavishy2801/CareBridge&Date)

---

<p align="center">
    <img src="images/logo.png" alt="CareBridge Logo" width="100" height="100">
</p>

<p align="center">
    <strong>CareBridge v1.0.0</strong><br>
    <sub>Empowering Healthcare Through Technology</sub>
</p>

<p align="center">
    Made with ❤️ by the CareBridge Team
</p>

<p align="center">
    <a href="#carebridge">⬆️ Back to Top</a>
</p>