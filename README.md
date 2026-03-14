# ♻️ SafaiPay – Clean Actions. Real Rewards. 🇮🇳

SafaiPay is a **comprehensive Flutter + Firebase civic-tech platform** that incentivizes citizens to keep their cities clean by rewarding cleanliness actions with real points and money.

> **Report issues. Book pickups. Earn rewards. Make your city cleaner.**

---

## 🚀 Features

### 👤 **User Features**

- ✅ **Phone OTP Authentication** (Firebase Auth)
- ✅ **Premium Animated Home Dashboard**
  - Wallet card with points & balance
  - Quick actions (Report, Book, Check-in, Rewards)
  - Impact tracker with progress bars
  - Community rank card
- ✅ **Report Cleanliness Issues**
  - Camera capture
  - Auto GPS location
  - Issue categorization
  - +5 points per report
- ✅ **Book Garbage Pickup**
  - Schedule date & time
  - Select waste type
  - Track status
  - Collector assignment
- ✅ **City Cleanliness Map**
  - Google Maps integration
  - Report markers (red = pending, green = resolved)
  - Real-time location
- ✅ **SafaiPay Wallet**
  - Points management
  - Redeem points to wallet
  - Withdraw to bank (Razorpay)
  - Transaction history
- ✅ **Rewards & Leaderboard**
  - Unlock badges
  - Ward-level rankings
  - Community competition
- ✅ **Profile & Settings**
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

## 🤝 Contributing

This is a complete MVP ready for production deployment. To contribute:

1. Fork the repo
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

---

## 📄 License

MIT License - Free to use for civic projects

---

## 👨‍💻 Developed By

**Built with ❤️ using Flutter**

For support: Open an issue on GitHub

---

## 🎉 What's Next?

- [ ] Admin panel for municipalities
- [ ] Garbage collector app
- [ ] AI-powered waste classification
- [ ] Social sharing features
- [ ] Multi-language support
- [ ] Dark mode

---

**SafaiPay - Making India Cleaner, One Action at a Time! 🇮🇳♻️**

🚀 SafaiPay Features Implementation - Complete Prompts

Pick the feature you want to implement and use the corresponding prompt:

1️⃣ Offline-First Architecture

Code
I'm building SafaiPay, a Flutter + Firebase civic-tech platform (GitHub: https://github.com/indwar7/SafaiPay).

I need to implement OFFLINE-FIRST ARCHITECTURE so users can:

- View cached reports even without internet
- Queue new reports/bookings while offline
- Auto-sync when connection is restored
- Handle sync conflicts gracefully

**Current Setup:**

- Provider for state management
- Firestore for data
- Firebase Storage for images
- SQLite should be used for local cache

**What I Need:**

1. **Database Schema** (SQLite)
   - Users table (cached user data)
   - Reports table (with sync status flag)
   - Bookings table (with sync status flag)
   - Transactions table
   - Sync queue table

2. **Services to Create/Modify:**
   - `offline_service.dart` - Handle local DB operations
   - `sync_service.dart` - Sync queued data with Firebase
   - Modify `firestore_service.dart` - Check local cache first
   - `connectivity_service.dart` - Monitor internet connection

3. **Provider Updates:**
   - Modify providers to check offline cache first
   - Add sync status tracking
   - Handle offline/online transitions

4. **UI Indicators:**
   - Show "Offline Mode" badge
   - Disable/grey out unavailable features
   - Show sync progress indicator
   - Notify user when data synced

**Specific Requirements:**

- Production-ready code with error handling
- Proper transaction handling in SQLite
- Conflict resolution strategy (last-write-wins or timestamp-based)
- Test strategy included
- Performance optimized (lazy loading, pagination)

**Code Examples Needed:**

- Complete SQLite database helper
- Sync service with batch operations
- Modified firestore_service with cache checking
- Updated provider logic
- UI widgets for offline indicators

Please provide full implementation with comments and best practices.
2️⃣ Real-time Leaderboard

Code
I'm building SafaiPay (Flutter + Firebase civic-tech platform).

