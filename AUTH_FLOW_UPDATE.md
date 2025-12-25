# Authentication Flow Update

## Changes Made to Match Backend

### 🔑 **Key Changes**

1. **Updated API Endpoints** - Added `/api` prefix
   - Login: `POST /api/auth/login`
   - Signup: `POST /api/auth/signup`

2. **Signup Flow Changed**
   - ❌ Old: Signup returned user + token → auto-login
   - ✅ New: Signup returns only success message → user must login separately

3. **Response Formats Updated**
   - Login: `{ token: "...", user: { id, name, email, role, language } }`
   - Signup: `{ msg: "User registered successfully" }`

### 📝 **Updated Files**

#### [auth_service.dart](lib/services/auth_service.dart)
- **Login endpoint**: Changed to `/api/auth/login`
  - Expects `user.id` (not `_id`)
  - Token is in `data['token']` directly
  
- **Signup endpoint**: Changed to `/api/auth/signup`
  - Returns `String` message instead of `User`
  - Sends `language: 'en'` field
  - No token returned

#### [auth_provider.dart](lib/providers/auth_provider.dart)
- **signup()** method now returns `Future<String>` (success message)
- Does NOT set `_currentUser` after signup
- User must login separately after signup

#### [signup_screen.dart](lib/screens/auth/signup_screen.dart)
- Shows success message after signup
- Redirects to **login screen** (not dashboard)
- User must login with their credentials

#### [api_service.dart](lib/services/api_service.dart)
- Base URL updated to include `/api` prefix
- All endpoints now use: `https://carebridge-xhnj.onrender.com/api`

### 🔐 **Authentication Flow**

#### **Signup**
```dart
1. User fills signup form
2. POST /api/auth/signup with { name, email, password, role, language }
3. Backend returns { msg: "User registered successfully" }
4. Show success message
5. Redirect to login screen
6. User enters credentials to login
```

#### **Login**
```dart
1. User fills login form
2. POST /api/auth/login with { email, password }
3. Backend returns { token, user: { id, name, email, role } }
4. Save token and user to SharedPreferences
5. Redirect to appropriate dashboard based on role
```

#### **Protected API Calls**
```dart
1. Get token from SharedPreferences
2. Create ApiService with token
3. Token sent as: Authorization: Bearer <token>
4. Backend middleware verifies token (expires in 7 days)
```

### ✅ **Request/Response Examples**

#### **Signup Request**
```json
POST /api/auth/signup
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "patient",
  "language": "en"
}
```

**Response**
```json
{
  "msg": "User registered successfully"
}
```

#### **Login Request**
```json
POST /api/auth/login
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "patient",
    "language": "en"
  }
}
```

### 🔄 **User Experience Flow**

**Old Flow:**
```
Signup → Auto Login → Dashboard
```

**New Flow:**
```
Signup → Success Message → Login Screen → Enter Credentials → Dashboard
```

### ⚠️ **Important Notes**

1. **Signup does NOT log the user in automatically**
   - User must login with their credentials after signup
   - This is intentional per backend design

2. **Token Expiration**
   - JWT token expires after 7 days
   - User will need to login again after expiration

3. **Error Messages**
   - Backend uses `msg` or `message` field for errors
   - Handle both in error parsing

4. **Role-Based Access**
   - Token contains user ID and role
   - Backend middleware uses this for route protection
   - Roles: patient, doctor, caregiver, admin

### 🐛 **Debug Mode**

Debug mode is set to `false` in [auth_provider.dart](lib/providers/auth_provider.dart). To enable:

```dart
static const bool debugMode = true;
```

This will skip authentication and use a mock user for testing.
