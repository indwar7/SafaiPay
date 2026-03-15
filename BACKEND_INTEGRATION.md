# SafaiPay — Backend Integration Changelog

## Overview

Migrated the Flutter frontend from **direct Firebase** (Auth, Firestore, Storage) to the **Go backend API** (Gin + PostgreSQL + Redis + Cloudflare R2). All UI remains untouched — only the service/data layer was rewired.

---

## Architecture Change

```
BEFORE:
Flutter App ──▶ Firebase Auth (OTP)
             ──▶ Cloud Firestore (CRUD)
             ──▶ Firebase Storage (Images)

AFTER:
Flutter App ──HTTP/JSON──▶ Go Backend (Gin) ──▶ PostgreSQL
                                │                   Redis
                                │                   Cloudflare R2
                                ├──▶ MSG91 (OTP SMS)
                                ├──▶ Razorpay (Payouts)
                                └──▶ FCM (Push Notifications)
```

Firebase is still used **only for FCM push notifications** (`firebase_core` + `firebase_messaging`).

---

## Files Created

| File | Purpose |
|------|---------|
| `lib/core/api_client.dart` | Dio HTTP client singleton with JWT interceptor, auto-redirect to login on 401 |
| `lib/core/storage.dart` | `FlutterSecureStorage` wrapper for JWT token persistence |
| `lib/services/api_service.dart` | All backend HTTP endpoints — profile, reports, bookings, wallet, leaderboard, badges |
| `lib/models/badge_model.dart` | `BadgeModel` + `UserBadgeModel` for the badges/achievements API |

## Files Deleted

| File | Reason |
|------|--------|
| `lib/services/firestore_service.dart` | Replaced by `api_service.dart` |
| `lib/services/storage_service.dart` | Image uploads now handled as multipart via the API |

## Files Modified

### Dependencies — `pubspec.yaml`

| Added | Removed |
|-------|---------|
| `dio: ^5.4.0` | `firebase_auth: ^4.17.0` |
| `flutter_secure_storage: ^9.0.0` | `cloud_firestore: ^4.15.0` |
| | `firebase_storage: ^11.6.0` |

Kept: `firebase_core`, `firebase_messaging` (for FCM).

### Constants — `lib/core/constants/app_constants.dart`

- Added `apiBaseUrl` (set your backend URL here)
- Removed Firestore collection names (`usersCollection`, `bookingsCollection`, etc.)
- Aligned `issueTypes` and `wasteTypes` lists with backend-expected values

### Models

All 5 models updated to remove Firestore dependencies:

| Model | Changes |
|-------|---------|
| `user_model.dart` | Removed `cloud_firestore` import, `Timestamp`, `DocumentSnapshot`. Added `fromJson()` with snake_case mapping. `toJson()` only sends editable fields. |
| `booking_model.dart` | Same pattern. Added `latitude`/`longitude` fields. `toJson()` sends only create-booking fields. |
| `report_model.dart` | Same pattern. `fromJson()` only (create goes via multipart). |
| `transaction_model.dart` | Same pattern. Added `withdrawn` type. |
| `collector_model.dart` | Same pattern. |

### Services

| File | Changes |
|------|---------|
| `auth_service.dart` | **Full rewrite.** Firebase phone auth → HTTP `POST /auth/send-otp` + `POST /auth/verify-otp`. Returns JWT, stores via `SecureStorageHelper`. Callback changed from `onCodeSent(verificationId)` → `onSuccess()`. Added `isLoggedIn()` check. |
| `payment_service.dart` | No changes (Razorpay stays client-side). |
| `location_service.dart` | No changes (pure client-side GPS). |

### Providers

| File | Changes |
|------|---------|
| `user_provider.dart` | Uses `ApiService` instead of `FirestoreService`. `loadUser()` no longer takes `uid` param (JWT identifies user). `updateUser()` takes named params (`name`, `ward`, `address`). `redeemPoints()` calls API + reloads profile. `dailyCheckIn()` calls API. `logout()` clears JWT. Added `setUser()` and `sendFcmToken()`. |
| `booking_provider.dart` | Uses `ApiService`. `createBooking()` takes named params instead of `BookingModel`. `loadUserBookings()` takes optional `status` filter. |
| `report_provider.dart` | Uses `ApiService`. `createReport()` takes named params + optional `File image` (multipart upload). |