I need to implement a REAL-TIME LEADERBOARD SYSTEM where:

- Users see live rankings by ward/city
- Rankings update in real-time as users earn points
- Show top 10, top 100, and user's position
- Filter by ward, city, or all-time
- Show badges and streaks

**Current Setup:**

- Firestore database
- Provider state management
- Users collection with points field

**What I Need:**

1. **Firestore Collection Structure:**
   - Optimize users collection for leaderboard queries
   - Create indexes for fast querying
   - Suggested fields for leaderboard doc

2. **Services:**
   - `leaderboard_service.dart` - Fetch rankings efficiently
   - Implement pagination (top 10, 100, etc.)
   - Real-time listener with Firestore stream
   - Cache strategy for performance

3. **Providers:**
   - `leaderboard_provider.dart` - Manage leaderboard state
   - Handle real-time updates
   - Track user's position
   - Filter/sort options

4. **Models:**
   - `leaderboard_entry_model.dart` with rank, points, badge, streak
   - Serialize/deserialize from Firestore

5. **UI Screens:**
   - Global leaderboard screen
   - Ward-specific leaderboard
   - User profile with rank badge
   - Position indicator (me vs others)

**Specific Requirements:**

- Real-time streaming (Firestore listeners)
- Pagination (load top 100, then more on demand)
- Optimized queries (indexes recommended)
- Display rank changes (up/down indicators)
- Show badges for achievements
- Performance optimized for 100k+ users

**Features:**

- Rank change animation
- Show user's current rank prominently
- Filter by ward
- Time-based leaderboards (weekly, monthly, all-time)
- Share rank feature

Please provide:

1. Firestore schema with indexes
2. leaderboard_service.dart (with pagination)
3. leaderboard_provider.dart
4. UI screens with animations
5. Best practices for scaling
   3️⃣ Real-time Notifications with FCM

Code
I'm building SafaiPay (Flutter + Firebase civic-tech platform).

I need to implement PUSH NOTIFICATIONS using Firebase Cloud Messaging (FCM):

- Notify users when their reports are resolved
- Alert collectors about new bookings
- Send streak reminders
- Leaderboard position changes
- Reward redemption confirmations

**Current Setup:**

- Firebase already configured
- Provider state management
- Firestore backend

**What I Need:**

1. **FCM Setup:**
   - Initialize FCM in app
   - Handle token management and updates
   - Store tokens in Firestore users collection
   - Handle token refresh

2. **Services:**
   - `notification_service.dart` - Initialize and manage FCM
   - `fcm_handler.dart` - Handle foreground/background messages
   - `notification_payload_parser.dart` - Parse notification data

3. **Local Notifications:**
   - Use `flutter_local_notifications` for display
   - Custom notification designs
   - Handle notification taps/deep linking
   - Sound and vibration

4. **Cloud Functions** (Node.js):
   - Trigger notifications on:
     - Report status changed to "resolved"
     - New booking assigned to collector
     - User reaches 7-day streak
     - User enters top 10 leaderboard
     - Points redeemed successfully
   - Batch notifications
   - Schedule reminders

5. **Providers & Models:**
   - `notification_provider.dart` - Track notification state
   - `notification_model.dart` - Model for notification data
   - In-app notification center with history

6. **UI Components:**
   - Notification badge on app icon
   - In-app notification banner
   - Notification center/history screen
   - Notification settings (enable/disable per type)

**Specific Requirements:**

