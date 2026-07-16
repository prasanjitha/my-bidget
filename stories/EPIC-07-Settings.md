# Epic 7: Settings & Customization

**Epic ID**: EPIC-07  
**Epic Name**: Settings & Customization  
**Epic Owner**: Development Team  
**Business Value**: Personalize app experience and configure preferences  
**Target Release**: v1.0

---

## Story SET-001: Settings Page Layout

**Story ID**: SET-001  
**Story Title**: Settings Page Navigation and Structure  
**Priority**: Must Have (P0)  
**Story Points**: 2

### User Story
**As a** user  
**I want to** access app settings  
**So that** I can customize my experience

### Acceptance Criteria

**Given** the user taps the Settings tab in bottom navigation  
**When** the page loads  
**Then** the Settings page should display with:
- Header: "Settings" (center)
- List of setting cards in order:
  1. Dark Mode
  2. Set Currency
  3. Set Monthly Allocation
  4. Change Profile Name
  5. Budget Cycle Start
  6. Export Monthly Report
  7. Logout

**Given** the settings page is displayed  
**When** all cards render  
**Then** each card should have:
- Icon on the left
- Setting label
- Current value or subtitle (where applicable)
- Action button or toggle (right side)

**Given** the page is scrollable  
**When** there are many settings  
**Then** the page should scroll smoothly  
**And** maintain bottom navigation visibility

### Technical Notes
- Use ListView or Column with SingleChildScrollView
- Card widget for each setting
- Icons: Material Icons
- Consistent spacing: 16dp padding, 8dp margin
- Divider between cards (optional)

### Dependencies
- HOME-001 (Navigation structure)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Settings page displays correctly
- [ ] All setting cards visible
- [ ] Navigation works
- [ ] Scrolling smooth
- [ ] UI matches design
- [ ] Widget tests passed

---

## Story SET-002: Dark Mode Toggle

**Story ID**: SET-002  
**Story Title**: Enable/Disable Dark Theme  
**Priority**: Should Have (P1)  
**Story Points**: 5

### User Story
**As a** user  
**I want to** enable dark mode  
**So that** I can use the app comfortably in low-light conditions

### Acceptance Criteria

**Given** the user is on the Settings page  
**When** the Dark Mode card is displayed  
**Then** it should show:
- Moon icon
- Label: "Dark Mode"
- Switch toggle (right side)
- Current state (on/off)

**Given** the user toggles dark mode on  
**When** the switch is flipped  
**Then** the entire app should switch to dark theme  
**And** the setting should be saved to SharedPreferences  
**And** apply immediately without restart

**Given** the user toggles dark mode off  
**When** the switch is flipped  
**Then** the entire app should switch to light theme  
**And** the setting should be saved to SharedPreferences

**Given** the app is restarted  
**When** the app launches  
**Then** the theme should match the saved preference  
**And** apply before the first screen renders

**Given** dark mode is enabled  
**When** any page is viewed  
**Then** all pages should use dark theme colors:
- Background: #121212 (dark gray)
- Cards: #1E1E1E (darker gray)
- Text: #FFFFFF (white)
- Primary: Adjusted for dark mode

### Technical Notes
- Store in SharedPreferences: `darkMode` (bool)
- Use ThemeMode.light or ThemeMode.dark
- Define light and dark ThemeData in main.dart
- Use ThemeProvider or similar state management
- Apply theme to MaterialApp
- Ensure all custom widgets support both themes
- Test all pages in both themes

### Dependencies
- SET-001 (Settings page structure)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Toggle switch works
- [ ] Theme switches immediately
- [ ] All pages support dark theme
- [ ] Setting persists across sessions
- [ ] Colors defined for both themes
- [ ] Text readable in both themes
- [ ] Unit tests written
- [ ] Visual tests for both themes

---

## Story SET-003: Currency Selection

**Story ID**: SET-003  
**Story Title**: Set Preferred Currency  
**Priority**: Must Have (P0)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** select my preferred currency  
**So that** all amounts display in my local currency

