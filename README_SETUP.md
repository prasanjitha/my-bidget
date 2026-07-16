# Bidget - Setup Instructions

## Firebase Configuration

Before running the app, you **MUST** configure Firebase:

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it "Bidget" (or your preferred name)
4. Follow the setup wizard

### Step 2: Add Android App
1. In Firebase Console, click "Add app" > Android
2. Android package name: `com.bidget.bidget`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

### Step 3: Update Firebase Constants
1. Open `lib/core/constants/firebase_constants.dart`
2. Replace placeholder values with your Firebase config from Firebase Console

### Step 4: Enable Firebase Authentication
1. In Firebase Console > Authentication
2. Click "Get Started"
3. Enable "Anonymous" sign-in method

### Step 5: Enable Firestore Database
1. In Firebase Console > Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" (we'll add security rules later)
4. Select a location

### Step 6: Update Android Gradle Files
Ensure these files are updated (already done in template):
- `android/build.gradle.kts` - Add Google services classpath
- `android/app/build.gradle.kts` - Apply Google services plugin

## Android Biometric Setup

The app requires biometric authentication. Ensure:
1. Your device has fingerprint or face recognition enrolled
2. Test on physical device (emulator may have limited biometric support)

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on Android device
flutter run
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/auth_test.dart
```

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App and Firebase constants
│   ├── theme/              # App theming
│   └── utils/              # Utility functions
├── features/
│   ├── auth/               # Authentication feature
│   │   ├── data/           # Data layer
│   │   ├── domain/         # Domain/business logic
│   │   └── presentation/   # UI layer
│   │       ├── providers/  # State management
│   │       ├── screens/    # Screen widgets
│   │       └── widgets/    # Reusable widgets
│   └── home/               # Other features...
└── services/               # Global services
```

## Current Implementation Status

✅ Project structure created
✅ Dependencies installed
🔄 Implementing Authentication (AUTH-001, AUTH-002, AUTH-003)
⏳ Home page (pending)
⏳ Expense management (pending)

See `stories/` folder for complete user stories and implementation plan.
