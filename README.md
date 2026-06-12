# ♻️ SafaiPay – Clean Actions. Real Rewards. 🇮🇳

SafaiPay is a **comprehensive Flutter + Firebase civic-tech platform** that incentivizes citizens to keep their cities clean by rewarding cleanliness actions with real points and money.

> **Report issues. Book pickups. Earn rewards. Make your city cleaner.**

---

##  Features

###  **User Features**

-  **Phone OTP Authentication** (Firebase Auth)
-  **Premium Animated Home Dashboard**
  - Wallet card with points & balance
  - Quick actions (Report, Book, Check-in, Rewards)
  - Impact tracker with progress bars
  - Community rank card
- **Report Cleanliness Issues**
  - Camera capture
  - Auto GPS location
  - Issue categorization
  - +5 points per report
-  **Book Garbage Pickup**
  - Schedule date & time
  - Select waste type
  - Track status
  - Collector assignment
-  **City Cleanliness Map**
  - Google Maps integration
  - Report markers (red = pending, green = resolved)
  - Real-time location
-  **SafaiPay Wallet**
  - Points management
  - Redeem points to wallet
  - Withdraw to bank (Razorpay)
  - Transaction history
- **Rewards & Leaderboard**
  - Unlock badges
  - Ward-level rankings
  - Community competition
-  **Profile & Settings**
  - User stats
  - Streak tracking
  - Account management

### 🎨 **Design Highlights**

- Modern glassmorphism UI
- Smooth animations throughout
- Professional green & white color palette
- Google Fonts (Poppins + Inter)
- Shimmer loading effects
- Micro-interactions

---

## 🛠️ Tech Stack

### Frontend

- **Flutter** (Dart 3.2+)
- **Material 3** design
- **Provider** for state management
- **Google Fonts**

### Backend & Services

- **Firebase Auth** (Phone OTP)
- **Cloud Firestore** (Database)
- **Firebase Storage** (Images)
- **Firebase Cloud Messaging** (Notifications)

### Third-Party Integrations

- **Google Maps** (City map & location)
- **Razorpay** (Payment gateway)
- **Geolocator** (GPS location)
- **Image Picker** (Camera/Gallery)

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_gradients.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── widgets/
│       ├── glass_card.dart
│       ├── primary_button.dart
│       ├── quick_action_card.dart
│       ├── wallet_card.dart
│       └── waste_chip.dart
│
├── models/
│   ├── user_model.dart
│   ├── booking_model.dart
│   ├── report_model.dart
│   ├── transaction_model.dart
│   └── collector_model.dart
│
├── providers/
│   ├── user_provider.dart
│   ├── booking_provider.dart
│   └── report_provider.dart
│
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── location_service.dart
│   ├── payment_service.dart
│   └── storage_service.dart
│
├── features/
│   ├── splash/
│   ├── onboarding/
│   ├── auth/
│   ├── main/
│   ├── home/
│   ├── booking/
│   ├── report/
│   ├── map/
│   ├── wallet/
│   ├── rewards/
│   └── profile/
│
├── routes/
│   └── app_routes.dart
│
├── app.dart
└── main.dart
```

---

## 🔧 Setup Instructions

### Prerequisites

- Flutter SDK (3.2.0 or higher)
- Android Studio / VS Code
- Firebase Project
- Google Maps API Key
- Razorpay Account (optional for payments)

### 1. Clone & Install Dependencies

```bash
cd /app
flutter pub get
```

### 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing
3. Enable **Phone Authentication**
4. Download `google-services.json` → Place in `android/app/`
5. Download `GoogleService-Info.plist` → Place in `ios/Runner/`
6. Run FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

### 3. Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **Maps SDK for Android** & **Maps SDK for iOS**
3. Create API Key
4. Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```

### 4. Razorpay Setup (Optional)

1. Sign up at [Razorpay](https://razorpay.com/)
2. Get API Key from Dashboard
3. Update in `lib/services/payment_service.dart`:
   ```dart
   'key': 'YOUR_RAZORPAY_KEY_HERE',
   ```

### 5. Run the App

```bash
flutter run
```

---

## 📊 Firestore Collections Structure

### users

```json
{
  "phoneNumber": "+919876543210",
  "name": "John Doe",
  "ward": "Ward 5",
  "address": "123 Main St",
  "points": 150,
  "walletBalance": 100,
  "totalReports": 10,
  "totalBookings": 5,
  "streak": 7,
  "createdAt": "timestamp",
  "lastCheckIn": "timestamp"
}
```

### bookings

```json
{
  "userId": "uid",
  "userName": "John Doe",
  "phoneNumber": "+919876543210",
  "address": "123 Main St",
  "wasteType": "Dry Waste",
  "bookingDate": "timestamp",
  "timeSlot": "6:00 AM - 8:00 AM",
  "status": "pending",
  "collectorId": "collector_uid",
  "collectorName": "Collector Name",
  "weight": 5.5,
  "pointsEarned": 55,
  "imageUrl": "url",
  "createdAt": "timestamp"
}
```

### reports

```json
{
  "userId": "uid",
  "userName": "John Doe",
  "issueType": "Overflowing Bin",
  "description": "Bin overflowing for 3 days",
  "latitude": 28.6139,
  "longitude": 77.209,
  "address": "123 Main St",
  "imageUrl": "url",
  "status": "pending",
  "pointsEarned": 5,
  "createdAt": "timestamp"
}
```

### transactions

```json
{
  "userId": "uid",
  "type": "earned",
  "points": 5,
  "description": "Reported issue: Overflowing Bin",
  "createdAt": "timestamp"
}
```

---

## 🎯 Points System

| Action           | Points      |
| ---------------- | ----------- |
| Daily Check-in   | +2          |
| Report Issue     | +5          |
| Completed Pickup | +10 per kg  |
| 7-day Streak     | Bonus Badge |

**Redemption:** 1 Point = ₹1

---

## 🔐 Permissions Required

### Android

- `INTERNET`
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `CAMERA`
- `READ_EXTERNAL_STORAGE`
- `WRITE_EXTERNAL_STORAGE`

### iOS

- Add to `Info.plist`:
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>We need your location to show nearby cleanliness issues</string>
  <key>NSCameraUsageDescription</key>
  <string>We need camera access to report issues</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>We need photo access to report issues</string>
  ```

---

## 📱 App Flow

```
Splash → Onboarding → Login → OTP → Home Dashboard
                                          ↓
                        ┌─────────────────┴─────────────────┐
                        ↓                 ↓                 ↓
                     Report           Booking            Wallet
                     Issue            Pickup            & Rewards
```

---

## 🚧 Known Limitations

1. **Google Maps API Key**: Needs to be added (currently placeholder)
2. **Razorpay Key**: Needs to be added for real payments
3. **Collector Assignment**: Currently manual (can be automated)
4. **Push Notifications**: FCM setup needed

---


Future Scope-

Offline-First - Foundation for reliability
Image Upload - Core feature for reports
Notifications - Keep users engaged
Payment System - Revenue generation
Real-time Leaderboard - Engagement boost
Badges - Gamification
Collector App - Operational capability
Admin Dashboard - Management
Advanced Search - User experience
Personalized Notifications - Retention