- Handle both foreground and background messages
- Deep linking to relevant screens
- Don't lose notifications while app is closed
- User privacy (don't expose sensitive data in notification)
- Opt-in/opt-out for different notification types
- Notification grouping
- Actionable notifications (buttons in notification)

**Testing:**

- Test foreground/background handling
- Test with app closed
- Test deep linking
- Test with multiple notification types

Please provide:

1. Complete FCM setup code
2. Notification service
3. Local notifications integration
4. Cloud Functions for triggering
5. Updated user model with token
6. Settings screen for notifications
7. Deep linking implementation
   4️⃣ Image Upload with Optimization

Code
I'm building SafaiPay (Flutter + Firebase civic-tech platform).

I need to implement IMAGE UPLOAD WITH OPTIMIZATION:

- Users upload photos of cleanliness issues
- Compress images before upload
- Generate thumbnails
- Cache images locally
- Progress indicator during upload
- Handle network interruptions

**Current Setup:**

- Firebase Storage for images
- Image Picker for camera/gallery
- Using geolocator for location

**What I Need:**

1. **Image Processing:**
   - Compress images (80% quality target, max 2MB)
   - Generate multiple sizes (full, thumbnail, preview)
   - Optimize for different screen sizes
   - EXIF data handling (preserve or remove based on privacy)
   - Batch processing for multiple images

2. **Services:**
   - `image_service.dart` - Compress and process images
   - `storage_service.dart` (enhanced) - Upload with progress
   - `image_cache_service.dart` - Cache locally with sqflite
   - Handle upload resumption on network loss

3. **Providers:**
   - `image_upload_provider.dart` - Track upload state
   - Handle multiple simultaneous uploads
   - Queue management for failed uploads
   - Progress tracking (bytes/percentage)

4. **Models:**
   - `image_data_model.dart` - Store image metadata
   - Track compression ratio, original size, compressed size
   - Store local cache path and Firebase URL

5. **UI Components:**
   - Image picker with preview
   - Upload progress indicator
   - Retry on failed upload
   - Show uploaded image with spinner while uploading
   - Gallery view for multiple images
   - Cancel upload button

6. **Firebase Storage:**
   - Folder structure: `/reports/{userId}/{reportId}/images/`
   - Versioning: keep compressed and thumbnail versions
   - Set expiration for unused images (30 days)

**Specific Requirements:**

- Async processing (don't block UI)
- Support batch uploads
- Handle large files (up to 10MB original)
- Resume interrupted uploads
- Low bandwidth optimization
- Memory efficient (don't load full res in memory)
- Test with slow networks

**Features:**

- Drag & drop on web
- Multiple image selection
- Image cropping/rotation before upload
- Upload queue persistence
- Bandwidth estimation
- Background upload when app closed

Please provide:

1. Image compression service
2. Storage service with progress
3. Image cache service (SQLite)
4. Upload provider with queue
5. UI screens for image upload
6. Firebase Storage rules
7. Background upload handling
   5️⃣ Gamification - Badges & Achievements

Code
I'm building SafaiPay (Flutter + Firebase civic-tech platform).

I need to implement GAMIFICATION with BADGES & ACHIEVEMENTS to boost engagement:

- Users unlock badges for actions (Report 10 issues, 7-day streak, etc.)
- Show achievement notifications
- Display badges on profile
- Achievements page with progress bars
- Share achievements on social media

**Current Setup:**

- Firestore for data
- Points system: +5 for report, +2 daily check-in, +10 per kg pickup
- Provider for state management

**What I Need:**

1. **Badge System Design:**
   - Define 15-20 badges/achievements
   - Examples:
     - "Clean Start" - First report
     - "Streak Master" - 7 consecutive days
     - "Reporter" - Report 10 issues
     - "Community Hero" - Top 10 leaderboard
     - "Eco Warrior" - Collect 100kg waste
     - "Night Owl" - Report at midnight
     - "Speed Demon" - Report 5 issues in day
     - "Wealthy" - Accumulate 1000 points
     - "Generous" - Redeem first reward
     - Custom badges (limited time events)

2. **Database Schema:**
   - `badges` collection - Badge definitions with:
     - ID, name, description, icon URL
     - Tier (bronze/silver/gold)
     - Unlock condition (trigger type, threshold)
     - Reward (bonus points, icon, prestige)
   - `user_badges` collection - Track unlocked badges
     - Badge ID, unlock timestamp, progress

3. **Services:**
   - `badge_service.dart` - Check and award badges
   - `achievement_service.dart` - Track progress
   - Listen to user actions (reports, points, streaks) and award

4. **Providers:**
   - `badge_provider.dart` - Manage badge state
   - Track progress toward badges
   - Handle achievement unlocks
   - Notification on unlock

5. **Models:**
   - `badge_model.dart` - Badge definition
   - `user_badge_model.dart` - User's earned badge
   - `achievement_progress_model.dart` - Progress tracking

6. **UI Components:**
   - Badge showcase on profile
   - Achievement progress page
   - Unlock animation + celebration
   - Achievement card with details
   - Social share button for achievements
   - Locked vs unlocked state indicators
   - Progress bar for in-progress achievements

7. **Firestore Structure:**
   /badges/{badgeId}

name, description, icon
unlockTrigger: {type, threshold, value}
tier, points
/users/{userId}/badges/{badgeId}

unlockedAt: timestamp
progress: current value
Code

**Specific Requirements:**

- Real-time progress tracking
- Prevent duplicate awards
- Celebration animation on unlock
- Sound effect on unlock (optional)
- Notification to user
- Social sharing integration
- Mobile-first UI
- Performant queries

**Bonus Features:**

- Time-limited badges (seasonal)
- Badge collections/sets (unlock all = bonus)
- Tiered badges (bronze → silver → gold)
- Leaderboard by badge count
- Badge trading/gifting (future)

Please provide:

1. Complete badge definitions (15-20)
2. Badge model and schema
3. Badge service (unlock logic)
4. Badge provider
5. Achievement progress tracking
6. Unlock animation UI
7. Profile badge display
8. Achievements page with filters
9. Social share implementation
   6️⃣ Payment & Wallet System (Razorpay)

Code
I'm building SafaiPay (Flutter + Firebase civic-tech platform).

I need to implement SECURE PAYMENT & WALLET SYSTEM:

- Users redeem points to wallet balance
- Withdraw money to bank account (Razorpay)
- Track transaction history
- Prevent fraud
- Instant confirmations

**Current Setup:**

- Points system: 1 Point = ₹1
- Razorpay account ready
- Firestore for data
- Provider state management

**What I Need:**

1. **Wallet System:**
   - Points balance (in-app currency)
   - Wallet balance (actual money, in rupees)
   - Transaction history with filters
   - Pending withdrawals tracking
   - Redeem rate (1 Point = ₹1)

2. **Services:**
   - `payment_service.dart` (enhanced)
     - Initialize Razorpay
     - Create payment orders
     - Handle payment callbacks
   - `wallet_service.dart`
     - Redeem points to wallet
     - Process withdrawals
     - Fetch balance and history
   - `transaction_service.dart`
     - Log all transactions
     - Generate receipts

3. **Cloud Functions** (Node.js):
   - Verify Razorpay payment signatures
   - Update wallet balance server-side
   - Process withdrawal requests
   - Send transaction receipts via email/SMS
   - Fraud detection (rapid redemptions, suspicious patterns)
   - Failed payment cleanup

4. **Providers:**
   - `wallet_provider.dart` - Manage wallet state
   - Track points and balance
   - Handle redemption flow
   - Transaction history

5. **Models:**
   - `wallet_model.dart` - Points & balance
   - `transaction_model.dart` - Transaction details
   - `payment_model.dart` - Payment status
   - `withdrawal_model.dart` - Withdrawal request

6. **Firestore Collections:**
   /users/{userId}

points: number
walletBalance: number
totalRedeemed: number
bankAccount: {name, ifsc, accountNumber}
/users/{userId}/transactions

type: "earned" | "redeemed" | "withdrawn"
amount: number
status: "pending" | "completed" | "failed"
timestamp
description
/withdrawals/{withdrawalId}

userId, amount, status
bankDetails, razorpayRefId
requestedAt, completedAt
notes
Code

7. **UI Screens:**

- Wallet dashboard
  - Points balance (large)
  - Wallet balance (large)
  - Quick redeem button
  - Quick withdraw button
- Redeem flow
  - Enter amount in points
  - Confirm redeem
  - Success animation
- Withdraw flow
  - Enter bank details (one time)
  - Enter amount
  - Confirm with OTP
  - Processing screen
- Transaction history
  - Filter by type/date
  - Search by amount
  - Download receipt
- Bank details management
  - Add/edit bank account
  - Verify account details

**Security Requirements:**

- Server-side validation of redemptions
- Prevent negative balance exploits
- Rate limit withdrawal requests
- Verify Razorpay signatures
- PCI compliance for bank details
- Encrypt sensitive data
- Audit trail for all transactions
- OTP verification for withdrawals

**Specific Requirements:**

- Handle payment failures gracefully
- Retry logic for failed transactions
- Real-time balance updates
- Transaction receipts (PDF)
- Email/SMS notifications
- Reconciliation with Razorpay
- Minimum withdrawal amount (₹100)
- Maximum daily withdrawal (₹50,000)
- Charge minimal fees (0-2%)

**Testing:**

- Test with Razorpay test keys
- Test successful and failed payments
- Test withdrawal flow
- Test fraud scenarios
- Test concurrent transactions

Please provide:

1. Complete payment_service implementation
2. Wallet service with redemption logic
3. Cloud Functions for verification
4. Firestore schema with indexes
5. Updated user model
6. Wallet provider
7. All UI screens (redeem, withdraw, history)
8. Receipt generation (PDF)
9. Security best practices
10. Testing strategy
    7️⃣ Admin Dashboard (Web)

Code
I'm building SafaiPay (Flutter + Firebase civic-tech platform).

I need to create an ADMIN DASHBOARD (Web) to manage:

- View all reports with status
- Assign collectors to tasks
- Monitor real-time analytics
- User management
- Payment verification
- Issue resolution

**Current Setup:**

- Flutter mobile app (users + collectors)
- Firestore backend
- Cloud Functions ready

**What I Need:**

1. **Dashboard Overview:**
   - Total users, reports, bookings
   - Points distributed today
   - Revenue generated
   - Active users (real-time)
   - Top issues by type
   - Map showing reports

2. **Report Management:**
   - List of all reports (with filters)
   - Status: pending → assigned → completed
   - Mark as resolved
   - Assign to collectors
   - View photos and location
   - Add notes/comments

3. **Booking Management:**
   - List all bookings
   - Assign collectors
   - Track completion
   - Generate collection statistics

4. **User Management:**
   - View all users
   - User details (points, wallet, stats)
   - Ban/suspend users (spam/fraud)
   - Verify bank details
   - Manual point adjustments

5. **Analytics & Reports:**
   - Charts: Reports over time, bookings, revenue
   - Top collectors, top reporters
   - Waste collection stats (by type/weight)
   - City cleanliness metrics
   - Ward-wise statistics
   - User retention, DAU/MAU

6. **Payment Management:**
   - Pending withdrawals
   - Verify Razorpay transactions
   - Process payouts manually
   - Transaction history
   - Fraud detection

7. **Settings & Configuration:**
   - Update point values
   - Manage badges
   - Set withdrawal limits
   - Admin user management
   - Audit logs

**Tech Stack for Admin:**

- Next.js or Flutter Web (choose one)
- Firebase Admin SDK
- Firestore database
- Charts library (Chart.js, Recharts)
- Authentication (Firebase or custom)

**Firestore Collections Needed:**
/admins/{adminId}

email, name, role, permissions
createdAt
/audit_logs/{logId}

action, adminId, changes
timestamp, targetId
Code

**Features:**

- Real-time dashboards (using Firestore listeners)
- Bulk operations (assign multiple collectors)
- Export reports (CSV/PDF)
- Email notifications
- Role-based access (super-admin, moderator)
- Dark mode
- Mobile responsive

**Security:**

- Firebase Auth with email
- Admin role verification
- Audit trail for all actions
- IP whitelisting (optional)
- Activity logging

Please provide:

1. Admin dashboard architecture
2. Firestore queries for analytics
3. Cloud Functions for admin actions
4. UI mockups/components (if Next.js)
5. Authentication system
6. Real-time data fetching
7. Charts and visualizations
8. Bulk operation handlers
9. Export functionality
10. Deployment guide
    8️⃣ Collector App (Separate Flutter App)

Code
I'm building SafaiPay (Flutter + Firebase civic-tech platform).

I need to create a COLLECTOR APP (Separate Flutter App) for waste collectors to:

- View assigned bookings
- Navigate to locations
- Mark collection complete
- Photograph waste
- Track earnings
- Get performance stats

**Current Setup:**

- Main app for citizens (reports, bookings, wallet)
- Firestore backend
- Google Maps integration

**What I Need:**

1. **Authentication:**
   - Phone OTP login (separate from users)
   - Collector verification
   - Document upload (ID, bank details)

2. **Dashboard:**
   - Active bookings count
   - Today's earnings
   - Performance metrics
   - Rating/reviews

3. **Bookings Management:**
   - List of assigned bookings (today, upcoming)
   - Booking details (address, waste type, contact)
   - Map navigation to location
   - Estimated time to reach
   - Track location in real-time
   - Status: assigned → en-route → arrived → collecting → completed

4. **Collection Process:**
   - Checklist of waste types
   - Measure/weigh waste collected
   - Photograph before & after
   - Add notes
   - Get user's signature/confirmation (optional)
   - Calculate points earned
   - Generate receipt

5. **Earnings & Wallet:**
   - Today's earnings breakdown
   - Weekly/monthly stats
   - Points vs money earned
   - Withdraw functionality
   - Bank details management
   - Withdraw history

6. **Performance:**
   - Collection statistics
   - Ratings from users
   - Feedback/reviews
   - Performance bonus eligibility
   - Leaderboard (collectors only)

7. **Support:**
   - Report issues
   - Chat with support
   - FAQ section
   - Emergency contact

**Firestore Collections:**
/collectors/{collectorId}

name, phone, email
ward, area
bankDetails
documents: {idUrl, addressUrl}
rating, totalCollected
joinedAt
/collector_bookings/{bookingId}

userId, collectorId
status: pending → accepted → arrived → completed
location, wasteType
weight
photos: [urls]
earnings
createdAt, completedAt
/collector_earnings/{collectorId}/daily/{date}

totalCollected, totalEarned
bookingsCompleted
Code

**Features:**

- Real-time booking notifications
- Route optimization (multiple stops)
- Auto-calculation of weight/points
- Incentives for speed/efficiency
- Supervisor view (see collector locations)
- Offline access to active bookings

**UI Screens:**

1. Authentication (phone + document upload)
2. Dashboard (earnings, active bookings)
3. Bookings list
4. Booking detail with map
5. Collection form (checklist, photos, weight)
6. Receipt generation
7. Earnings history
8. Performance stats
9. Profile & settings
10. Chat support

Please provide:

1. Collector authentication flow
2. Firestore schema for collectors
3. Booking assignment system
4. Collection tracking UI
5. Real-time location sharing
6. Earnings calculation
7. Performance analytics
8. Notification system
9. Document verification process
10. Supervisor dashboard
    9️⃣ Advanced Filtering & Search

Code
I'm building SafaiPay (Flutter + Firebase civic-tech platform).

I need to implement ADVANCED FILTERING & SEARCH:

- Users filter reports by type, status, date
- Search on map
- Advanced leaderboard filters
- Activity history filtering
- Transaction search

**Current Setup:**

- Firestore with reports, bookings, users collections
- Provider for state management
- Google Maps for visualization

**What I Need:**

1. **Report Filtering:**
   - By status (pending, in-progress, resolved)
   - By issue type (overflowing bin, pothole, dirty street, etc.)
   - By date range
   - By location (radius search)
   - By reporter
   - Combined filters

2. **Search Implementation:**
   - Full-text search on reports (description, location)
   - User search (leaderboard)
   - Address search with Google Places API
   - Fuzzy matching

3. **Firestore Indexes:**
   - Create composite indexes for filtered queries
   - Optimize for common filter combinations
   - Performance considerations

4. **Services:**
   - `search_service.dart` - Handle search queries
   - `filter_service.dart` - Complex filtering logic
   - Pagination with filters

5. **Providers:**
   - `report_filter_provider.dart` - Filter state
   - `search_provider.dart` - Search state
   - Manage selected filters, results, pagination

6. **Models:**
   - `filter_model.dart` - Represent applied filters
   - `search_result_model.dart` - Search results with relevance

7. **UI Components:**
   - Filter sheet (bottom sheet with options)
   - Filter chips (show active filters)
   - Search bar with autocomplete
   - Date range picker
   - Location radius selector
   - Results count indicator
   - Sorting options (date, relevance, distance)

8. **Map Integration:**
   - Filter markers on map
   - Show only matching reports
   - Cluster markers by filter
   - Draw radius circle for location filter

**Firestore Queries:**

- Single filter queries (work without indexes)
- Compound filters (need indexes)
- Geoqueries for distance-based search
- Text search with Algolia or custom solution

**Performance:**

- Pagination (50 results per page)
- Cache filter results
- Lazy load more results
- Debounce search input

**Features:**

- Save filter presets
- Share filtered results
- Export filtered data
- Search history
- Suggestions while typing

Please provide:

1. Filter service with all combinations
2. Search service implementation
3. Firestore indexes needed
4. Filter provider
5. Search provider
6. UI screens for filtering
7. Map filtering logic
8. Pagination with filters
9. Performance optimization tips
   🔟 Push Notifications & Engagement

Code
I'm building SafaiPay (Flutter + Firebase civic-tech platform).

I need to implement PERSONALIZED PUSH NOTIFICATIONS:

- Smart timing (when users are active)
- Engagement reminders
- Streak notifications
- Achievement unlocks
- Leaderboard changes
- Report updates

**Current Setup:**

- Firebase Cloud Messaging ready
- Provider for state management
- Firestore user data

**What I Need:**

1. **Notification Types:**
   - Report resolved (with before/after photos)
   - Booking assignment to collector
   - Collector nearby (location alert)
   - Streak reminder (3pm if no action today)
   - Leaderboard changes (entered top 10)
   - Achievement unlocked (celebration)
   - Special events (weekend challenges)
   - Points expiring soon
   - New feature announcements

2. **Smart Timing:**
   - User activity analysis
   - Send at optimal time (high engagement time)
   - Frequency capping (not too many)
   - Time zone aware
   - Respect quiet hours

3. **Services:**
   - `engagement_service.dart` - Track user engagement
   - `notification_scheduler.dart` - Smart scheduling
   - `fcm_enhanced_service.dart` - Rich notifications
   - Analytics tracking

4. **Cloud Functions** (Node.js):
   - Trigger notifications based on actions
   - Schedule daily reminders
   - Calculate optimal send time
   - A/B test message variants
   - Track delivery & engagement

5. **Providers:**
   - `engagement_provider.dart` - Track engagement metrics
   - Notification history
   - User preferences

6. **Firestore Schema:**
   /users/{userId}/notification_settings

enabled: boolean
quietHours: {start, end}
preferences: { reportUpdates: true, leaderboard: true, achievements: true, etc }
lastActiveTime
optimalSendTimes: []
/users/{userId}/notifications

type, message, data
read, timestamp
Code

7. **UI Features:**

- Notification center with history
- Mark as read
- Customize preferences
- Unsubscribe from types
- Quiet hours setup
- Preview notifications

**Personalization:**

- Analyze user behavior
- Send relevant notifications
- A/B test message content
- Time-optimized delivery
- Dynamic content (personalized text)

**Analytics:**

- Delivery rate
- Open rate
- Click-through rate
- Engagement metrics
- Opt-out tracking

Please provide:

1. Notification system architecture
2. Cloud Functions for triggers
3. Smart scheduling algorithm
4. Engagement tracking
5. FCM implementation
6. Preferences UI
7. Notification center screen
8. A/B testing setup
9. Analytics tracking
   📝 How to Use These Prompts:

Copy the prompt for the feature you want
Customize with your specific requirements
Paste into Claude (or other AI)
Ask follow-up questions for clarification
Implement the code provided
Test thoroughly before deployment
🎯 Recommended Implementation Order:

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