### Acceptance Criteria

**Given** the user is on the Settings page  
**When** the Set Currency card is displayed  
**Then** it should show:
- Currency icon
- Label: "Set Currency"
- Subtitle: Current currency (e.g., "LKR (RS)")
- SET button

**Given** the user taps the SET button  
**When** the button is pressed  
**Then** a popup modal should open with:
- Header: "Select Currency"
- Currency dropdown with options:
  - LKR (RS) - Sri Lankan Rupee
  - USD ($) - US Dollar
  - EUR (€) - Euro
  - GBP (£) - British Pound
  - INR (₹) - Indian Rupee
- Save button
- Cancel button

**Given** the user selects a currency and saves  
**When** the Save button is pressed  
**Then** the currency should be saved to SharedPreferences  
**And** the popup should close  
**And** all amounts throughout the app should update to show the new currency symbol  
**And** the Settings card subtitle should update

**Given** the app is restarted  
**When** the app launches  
**Then** all amounts should display with the saved currency

**Given** no currency has been set  
**When** the app first launches  
**Then** default currency should be LKR (RS)

### Technical Notes
- Store in SharedPreferences: `currency` (string: "LKR", "USD", etc.)
- Create currency utility class:
  - getCurrencySymbol(code): Returns symbol (RS, $, €, £, ₹)
  - formatAmount(amount, code): Returns formatted string
- Update all amount displays app-wide
- Use Provider/Riverpod for currency state management
- Number formatting: Thousand separators, 2 decimal places

### Dependencies
- SET-001 (Settings page structure)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Currency card displays current selection
- [ ] SET button opens popup
- [ ] Dropdown shows all currencies
- [ ] Save updates SharedPreferences
- [ ] All amounts update app-wide
- [ ] Default currency is LKR
- [ ] Setting persists across sessions
- [ ] Number formatting correct
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story SET-004: Set Monthly Allocation

**Story ID**: SET-004  
**Story Title**: Configure Monthly Budget via Settings  
**Priority**: Should Have (P1)  
**Story Points**: 2

### User Story
**As a** user  
**I want to** set my monthly budget allocation from settings  
**So that** I have another way to configure my budget

### Acceptance Criteria

**Given** the user is on the Settings page  
**When** the Set Monthly Allocation card is displayed  
**Then** it should show:
- Wallet icon
- Label: "Set Monthly Allocation"
- SET button

**Given** the user taps the SET button  
**When** the button is pressed  
**Then** a popup modal should open with:
- Header: "Set Monthly Allocation"
- Amount input field with current currency symbol
- Save button
- Cancel button

**Given** the user enters a valid amount and saves  
**When** the Save button is pressed  
**Then** the budget should be updated in Firebase `users` collection  
**And** the popup should close  
**And** Home page should update automatically  
**And** Summary page should reflect new budget

**Given** the amount is invalid  
**When** Save is attempted  
**Then** validation error should display  
**And** save should be prevented

### Technical Notes
- Same logic as HOME-003
- Update Firestore: `users/{userId}/monthlyAllocation`
- Validation: Min: 0, Max: 999,999,999
- Real-time sync: Use StreamBuilder on Home page
- Currency symbol from SharedPreferences

### Dependencies
- SET-003 (Currency for display)
- HOME-003 (Same functionality, different access point)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] SET button opens popup
- [ ] Amount input validation works
- [ ] Save updates Firebase
- [ ] Home page updates automatically
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story SET-005: Change Profile Name

**Story ID**: SET-005  
**Story Title**: Update User Display Name  
**Priority**: Should Have (P1)  
**Story Points**: 2

### User Story
**As a** user  
**I want to** set or change my name  
**So that** the app greets me personally

### Acceptance Criteria

**Given** the user is on the Settings page  
**When** the Change Profile Name card is displayed  
**Then** it should show:
- User icon
- Label: "Change Profile Name"
- Subtitle: Current name (or "Not Set")
- SET button

