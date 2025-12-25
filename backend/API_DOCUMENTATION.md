# CareBridge Backend API Documentation v2.0

## Overview

The revamped CareBridge backend features:

- Separate user models for Patients, Doctors, and Caretakers
- QR Code-based patient identification for associations
- Real-time chat via WebSocket (Socket.io)
- Association-based communication restrictions

## Base URL

```
http://localhost:5000/api
```

## Authentication

All protected routes require a JWT token in the Authorization header:

```
Authorization: Bearer <token>
```

---

## Auth Routes (`/api/auth`)

### POST `/signup`

Register a new user (patient, doctor, or caretaker).

**Request Body (Patient):**

```json
{
  "name": "John Doe",
  "email": "patient@example.com",
  "password": "securepassword",
  "role": "patient",
  "gender": "male",
  "phone": "+1234567890",
  "age": 35,
  "bloodGroup": "O+",
  "address": "123 Main St",
  "emergencyContact": {
    "name": "Jane Doe",
    "phone": "+0987654321",
    "relation": "spouse"
  },
  "medicalHistory": {
    "allergies": ["penicillin"],
    "chronicConditions": ["diabetes"],
    "medications": ["metformin"]
  }
}
```

**Response (Patient):**

```json
{
  "msg": "Patient registered successfully",
  "userId": "...",
  "qrCodeId": "uuid-for-qr-code"
}
```

**Request Body (Doctor):**

```json
{
  "name": "Dr. Smith",
  "email": "doctor@example.com",
  "password": "securepassword",
  "role": "doctor",
  "gender": "male",
  "phone": "+1234567890",
  "specialization": "cardiologist",
  "qualifications": [
    { "degree": "MBBS", "institution": "Medical College", "year": 2010 }
  ],
  "experience": 10,
  "clinicAddress": "456 Hospital Rd",
  "consultationFee": 500
}
```

**Request Body (Caretaker):**

```json
{
  "name": "Nurse Brown",
  "email": "caretaker@example.com",
  "password": "securepassword",
  "role": "caretaker",
  "gender": "female",
  "phone": "+1234567890",
  "qualification": "Certified Nursing Assistant",
  "experience": 5,
  "specializations": ["elderly_care", "chronic_illness_care"],
  "availability": "full_time"
}
```

### POST `/login`

