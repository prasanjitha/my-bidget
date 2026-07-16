# Device Pairing Testing Guide

## Prerequisites
- 2 Android devices (or 1 physical + 1 emulator)
- Both devices must have fingerprint/biometric capability
- Both devices need internet connection

## Test Scenario 1: Fresh Pairing

### Primary Device (Device A)
1. ✅ Install app on Device A
2. ✅ Open app - should show fingerprint enrollment screen
3. ✅ Tap "Enroll" and complete fingerprint authentication
4. ✅ App should open to main screen
5. ✅ Add some test data:
   - Set monthly allocation: RS 100,000
   - Add a category: "Food"
   - Add an expense: RS 5,000 in "Food"
6. ✅ Go to Settings
7. ✅ Tap "Pair New Device"
8. ✅ QR code should be displayed
9. ✅ Keep this screen open

### Secondary Device (Device B)
1. ✅ Install app on Device B
2. ✅ Open app - should show fingerprint enrollment screen
3. ✅ Tap "Pair with existing device" button (at bottom)
4. ✅ Camera permission dialog should appear - grant it
5. ✅ QR scanner screen should open
6. ✅ Point camera at Device A's QR code
7. ✅ Should see "Device paired successfully!" message
8. ✅ Should return to enrollment screen
9. ✅ Complete fingerprint authentication on Device B
10. ✅ App should open to main screen
11. ✅ **VERIFY**: Should see same data as Device A:
    - Monthly allocation: RS 100,000
    - Category: "Food"
    - Expense: RS 5,000

## Test Scenario 2: Data Sync

### On Device A
1. ✅ Add new expense: RS 3,000 in "Food"
2. ✅ Wait 2-3 seconds

### On Device B
1. ✅ **VERIFY**: New expense (RS 3,000) should appear automatically
2. ✅ **VERIFY**: Total spent should update to RS 8,000

### On Device B
1. ✅ Create new category: "Transport"
2. ✅ Add expense: RS 2,000 in "Transport"

### On Device A
1. ✅ **VERIFY**: "Transport" category should appear
2. ✅ **VERIFY**: RS 2,000 expense should appear

## Test Scenario 3: Settings Sync

### On Device A
1. ✅ Change currency to USD
2. ✅ Change monthly allocation to 200,000
3. ✅ Change budget cycle start day to 15

### On Device B
1. ✅ **VERIFY**: Currency changed to USD
2. ✅ **VERIFY**: Monthly allocation shows 200,000
3. ✅ **VERIFY**: Budget cycle start day is 15

## Test Scenario 4: Logout & Re-pair

### On Device B
1. ✅ Go to Settings
2. ✅ Tap "Logout"
3. ✅ Confirm logout
4. ✅ Should return to enrollment screen
5. ✅ Tap "Pair with existing device" again
6. ✅ Scan Device A's QR code again
7. ✅ Complete fingerprint
8. ✅ **VERIFY**: All data should be back

## Test Scenario 5: Multiple Devices

### Add Device C
1. ✅ On Device A or B, go to Settings → "Pair New Device"
2. ✅ On Device C, install app and tap "Pair with existing device"
3. ✅ Scan QR code
4. ✅ **VERIFY**: Device C shows same data
5. ✅ Add expense on Device C
6. ✅ **VERIFY**: Expense appears on Device A and B

## Expected Behavior

### ✅ Correct Behavior
- All devices show identical data
- Changes sync within 2-3 seconds
- Each device has independent fingerprint authentication
- QR code remains valid indefinitely
- Can pair unlimited devices

### ❌ Incorrect Behavior (Report if occurs)
- Data doesn't sync after 10 seconds
- Different devices show different totals
- QR scan fails repeatedly
- Camera permission denied even after granting
- App crashes during pairing

## Common Issues

### Issue: QR Code Not Scanning
**Solution:**
- Ensure good lighting
- Hold phone steady
- Try moving camera closer/farther
- Check camera permission is granted

### Issue: "Invalid pairing code" Error
**Solution:**
- Ensure QR code is from same app
- QR code should contain only numbers
- Try generating QR code again

### Issue: Data Not Syncing
**Solution:**
- Check internet connection on both devices
- Wait 10 seconds
- Force close and reopen app
- Check Firebase console for connection issues

### Issue: Camera Permission Denied
**Solution:**
- Go to Android Settings → Apps → Bidget → Permissions
- Enable Camera permission
- Restart app

## Firestore Console Verification

To verify data in Firebase:
1. Open Firebase Console
2. Go to Firestore Database
3. Navigate to `users/{userId}`
4. Check:
   - Document fields (monthlyAllocation, currency, budgetCycleStartDay)
   - Subcollection: `categories` (should have your categories)
   - Collection: `expenses` (filter by userId, should have all expenses)
   - Collection: `savings` (filter by userId, should have savings)

## Performance Metrics

- QR scan time: < 2 seconds
- Pairing process: < 5 seconds
- Data sync delay: 2-3 seconds (real-time)
- App size increase: ~2MB (for QR packages)