**Given** the user taps the SET button  
**When** the button is pressed  
**Then** a popup modal should open with:
- Header: "Change Profile Name"
- Name input field (pre-filled with current name)
- Save button
- Cancel button

**Given** the user enters a valid name and saves  
**When** the Save button is pressed  
**Then** the name should be updated in Firebase `users` collection  
**And** the popup should close  
**And** Settings card subtitle should update  
**And** Home page greeting should update to "Hello [Name]"

**Given** the name is empty  
**When** Save is attempted  
**Then** validation error should display: "Name cannot be empty"

**Given** the name exceeds 50 characters  
**When** Save is attempted  
**Then** validation error should display: "Name too long (max 50 characters)"

### Technical Notes
- Update Firestore: `users/{userId}/name`
- Validation: Min: 1 character, Max: 50 characters
- Trim whitespace before saving
- Real-time sync: StreamBuilder on Home page
- Default name: "User"

### Dependencies
- SET-001 (Settings page structure)
- HOME-002 (Greeting display)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Card displays current name
- [ ] SET button opens popup with pre-filled name
- [ ] Validation works
- [ ] Save updates Firebase
- [ ] Settings subtitle updates
- [ ] Home greeting updates
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story SET-006: Budget Cycle Configuration

**Story ID**: SET-006  
**Story Title**: Set Budget Cycle Start Day  
**Priority**: Must Have (P0)  
**Story Points**: 5

### User Story
**As a** user  
**I want to** set when my budget cycle starts  
**So that** the app tracks my budget according to my pay schedule

### Acceptance Criteria

**Given** the user is on the Settings page  
**When** the Budget Cycle Start card is displayed  
**Then** it should show:
- Calendar icon
- Label: "Budget Cycle Start"
- Subtitle: Current cycle (e.g., "June 10, 2026 - July 9, 2026")
- SET button

**Given** the user taps the SET button  
**When** the button is pressed  
**Then** a popup modal should open with:
- Header: "Budget Cycle Start"
- Close icon (top right)
- Label: "Select the starting day of your budget cycle"
- Horizontal scrollable number picker (1-31)
- Each number in a rounded card
- Live preview: "Budget Tracking Period"
- Preview displays: "This Month's Cycle: [Start Date] - [End Date]"
- Cancel button
- Save/Update button

**Given** the user selects a day (e.g., 10)  
**When** the number is selected  
**Then** the live preview should update immediately  
**And** show: "June 10, 2026 - July 9, 2026"

**Given** the user saves the selection  
**When** the Save button is pressed  
**Then** the start day should be updated in Firebase `users` collection  
**And** the popup should close  
**And** the entire app should recalculate budget cycle  
**And** all expenses should be re-categorized by new cycle  
**And** Home page, Expenses page, Summary page should all update

**Given** the selected day > days in a month (e.g., 31 in February)  
**When** the cycle is calculated  
**Then** use the last day of that month

### Technical Notes
- Update Firestore: `users/{userId}/budgetCycleStartDay`
- Recalculate cycle: CYC-002 logic
- Update all expense budgetCycle fields (background job)
- Horizontal scroll: ListView.builder with horizontal axis
- Number cards: Container with border, rounded corners
- Selected state: Highlight with primary color
- Preview: Real-time calculation using DateFormat

### Dependencies
- SET-001 (Settings page structure)
- CYC-001 (Budget cycle calculation logic)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Card displays current cycle
- [ ] SET button opens picker popup
- [ ] Number picker scrollable and selectable
- [ ] Live preview updates correctly
- [ ] Save updates Firebase
- [ ] Budget cycle recalculates app-wide
- [ ] Expenses re-categorized by new cycle
- [ ] Edge case (day > month days) handled
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story SET-007: Logout

**Story ID**: SET-007  
**Story Title**: User Logout  
**Priority**: Must Have (P0)  
**Story Points**: 2