### Auth Screens

| File | Changes |
|------|---------|
| `login_screen.dart` | `_sendOTP()` callback changed: `onCodeSent(verificationId)` → `onSuccess()`. Route args no longer include `verificationId`. |
| `otp_verification_screen.dart` | **Significant change.** Removed `verificationId` constructor param. Removed `FirebaseAuth`/`FirestoreService` imports. OTP verify calls `AuthService.verifyOtp(phone, otp)` → gets JWT + user. Sets user in provider. Resend calls `AuthService.sendOtp()`. |

### Other Screens (minimal changes — no UI touched)

| File | Changes |
|------|---------|
| `main_app.dart` | `_loadUser()` checks `AuthService.isLoggedIn()` instead of `FirebaseAuth.instance.currentUser`. Calls `loadUser()` without uid. |
| `report_issue_screen.dart` | Removed `StorageService`. Submit calls provider's `createReport()` with named params + `File`. Removed `uuid`, `ReportModel` imports. |
| `book_pickup_screen.dart` | Submit calls provider's `createBooking()` with named params. Removed `BookingModel`, `uuid` imports. |
| `wallet_screen.dart` | Transactions loaded via `ApiService.getTransactions()` instead of Firestore. |
| `rewards_screen.dart` | Leaderboard loaded via `ApiService.getLeaderboard()` instead of Firestore. |
| `edit_profile_sheet.dart` | `updateUser()` call changed to named params. |
| `app_routes.dart` | OTP screen args: removed `verificationId`, only passes `phoneNumber`. |
| `app.dart` | Added `navigatorKey` from `ApiClient` for global 401 redirect. |

---

## Auth Flow Change

```
BEFORE (Firebase):
Phone → Firebase verifyPhoneNumber → codeSent(verificationId)
     → Enter OTP → signInWithCredential(verificationId + OTP)
     → FirebaseAuth User → Firestore lookup/create

AFTER (Go Backend):
Phone → POST /auth/send-otp { phone_number }
     → Enter OTP → POST /auth/verify-otp { phone_number, otp }
     → JWT token + user data → Store JWT in SecureStorage
     → All subsequent requests: Authorization: Bearer <JWT>
```

---

## API Endpoints Used

```
PUBLIC:
  POST   /auth/send-otp
  POST   /auth/verify-otp

USER (Bearer token required):
  GET    /user/profile
  PATCH  /user/profile
  POST   /user/checkin
  POST   /reports              (multipart/form-data)
  GET    /reports              (?status=&issue_type=&page=&limit=)
  GET    /reports/:id
  POST   /bookings
  GET    /bookings             (?status=&page=&limit=)
  GET    /bookings/:id
  PATCH  /bookings/:id/status
  GET    /wallet
  POST   /wallet/redeem
  POST   /wallet/withdraw
  GET    /wallet/transactions  (?type=&page=&limit=)
  GET    /leaderboard          (?ward=&limit=)
  GET    /leaderboard/me       (?ward=)
  GET    /badges/user
```

---

## Setup — What You Need To Do

### 1. Set your backend URL

In `lib/core/constants/app_constants.dart`:

```dart
static const String apiBaseUrl = 'https://your-backend-url.com/api/v1';
```

### 2. Keep Firebase config for FCM

`google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are still needed for push notifications.

### 3. Register FCM token after login

The app should call this after login and on token refresh:

```dart
final fcmToken = await FirebaseMessaging.instance.getToken();
await userProvider.sendFcmToken(fcmToken!);
```

---

## Error Handling

The `ApiClient` interceptor handles:

| HTTP Code | Action |
|-----------|--------|
| 401 | Clears JWT, redirects to login screen |
| 429 | Auth service shows "Too many attempts" message |
| Other errors | Propagated to callers via `DioException` |

---

## What Was NOT Changed

- All UI/screens (layouts, animations, themes, colors)
- `location_service.dart` (pure client-side GPS)
- `payment_service.dart` (Razorpay stays client-side)
- `main.dart` (still inits Firebase for FCM)
- All widget files in `core/widgets/`
- All theme files in `core/theme/`
- Splash, onboarding, home, map, profile, statistics screens (no service-level changes)
