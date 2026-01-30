# 🔧 SafaiPay Configuration Guide

This document provides detailed setup instructions for all third-party integrations.

---

## 1️⃣ Firebase Setup

### Step 1: Create Firebase Project
1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `SafaiPay`
4. Enable Google Analytics (optional)
5. Create project

### Step 2: Enable Authentication
1. Go to **Build** → **Authentication**
2. Click **Get Started**
3. Enable **Phone** provider
4. Add test phone numbers (for development):
   - +91 9999999999 → OTP: 123456

### Step 3: Create Firestore Database
1. Go to **Build** → **Firestore Database**
2. Click **Create Database**
3. Start in **Production Mode**
4. Select region (asia-south1 for India)

### Step 4: Set Up Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Bookings collection
    match /bookings/{bookingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
    
    // Reports collection
    match /reports/{reportId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
    
    // Transactions collection
    match /transactions/{transactionId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // Collectors collection
    match /collectors/{collectorId} {
      allow read: if request.auth != null;
    }
  }
}
```

### Step 5: Enable Storage
1. Go to **Build** → **Storage**
2. Click **Get Started**
3. Use default security rules
4. Create folders:
   - `reports/`
   - `pickups/`

### Step 6: Add Firebase to Flutter

#### Android
1. Download `google-services.json`
2. Place in `android/app/`
3. Update `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
   }
   ```
4. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### iOS
1. Download `GoogleService-Info.plist`
2. Place in `ios/Runner/`
3. Open Xcode and add file to Runner target

#### FlutterFire CLI (Recommended)
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

---

## 2️⃣ Google Maps Setup

### Step 1: Enable APIs
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create new)
3. Go to **APIs & Services** → **Library**
4. Enable:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Geocoding API

### Step 2: Create API Key
1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **API Key**
3. Copy the API key
4. Click **Restrict Key**:
   - Application restrictions: Android apps / iOS apps
   - API restrictions: Select enabled APIs

### Step 3: Add to Android
`android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSy...YOUR_KEY_HERE"/>
```

### Step 4: Add to iOS
`ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSy...YOUR_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## 3️⃣ Razorpay Setup (Payment Gateway)

### Step 1: Create Account
1. Visit [Razorpay](https://razorpay.com/)
2. Sign up (for business)
3. Complete KYC verification

### Step 2: Get API Keys
1. Go to **Settings** → **API Keys**
2. Generate Keys:
   - Test Mode Key (for development)
   - Live Mode Key (for production)

### Step 3: Configure in App
`lib/services/payment_service.dart`:
```dart
var options = {
  'key': 'rzp_test_YOUR_KEY_HERE', // Test key
  // 'key': 'rzp_live_YOUR_KEY_HERE', // Live key (production)
  'amount': amount * 100,
  'name': 'SafaiPay',
  ...
};
```

### Step 4: Enable Payment Methods
In Razorpay Dashboard:
- Enable UPI
- Enable Net Banking
- Enable Cards
- Enable Wallets

---

## 4️⃣ Environment Variables

Create `.env` file in project root:

```env
# Firebase
FIREBASE_PROJECT_ID=safaipay-xxxxx
FIREBASE_API_KEY=AIzaSy...

# Google Maps
GOOGLE_MAPS_API_KEY=AIzaSy...

# Razorpay
RAZORPAY_TEST_KEY=rzp_test_...
RAZORPAY_LIVE_KEY=rzp_live_...

# App Config
APP_NAME=SafaiPay
APP_VERSION=1.0.0
```

**⚠️ Important:** Add `.env` to `.gitignore`

---

## 5️⃣ Android App Signing (for Production)

### Step 1: Generate Keystore
```bash
keytool -genkey -v -keystore ~/safaipay-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias safaipay
```

### Step 2: Create key.properties
`android/key.properties`:
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=safaipay
storeFile=/path/to/safaipay-keystore.jks
```

### Step 3: Configure build.gradle
`android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 6️⃣ Testing Credentials

### Test Phone Numbers (Firebase)
```
+91 9999999999 → OTP: 123456
+91 8888888888 → OTP: 123456
```

### Test Card (Razorpay)
```
Card Number: 4111 1111 1111 1111
CVV: 123
Expiry: Any future date
```

### Test UPI (Razorpay)
```
UPI ID: success@razorpay
```

---

## 7️⃣ Deployment Checklist

### Before Production:
- [ ] Switch Firebase to production rules
- [ ] Use live Razorpay keys
- [ ] Restrict Google Maps API key
- [ ] Enable Proguard/R8
- [ ] Test on real devices
- [ ] Set up Firebase Analytics
- [ ] Configure FCM for notifications
- [ ] Add crash reporting (Firebase Crashlytics)
- [ ] Performance monitoring

### Play Store Requirements:
- [ ] Privacy Policy URL
- [ ] Terms & Conditions
- [ ] App Icon (512x512)
- [ ] Feature Graphics
- [ ] Screenshots (Phone + Tablet)
- [ ] App Description
- [ ] Target API level 33+

---

## 8️⃣ Troubleshooting

### Issue: Firebase Auth not working
**Solution:** Check SHA-1 certificate fingerprint in Firebase Console

```bash
# Get debug SHA-1
cd android
./gradlew signingReport
```

### Issue: Google Maps not showing
**Solution:** Verify API key restrictions and enable billing

### Issue: Razorpay payment fails
**Solution:** Ensure test mode is enabled and using test credentials

### Issue: Location permission denied
**Solution:** Check AndroidManifest.xml and iOS Info.plist for location permissions

---

## 📞 Support

For setup issues:
- Firebase: [Firebase Support](https://firebase.google.com/support)
- Google Maps: [Maps Platform Support](https://developers.google.com/maps/support)
- Razorpay: [Razorpay Support](https://razorpay.com/support/)

---

**Happy Building! 🚀**