### User Story
**As a** user  
**I want to** log out of the app  
**So that** I can secure my data when not using the app

### Acceptance Criteria

**Given** the user is on the Settings page  
**When** the page scrolls to the bottom  
**Then** a Logout button should be visible with:
- Logout icon
- Label: "Logout"
- Full-width button
- Red/warning color

**Given** the user taps the Logout button  
**When** the button is pressed  
**Then** a confirmation dialog should appear:
- Message: "Are you sure you want to logout?"
- Cancel button
- Logout button (red)

**Given** the user confirms logout  
**When** the Logout button in dialog is pressed  
**Then** the following should occur:
- Clear local session data
- Sign out from Firebase Authentication
- Navigate to biometric login screen
- Clear navigation stack (no back button)

**Given** the user cancels logout  
**When** the Cancel button is pressed  
**Then** the dialog should close  
**And** the user should remain on Settings page

**Given** the user logs back in  
**When** biometric authentication succeeds  
**Then** the app should load the user's data  
**And** navigate to Home page

### Technical Notes
- Firebase signOut(): `FirebaseAuth.instance.signOut()`
- Clear SharedPreferences: Keep only app settings (theme, currency)
- Clear sensitive data from memory
- Navigation: `Navigator.pushAndRemoveUntil()` to clear stack
- Biometric re-authentication required on re-entry

### Dependencies
- SET-001 (Settings page structure)
- AUTH-002 (Biometric login to return to)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Logout button displays correctly
- [ ] Confirmation dialog appears
- [ ] Logout clears session
- [ ] Firebase signOut successful
- [ ] Navigation to login screen works
- [ ] Navigation stack cleared
- [ ] Re-login requires biometric
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story SET-008: Settings Persistence

**Story ID**: SET-008  
**Story Title**: Save and Load User Preferences  
**Priority**: Must Have (P0)  
**Story Points**: 2

### User Story
**As a** user  
**I want** my settings to be remembered  
**So that** I don't have to reconfigure the app every time

### Acceptance Criteria

**Given** the user changes any setting  
**When** the setting is saved  
**Then** it should persist in appropriate storage:
- Dark Mode: SharedPreferences
- Currency: SharedPreferences
- Monthly Allocation: Firebase
- Profile Name: Firebase
- Budget Cycle Start: Firebase

**Given** the app is restarted  
**When** the app launches  
**Then** all settings should load from storage  
**And** apply before the UI renders

**Given** the user logs out and logs back in  
**When** authentication succeeds  
**Then** user-specific settings should load from Firebase  
**And** app-wide settings should load from SharedPreferences

**Given** the user switches devices  
**When** logging in on a new device  
**Then** Firebase-backed settings should sync  
**And** device-specific settings (theme) should use defaults

### Technical Notes
- SharedPreferences: darkMode, currency
- Firestore: monthlyAllocation, name, budgetCycleStartDay
- Load order:
  1. Load SharedPreferences (synchronous)
  2. Apply theme before MaterialApp
  3. Load Firebase settings after authentication
- Create SettingsService class to manage settings
- Use FutureBuilder or async init

### Dependencies
- SET-002 to SET-007 (All settings features)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Settings persist correctly
- [ ] Load on app launch works
- [ ] Settings survive logout/login
- [ ] Cross-device sync works for Firebase settings
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Epic 7 Summary

**Total Stories**: 8  
**Total Story Points**: 23  
**Estimated Duration**: 4-5 days  
**Must Have Stories**: 4  
**Should Have Stories**: 4  
**Could Have Stories**: 0

### Epic Acceptance Criteria
- [ ] All settings stories completed
- [ ] Settings page fully functional
- [ ] All settings persist correctly
- [ ] Dark mode works app-wide
- [ ] Currency changes apply everywhere
- [ ] Budget cycle configuration works
- [ ] Logout functionality secure
- [ ] All tests passing
