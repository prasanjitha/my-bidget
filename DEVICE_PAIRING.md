# Device Pairing Feature

## Overview
This feature allows you to sync your budget data across multiple devices without using Google Sign-In. It uses QR code-based device pairing.

## How It Works

### Architecture
- Each user has a unique `userId` (timestamp-based)
- All Firestore data is filtered by this `userId`
- When you pair a device, both devices share the same `userId`
- Data automatically syncs through Firebase Firestore

### First Time Setup (Primary Device)
1. Open the app
2. Set up fingerprint authentication
3. Start using the app

### Pairing a Second Device
1. On **primary device**:
   - Go to Settings
   - Tap "Pair New Device"
   - A QR code will be displayed

2. On **new device**:
   - Install and open the app
   - On the welcome screen, tap "Pair with existing device"
   - Scan the QR code from primary device
   - Set up fingerprint authentication
   - Done! Both devices now share the same data

## Security
- Each device requires its own fingerprint authentication
- QR code contains only the userId (not sensitive data)
- Keep the QR code private - anyone with it can access your data
- You can logout from any device anytime

## Data Sync
- All changes are automatically synced in real-time
- Both devices see the same:
  - Budget allocation
  - Categories
  - Expenses
  - Savings
  - Settings (currency, budget cycle)

## Technical Details

### Files Added
- `lib/services/device_pairing_service.dart` - Core pairing logic
- `lib/features/auth/presentation/screens/qr_pair_device_screen.dart` - QR display
- `lib/features/auth/presentation/screens/qr_scan_screen.dart` - QR scanner

### Packages Added
- `qr_flutter: ^4.1.0` - Generate QR codes
- `mobile_scanner: ^5.2.3` - Scan QR codes

### Permissions
- Camera permission added for QR scanning

### Storage Keys
- `is_paired_device` - Marks if device was paired (vs original enrollment)

## Limitations
- No cloud backup of userId - if you lose all devices, you lose access to data
- No remote device management - can't revoke access from other devices
- QR code must be scanned carefully (no cloud sync of pairing codes)

## Future Enhancements (Optional)
- Add Firebase Authentication for cloud-based account management
- Remote device revocation
- Account recovery system
- PIN-based pairing as alternative to QR