Authenticate a user.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password",
  "role": "patient" // Optional - helps direct search
}
```

**Response:**

```json
{
  "token": "jwt-token",
  "user": {
    "id": "...",
    "name": "John Doe",
    "role": "patient",
    "qrCodeId": "uuid", // Only for patients
    "associatedDoctors": [], // Only for patients
    "associatedCaretakers": [] // Only for patients
  }
}
```

### GET `/profile` (Protected)

Get current user's profile.

### PUT `/profile` (Protected)

Update current user's profile.

### POST `/change-password` (Protected)

Change password.

---

## Association Routes (`/api/associations`)

### POST `/scan` (Protected - Doctors/Caretakers only)

Scan patient's QR code to create association.

**Request Body:**

```json
{
  "qrCodeId": "patient-uuid-from-qr",
  "notes": "Initial consultation"
}
```

**Response:**

```json
{
  "msg": "Association created successfully",
  "association": {...},
  "patient": {
    "id": "...",
    "name": "John Doe",
    "age": 35,
    "bloodGroup": "O+",
    "gender": "male"
  }
}
```

### GET `/` (Protected)

Get all associations for current user.

**Response (for patients):**

```json
{
  "associations": {
    "doctors": [...],
    "caretakers": [...]
  }
}
```

**Response (for doctors/caretakers):**

```json
{
  "associations": {
    "patients": [...]
  }
}
```

### GET `/patient/:qrCodeId` (Protected - Doctors/Caretakers only)

Preview patient info by QR code before creating association.

### POST `/can-communicate` (Protected)

Check if two users can chat.

**Request Body:**

```json
{
  "targetUserId": "...",
  "targetUserType": "Doctor"
}
```

### PATCH `/:associationId/deactivate` (Protected)

Deactivate an association.

### PATCH `/visit/:patientId` (Protected - Doctors only)

Update last visit record for a patient.

---

## Chat Routes (`/api/chat`)

### GET `/conversations` (Protected)

Get all conversations for current user.

**Response:**

```json
{
  "conversations": [
    {
      "conversationId": "...",
      "partner": {
        "id": "...",
        "type": "Doctor",
        "name": "Dr. Smith",
        "specialization": "cardiologist"
      },
      "lastMessage": {
        "content": "See you tomorrow",
        "createdAt": "...",
        "isFromMe": true
      },
      "unreadCount": 2
    }
  ]
}
```

### GET `/unread` (Protected)

Get total unread message count.

### GET `/:partnerId/:partnerType` (Protected)

Get conversation history with specific user.

**Query Parameters:**

- `limit` (optional): Number of messages (default: 50)
- `skip` (optional): Pagination offset (default: 0)

### POST `/send` (Protected)

Send message via REST (WebSocket preferred for real-time).

**Request Body:**

```json
{
  "receiverId": "...",
  "receiverType": "Doctor",
  "content": "Hello doctor",
  "messageType": "text"
}
```

### PATCH `/:conversationId/read` (Protected)

Mark messages in conversation as read.

### DELETE `/message/:messageId` (Protected)

Delete a message (sender only).

---

## WebSocket Events

### Connection

```javascript
const socket = io("http://localhost:5000", {
  auth: { token: "jwt-token" },
});
```

### Client → Server Events

#### `join_conversation`

Join a conversation room for real-time updates.

```javascript
socket.emit("join_conversation", {
  partnerId: "...",
  partnerType: "Doctor",
});
```

#### `leave_conversation`

Leave a conversation room.

```javascript
socket.emit("leave_conversation", { partnerId: "..." });
```

#### `send_message`

Send a message.

```javascript
socket.emit("send_message", {
  tempId: "client-temp-id", // For matching response
  receiverId: "...",
  receiverType: "Patient",
  content: "Hello!",
  messageType: "text",
});
```

#### `typing_start` / `typing_stop`

Typing indicators.

```javascript
socket.emit("typing_start", { partnerId: "..." });
socket.emit("typing_stop", { partnerId: "..." });
```

#### `messages_read`

Mark messages as read.

```javascript
socket.emit("messages_read", {
  conversationId: "...",
  partnerId: "...",
});
```

#### `check_online`

Check if users are online.

```javascript
socket.emit("check_online", { userIds: ["...", "..."] });
```

### Server → Client Events

#### `conversation_joined`

Confirmation of joining conversation.

#### `message_sent`

Confirmation that message was sent.

```javascript
socket.on("message_sent", ({ tempId, message }) => {
  // Match tempId to update UI
});
```

#### `new_message`

Receive new message.

```javascript
socket.on("new_message", ({ message }) => {
  // Display new message
});
```

#### `user_typing` / `user_stopped_typing`

Typing indicators from other users.

#### `messages_marked_read`

Notification that partner read messages.

#### `online_status`

Response to `check_online`.

```javascript
socket.on("online_status", (status) => {
  // { 'userId1': true, 'userId2': false }
});
```

#### `user_offline`

Notification when a user disconnects.

#### `error`

Error messages.

```javascript
socket.on("error", ({ message }) => {
  console.error(message);
});
```

---

## Data Models

### Patient

- `qrCodeId`: Unique UUID for QR code generation
- `associatedDoctors[]`: List of associated doctors
- `associatedCaretakers[]`: List of associated caretakers

### Doctor

- `specialization`: Medical specialization
- `associatedPatients[]`: List of associated patients

### Caretaker

- `specializations[]`: Care specializations
- `associatedPatients[]`: List of associated patients

### Association

Central record of all patient-doctor/caretaker associations.

### Message

Chat messages with conversation tracking.

---

## QR Code Flow

1. **Patient Registration**: Patient signs up and receives a `qrCodeId`
2. **QR Code Generation**: Frontend generates QR code containing the `qrCodeId`
3. **Doctor Scans**: Doctor scans patient's QR code using their app
4. **Association Created**: Backend creates bidirectional association
5. **Chat Enabled**: Both can now communicate via chat

---

## Error Codes

- `400`: Bad Request - Missing or invalid parameters
- `401`: Unauthorized - Invalid or missing token
- `403`: Forbidden - User not authorized for this action
- `404`: Not Found - Resource doesn't exist
- `409`: Conflict - Resource already exists (e.g., duplicate email)
- `500`: Internal Server Error

---

## Setup

1. Install dependencies:

   ```bash
   cd backend
   npm install
   ```

2. Create `.env` file:

   ```
   PORT=5000
   MONGODB_URI=mongodb://localhost:27017/carebridge
   JWT_SECRET=your-secret-key
   ```

3. Start server:
   ```bash
   npm run dev  # Development
   npm start    # Production
   ```
