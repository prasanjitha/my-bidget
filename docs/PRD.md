# Product Requirements Document (PRD)
## Bidget - Personal Budget Tracking App

**Version:** 1.0  
**Date:** July 15, 2026  
**Platform:** Android  
**Tech Stack:** Flutter, Firebase (Cloud Firestore, Authentication)

---

## 1. Executive Summary

Bidget is a personal budget tracking mobile application that helps users manage their monthly expenses, allocate budgets across categories, and track spending patterns. The app provides biometric authentication, flexible budget cycles, category-based expense tracking, and comprehensive spending summaries with PDF export capabilities.

---

## 2. Product Overview

### 2.1 Purpose
To provide users with an intuitive, secure mobile application for tracking daily expenses, managing monthly budgets, monitoring category-wise spending, and maintaining savings records.

### 2.2 Target Audience
- Individuals seeking to manage personal finances
- Users who want category-based budget allocation
- People looking for simple expense tracking with biometric security

### 2.3 Key Features
- Biometric authentication (fingerprint/face recognition)
- Customizable budget cycles (1-31 day start dates)
- Category-based budget allocation with progress tracking
- Daily and monthly expense tracking
- Visual spending summaries with graphs
- Multi-currency support
- PDF report generation
- Savings tracking
- Dark mode support

---

## 3. Technical Requirements

### 3.1 Platform
- **Target Platform:** Android
- **Minimum SDK:** Android 8.0 (API Level 26)
- **Target SDK:** Latest stable Android version

### 3.2 Technology Stack
- **Framework:** Flutter (latest stable version)
- **Backend:** Firebase
  - Cloud Firestore (database)
  - Firebase Authentication (biometric authentication)
- **Local Storage:** SharedPreferences (for app settings)
- **Biometric Authentication:** local_auth Flutter package
- **PDF Generation:** Flutter PDF generation library

### 3.3 Dependencies
- `firebase_core`
- `cloud_firestore`
- `firebase_auth`
- `local_auth` (biometric authentication)
- `shared_preferences` (local settings)
- `fl_chart` or similar (for graphs)
- `pdf` package (for PDF generation)
- `intl` (date/number formatting)

---

## 4. Functional Requirements

## 4.1 Authentication & Security

### 4.1.1 Biometric Login
**User Story:** As a user, I want to log in using biometric authentication so that my financial data remains secure.

**Requirements:**
- On app launch, prompt biometric authentication (fingerprint/face recognition)
- No email/password signup required
- Use Firebase Authentication with anonymous authentication + device biometric verification
- On successful biometric verification, navigate directly to Home page
- On biometric failure, show error message and retry option
- First-time users: Enroll biometric during first launch
- App close and reopen requires biometric re-authentication

**Acceptance Criteria:**
- [ ] Biometric prompt appears on app launch
- [ ] Successful authentication navigates to Home page
- [ ] Failed authentication shows error and allows retry
- [ ] Biometric required every time app is reopened
- [ ] Works with fingerprint and face recognition

---

## 4.2 Home Page

### 4.2.1 Home Page Layout
**User Story:** As a user, I want to see my budget overview on the home page so I can quickly understand my financial status.

**Components (Top to Bottom):**

1. **Greeting Message**
   - Display: "Hello User" (or user's custom name from settings)

2. **Monthly Allocation Budget Card**
   - Display: "MONTHLY Allocation Budget"
   - Show: Current month name (e.g., "June 2026")
   - Show: Amount (e.g., "RS 170,000")
   - Button: "SET" button
   - On click: Open popup modal to set monthly budget
   - Popup fields:
     - Currency dropdown (LKR, USD, EUR, GBP, INR)
     - Budget amount input field
     - Save button
     - Cancel button

3. **Category Budget Allocation Expanded Card**
   - Header: "Budget Categories" with expand/collapse icon
   - Default collapsed state
   - On expand, show list of categories:

   **Each Category Item:**
   - Category name (e.g., "Food", "Rent")
   - Progress bar (visual representation: spent/allocated)
   - Allocated budget amount
   - Remaining amount
   - "SET" button
   - On SET click: Open popup to set category budget
     - Popup fields:
       - Category name (read-only)
       - Budget amount input
       - Save button
       - Cancel button

   **Add New Category Button:**
   - Located at bottom of expanded list
   - On click: Open popup to add new category
     - Popup fields:
       - Category name input
       - Save button
       - Cancel button
   - On save: Add category to Firebase and display in list

4. **Total Spend Card**
   - Display: "Total Spend"
   - Show: Current month name
   - Show: Total amount spent (e.g., "RS 20,000")
   - Updates automatically when expenses are added/edited/deleted

5. **Remaining Balance Card**
   - Display: "Remaining Balance"
   - Show: Amount (Allocated Budget - Total Spend)
   - Example: "RS 150,000"
   - Updates automatically

6. **Monthly Overview Card**
   - Header: "Monthly Overview - [Current Month Name]"
   - Bar graph showing:
     - Budget (allocated)
     - Spent (total expenses)
     - Remaining (balance)
   - Interactive: Touch/tap on bar shows exact amount
   - Visual: Different colors for each bar

7. **Bottom Navigation Bar**
   - Tab 1: Home (icon + label)
   - Tab 2: Expenses (icon + label)
   - Tab 3: Add Expense (center floating action button with + icon)
   - Tab 4: Summary (icon + label)
   - Tab 5: Settings (icon + label)

**Acceptance Criteria:**
- [ ] All components display correctly in order
- [ ] Monthly budget can be set via popup
- [ ] Category budgets can be set individually
- [ ] New categories can be added
- [ ] Total spend updates automatically
- [ ] Remaining balance calculates correctly
- [ ] Graph displays all three values
- [ ] Tapping graph bars shows amounts
- [ ] Bottom navigation works correctly
- [ ] All data syncs with Firebase

---

## 4.3 Expenses Page (Recent Expenses)

### 4.3.1 Recent Expenses Page Layout
**User Story:** As a user, I want to view and manage my recent expenses so I can track my spending.

**Components:**

1. **Header**
   - Title: "Recent Expenses" (center)
   - Search icon (top right)
   - On click: Open search popup/overlay
     - Search input field
     - Search by expense title/amount
     - Display filtered results

2. **Category Filter**
   - Icon on right side of header
   - On click: Show category dropdown from Firebase
   - Display all categories
   - Select category to filter expenses
   - Options to add/edit/delete categories:
     - **Add:** "+" button in dropdown
     - **Edit:** Long press on category
     - **Delete:** Swipe or delete icon
     - **Delete Rule:** Cannot delete category if it has expenses associated with current budget cycle

3. **Expenses List**
   - Group expenses by date
   - Date header (e.g., "June 25, Thursday")
   - Below date: Expense cards for that day

   **Expense Card:**
   - Title (if provided)
   - Category name with icon
   - Amount
   - Edit icon
   - Delete icon
   - On edit: Open edit popup (pre-filled with existing data)
   - On delete: Show confirmation dialog, then delete from Firebase

4. **View All Button**
   - Floating action button (bottom right)
   - Label: "View All"
   - On click: Navigate to "All Expenses" page

**All Expenses Page:**
- Back button (top left)
- Budget cycle selector (dropdown)
  - Lists all past and current budget cycles
  - Format: "June 10, 2026 - July 9, 2026"
  - Selected cycle displays its expenses
- Expense cards grouped by date
- Each card expandable to show full details
- Delete button on each expense
- Shows expenses only for selected budget cycle

**Acceptance Criteria:**
- [ ] Recent expenses display grouped by date
- [ ] Search functionality filters expenses
- [ ] Category filter works correctly
- [ ] Cannot delete category with expenses in current cycle
- [ ] Edit expense updates Firebase and UI
- [ ] Delete expense removes from Firebase and UI
- [ ] View All page shows budget cycle selector
- [ ] Expenses filtered by selected budget cycle
- [ ] All changes reflect in real-time

---

### 4.3.2 Add Expense (Floating Action Button)
**User Story:** As a user, I want to add expenses quickly so I can track my spending in real-time.

**Trigger:** Tap center "+" button in bottom navigation

**Bottom Sheet Components:**
1. **Title Input (Optional)**
   - Text input field
   - Placeholder: "Enter title (optional)"

2. **Category Dropdown**
   - Display all categories from Firebase
   - "+" button next to dropdown
   - On "+" click: Open popup to add new category
     - Category name input
     - Save button
     - Cancel button
   - On save: Add to Firebase and refresh dropdown

3. **Date Picker**
   - Calendar picker
   - Default: Today's date
   - Allow past and future dates

4. **Amount Input**
   - Numeric input
   - Currency symbol prefix (based on selected currency)
   - Required field

5. **Buttons**
   - ADD button (primary)
   - Cancel button (secondary)

**On ADD:**
- Validate required fields (Category, Date, Amount)
- Save to Firebase with:
  - Title (optional)
  - Category ID
  - Date
  - Amount
  - Timestamp
  - Budget cycle ID (based on current cycle)
- Close bottom sheet
- Navigate to Recent Expenses page
- Update Home page values (Total Spend, Remaining Balance, Category Progress)

**Acceptance Criteria:**
- [ ] Bottom sheet opens from center FAB
- [ ] All fields display correctly
- [ ] Category dropdown shows Firebase categories
- [ ] New category can be added via "+" button
- [ ] Date picker allows date selection
- [ ] Amount input accepts numeric values
- [ ] Validation works for required fields
- [ ] Expense saves to Firebase
- [ ] Recent Expenses page updates
- [ ] Home page updates automatically

---

## 4.4 Summary Page

### 4.4.1 Summary Page Layout
**User Story:** As a user, I want to view daily and monthly spending summaries so I can analyze my spending patterns.

**Header:**
- Title: "Summary" (center)

**Tab Navigation:**
- Two tabs: "Daily" and "Monthly"

---

### 4.4.2 Daily Tab
**Components:**

1. **Spent Today Card**
   - Display: "Spent Today"
   - Date: Current date
   - Amount: Total spent today (e.g., "RS 1,200")

2. **Daily Spending List**
   - Cards grouped by date (descending order)
   - Each card shows:
     - Date number (large, e.g., "25")
     - Full date (e.g., "June 25, Thursday")
     - Total spent that day (e.g., "RS 12,000")
   - Tap card: Expand to show expense details for that day

**Acceptance Criteria:**
- [ ] Today's spending displays correctly
- [ ] Daily list shows all dates with expenses
- [ ] Amounts calculate correctly per day
- [ ] Cards are tappable and expand

---

### 4.4.3 Monthly Tab
**Components:**

1. **Current Month Summary Card**
   - Month name (e.g., "June 2026")
   - Total Spent: Amount (e.g., "RS 25,600")
   - Allocated Budget: Amount (e.g., "RS 170,000")
   - Remaining: Calculated amount

2. **Category Budget Breakdown**
   - Same as Home page expanded category card
   - Each category shows:
     - Category name
     - Progress bar (spent/allocated)
     - Allocated amount
     - Spent amount
     - Remaining amount

3. **Monthly History**
   - Cards for past months (descending order)
   - Each card shows:
     - Month name (e.g., "July 2026")
     - Status badge: "In Budget" or "Over Budget"
       - In Budget: Spent ≤ Allocated
       - Over Budget: Spent > Allocated
     - Total Spent: Amount
     - Allocated Budget: Amount
     - Remaining: Amount (can be negative)
   - Tap card: Expand to show detailed category breakdown

**Acceptance Criteria:**
- [ ] Current month displays correctly
- [ ] Category breakdown shows progress
- [ ] Monthly history lists all past months
- [ ] Status badge calculates correctly
- [ ] All amounts fetch from Firebase

---

### 4.4.4 Savings Page (Floating Action Button)
**Trigger:** Tap "Savings" FAB (bottom right of Summary page)

**Savings Page Layout:**

1. **Total Savings Card**
   - Display: "Total Savings"
   - Amount: Sum of all savings (e.g., "RS 80,000")

2. **Monthly Savings List**
   - Cards showing savings per month (descending order)
   - Each card:
     - Month name (e.g., "June 2026")
     - Savings amount (e.g., "RS 20,000")

3. **Add Savings FAB**
   - Floating action button (bottom right)
   - Label: "Add Savings"
   - On click: Open popup

**Add Savings Popup:**
- Month dropdown (select month)
- Amount input
- Save button
- Cancel button
- On save: Add to Firebase `savings` collection

**Data Structure (Firebase):**
Collection: `savings`
- `userId` (string)
- `month` (string, e.g., "2026-06")
- `amount` (number)
- `currency` (string)
- `timestamp` (timestamp)

**Acceptance Criteria:**
- [ ] Total savings calculates correctly
- [ ] Monthly savings list displays all entries
- [ ] Add savings popup works
- [ ] Data saves to Firebase
- [ ] UI updates automatically

---

## 4.5 Settings Page

### 4.5.1 Settings Page Layout
**User Story:** As a user, I want to customize app settings so I can personalize my experience.

**Header:**
- Title: "Settings"

**Settings Cards (Top to Bottom):**

---

### 4.5.2 Dark Mode
**Card Layout:**
- Icon: Moon/dark mode icon
- Label: "Dark Mode"
- Switch toggle (right side)

**Functionality:**
- Toggle: Enable/Disable dark mode
- State saved in SharedPreferences
- On enable: Apply dark theme to entire app
- On disable: Apply light theme to entire app
- Theme persists across app sessions

**Acceptance Criteria:**
- [ ] Toggle switch works
- [ ] Dark theme applies to all screens
- [ ] Setting persists after app restart

---

### 4.5.3 Set Currency
**Card Layout:**
- Icon: Currency symbol icon
- Label: "Set Currency"
- Subtitle: Show currently selected currency
- Button: "SET"

**Functionality:**
- On SET click: Open popup modal
- Popup components:
  - Currency dropdown with options:
    - LKR (RS) - Sri Lankan Rupee
    - USD ($) - US Dollar
    - EUR (€) - Euro
    - GBP (£) - British Pound
    - INR (₹) - Indian Rupee
  - Save button
  - Cancel button
- On save:
  - Update SharedPreferences
  - Apply currency symbol throughout app
  - Update all displayed amounts with new currency symbol

**Acceptance Criteria:**
- [ ] Current currency displays
- [ ] Popup shows all currency options
- [ ] Save updates currency across app
- [ ] Setting persists after app restart

---

### 4.5.4 Set Monthly Allocation
**Card Layout:**
- Icon: Wallet/budget icon
- Label: "Set Monthly Allocation"
- Button: "SET"

**Functionality:**
- On SET click: Open popup modal
- Popup components:
  - Amount input field
  - Currency symbol (from current currency setting)
  - Save button
  - Cancel button
- On save:
  - Update Firebase user settings
  - Update Home page Monthly Allocation card
  - Update Summary page current month data
  - Recalculate Remaining Balance

**Acceptance Criteria:**
- [ ] Popup opens with current allocation
- [ ] Save updates Firebase
- [ ] Home page updates automatically
- [ ] Remaining balance recalculates

---

### 4.5.5 Change Profile Name
**Card Layout:**
- Icon: User/profile icon
- Label: "Change Profile Name"
- Subtitle: Show current name
- Button: "SET"

**Functionality:**
- On SET click: Open popup modal
- Popup components:
  - Name input field (pre-filled with current name)
  - Save button
  - Cancel button
- On save:
  - Update Firebase user document
  - Update Home page greeting ("Hello [Name]")

**Acceptance Criteria:**
- [ ] Current name displays
- [ ] Popup pre-fills current name
- [ ] Save updates Firebase
- [ ] Greeting updates on Home page

---

### 4.5.6 Budget Cycle Start
**Card Layout:**
- Icon: Calendar icon
- Label: "Budget Cycle Start"
- Subtitle: Show current cycle (e.g., "June 10, 2026 - July 9, 2026")
- Button: "SET"

**Functionality:**
- On SET click: Open popup modal
- Popup components:
  - Header: "Budget Cycle Start"
  - Close icon (top right)
  - Label: "Select the starting day of your budget cycle"
  - Horizontal scrollable number picker (1-31)
  - Each number in rounded card
  - Live preview: "Budget Tracking Period"
    - Display: "This Month's Cycle: [Start Date] - [End Date]"
    - Example: User selects 10 → "June 10, 2026 - July 9, 2026"
  - Cancel button
  - Save/Update button

- On save:
  - Update Firebase user settings
  - Recalculate current budget cycle
  - Update all expense tracking based on new cycle
  - Update Home page, Expenses page, Summary page to reflect new cycle dates

**Budget Cycle Logic:**
- Cycle runs from selected day to (selected day - 1) of next month
- Example: Start day = 10
  - Current date: June 25, 2026
  - Cycle: June 10, 2026 - July 9, 2026
- If current date < start day in current month:
  - Cycle: Previous month start day - Current month (start day - 1)
- If current date ≥ start day in current month:
  - Cycle: Current month start day - Next month (start day - 1)

**Acceptance Criteria:**
- [ ] Current cycle displays correctly
- [ ] Number picker allows selection 1-31
- [ ] Live preview updates as user selects
- [ ] Save updates Firebase
- [ ] Entire app reflects new budget cycle
- [ ] Expense filtering uses new cycle dates

---

### 4.5.7 Export Monthly Report
**Card Layout:**
- Icon: PDF/document icon
- Label: "Export Monthly Report"
- Subtitle: "Generate and save PDF of current cycle expenses"
- Button: "GENERATE"

**Functionality:**
- On GENERATE click:
  - Show loading indicator
  - Generate PDF with current budget cycle data
  - PDF contents:
    - Header: "Bidget - Monthly Report"
    - Budget Cycle: Dates
    - User Name
    - Currency
    - Summary Section:
      - Allocated Budget
      - Total Spent
      - Remaining Balance
      - Status (In Budget / Over Budget)
    - Category Breakdown:
      - Table with columns: Category, Allocated, Spent, Remaining
    - Detailed Expenses:
      - Grouped by date
      - Table: Date, Title, Category, Amount
    - Footer: Generated date and time
  - Save PDF to device downloads folder
  - Show success message with file path
  - Option to share PDF

**Acceptance Criteria:**
- [ ] Generate button creates PDF
- [ ] PDF includes all required sections
- [ ] PDF saved to device storage
- [ ] Success message displays
- [ ] Share option works

---

### 4.5.8 Logout
**Card Layout:**
- Icon: Logout icon
- Label: "Logout"
- Button: Full-width button (red/warning color)

**Functionality:**
- On click: Show confirmation dialog
  - Message: "Are you sure you want to logout?"
  - Cancel button
  - Logout button
- On confirm:
  - Clear local session
  - Sign out from Firebase Authentication
  - Navigate to biometric login screen

**Acceptance Criteria:**
- [ ] Confirmation dialog appears
- [ ] Logout clears session
- [ ] Navigation to login screen works
- [ ] Re-login requires biometric authentication

---

## 5. Data Models (Firebase Firestore)

### 5.1 Collections Structure

```
users (collection)
  └─ {userId} (document)
      ├─ name: string
      ├─ currency: string (default: "LKR")
      ├─ monthlyAllocation: number
      ├─ budgetCycleStartDay: number (1-31, default: 1)
      ├─ createdAt: timestamp
      └─ updatedAt: timestamp

categories (collection)
  └─ {categoryId} (document)
      ├─ userId: string
      ├─ name: string
      ├─ isDefault: boolean (true for Food, Rent)
      ├─ createdAt: timestamp
      └─ updatedAt: timestamp

categoryBudgets (collection)
  └─ {budgetId} (document)
      ├─ userId: string
      ├─ categoryId: string
      ├─ budgetCycle: string (e.g., "2026-06-10_2026-07-09")
      ├─ allocatedAmount: number
      ├─ createdAt: timestamp
      └─ updatedAt: timestamp

expenses (collection)
  └─ {expenseId} (document)
      ├─ userId: string
      ├─ title: string (optional)
      ├─ categoryId: string
      ├─ amount: number
      ├─ date: timestamp
      ├─ budgetCycle: string (e.g., "2026-06-10_2026-07-09")
      ├─ createdAt: timestamp
      └─ updatedAt: timestamp

savings (collection)
  └─ {savingId} (document)
      ├─ userId: string
      ├─ month: string (e.g., "2026-06")
      ├─ amount: number
      ├─ currency: string
      ├─ createdAt: timestamp
      └─ updatedAt: timestamp
```

### 5.2 Indexes Required
- `expenses`: userId + budgetCycle + date (descending)
- `expenses`: userId + categoryId + budgetCycle
- `categories`: userId + createdAt
- `categoryBudgets`: userId + budgetCycle
- `savings`: userId + month (descending)

---

## 6. User Interface Requirements

### 6.1 Design Guidelines

**Color Scheme:**
- Primary color: Blue (#2196F3) or custom brand color
- Secondary color: Green (#4CAF50) for positive values
- Warning color: Orange (#FF9800) for approaching limits
- Error color: Red (#F44336) for over budget
- Background (Light): White (#FFFFFF), Light Gray (#F5F5F5)
- Background (Dark): Dark Gray (#121212), Darker Gray (#1E1E1E)

**Typography:**
- Primary font: Roboto or custom font family
- Font sizes:
  - Headers: 24sp (bold)
  - Sub-headers: 18sp (medium)
  - Body: 16sp (regular)
  - Captions: 14sp (regular)
  - Small text: 12sp (regular)

**Icons:**
- Use Material Icons or custom icon set
- Consistent icon style throughout app

**Cards:**
- Border radius: 12dp
- Elevation: 2dp
- Padding: 16dp
- Margin: 8dp between cards

**Buttons:**
- Primary buttons: Filled with primary color
- Secondary buttons: Outlined
- Text buttons: Text only
- Border radius: 8dp
- Minimum height: 48dp

**Progress Bars:**
- Height: 8dp
- Border radius: 4dp
- Colors:
  - Green: 0-70% of budget used
  - Orange: 71-90% of budget used
  - Red: 91-100%+ of budget used

**Bottom Sheets:**
- Rounded top corners: 16dp
- Draggable handle
- Max height: 80% of screen

**Graphs:**
- Use bar charts for monthly overview
- Colors: Distinct for Budget, Spent, Remaining
- Interactive touch feedback
- Labels: Clear and readable

### 6.2 Responsive Design
- Support various Android screen sizes
- Portrait orientation (primary)
- Landscape orientation (optional, nice-to-have)
- Minimum screen width: 360dp

### 6.3 Accessibility
- Minimum touch target: 48dp x 48dp
- High contrast for text
- Support for system font scaling
- Descriptive labels for screen readers

---

## 7. Non-Functional Requirements

### 7.1 Performance
- App launch time: < 3 seconds
- Biometric authentication response: < 1 second
- Firestore query response: < 2 seconds
- Smooth scrolling (60fps)
- PDF generation: < 5 seconds

### 7.2 Security
- Biometric authentication required on every app launch
- Secure storage for sensitive data
- Firebase security rules to restrict data access
- No data caching of sensitive information

### 7.3 Reliability
- Offline support: View cached data when offline
- Data sync when connection restored
- Handle Firebase errors gracefully
- Validate all user inputs

### 7.4 Scalability
- Support thousands of expense entries per user
- Efficient queries with pagination
- Optimize Firestore reads/writes

### 7.5 Maintainability
- Clean code architecture (e.g., BLoC, Provider, Riverpod)
- Modular code structure
- Comprehensive comments
- Version control (Git)

---

## 8. Edge Cases & Error Handling

### 8.1 Authentication Errors
- Biometric hardware not available: Show error message, exit app
- Biometric enrollment not set: Prompt user to set up device biometrics
- Authentication failure: Allow retry (max 3 attempts)

### 8.2 Data Validation
- Empty required fields: Show validation error
- Negative amounts: Prevent input
- Invalid dates: Show date picker error
- Category name already exists: Show error message

### 8.3 Firebase Errors
- Network error: Show "No internet connection" message
- Firestore write failure: Retry with exponential backoff
- Read failure: Show error, allow manual retry

### 8.4 Budget Cycle Edge Cases
- User changes cycle mid-month: Recalculate and update all data
- Start day > days in month (e.g., 31 in February): Use last day of month
- Expense date outside current cycle: Still save, but don't count in current cycle totals

### 8.5 Category Deletion
- Category has expenses in current cycle: Show error, prevent deletion
- Category has expenses in past cycles: Allow deletion, keep expense records

### 8.6 PDF Generation Errors
- No expenses in cycle: Generate PDF with zero values
- File write permission denied: Show error message
- PDF generation failure: Show error, allow retry

---

## 9. Success Metrics

### 9.1 User Engagement
- Daily active users (DAU)
- Average session duration
- Number of expenses added per user per day

### 9.2 Feature Adoption
- Percentage of users using category budgets
- Percentage of users using savings tracker
- Percentage of users generating PDF reports

### 9.3 Performance Metrics
- App crash rate: < 1%
- Average app load time
- Firebase query performance

### 9.4 User Satisfaction
- App store rating target: 4.5+
- User retention rate (30-day)

---

## 10. Future Enhancements (Out of Scope for v1.0)

- iOS version
- Multi-user support (family budgets)
- Budget sharing
- Recurring expenses
- Income tracking
- Bill reminders
- Cloud backup and restore
- Advanced analytics with charts
- Export to Excel/CSV
- Integration with bank accounts
- Budget goals and challenges
- Widget support
- Notifications for budget limits

---

## 11. Development Phases

### Phase 1: Foundation (Week 1-2)
- Set up Flutter project
- Configure Firebase (Authentication, Firestore)
- Implement biometric authentication
- Create basic navigation structure
- Set up state management

### Phase 2: Core Features (Week 3-4)
- Home page with budget overview
- Add/Edit/Delete expenses
- Recent expenses page
- Category management
- Budget cycle logic

### Phase 3: Summaries & Reports (Week 5)
- Daily/Monthly summary tabs
- Savings tracker
- PDF report generation
- Graphs and visualizations

### Phase 4: Settings & Customization (Week 6)
- Settings page
- Dark mode
- Currency selection
- Budget cycle configuration
- Profile management

### Phase 5: Testing & Polish (Week 7-8)
- Unit testing
- Integration testing
- UI/UX polish
- Performance optimization
- Bug fixes

### Phase 6: Deployment (Week 9)
- Final testing
- App store assets (screenshots, description)
- Google Play Store submission
- Documentation

---

## 12. Acceptance Criteria Summary

The app is considered complete when:
- [ ] Biometric authentication works reliably
- [ ] All CRUD operations for expenses work
- [ ] Budget tracking and calculations are accurate
- [ ] Category management is functional
- [ ] Budget cycle configuration works correctly
- [ ] All summaries display correct data
- [ ] Savings tracker is functional
- [ ] PDF reports generate successfully
- [ ] Dark mode works on all screens
- [ ] Multi-currency support is implemented
- [ ] All settings save and persist
- [ ] App is responsive and performs well
- [ ] No critical bugs

---

## 13. Glossary

- **Budget Cycle:** The recurring time period for budget tracking (e.g., 10th of one month to 9th of next month)
- **Category:** A classification for expenses (e.g., Food, Rent, Transport)
- **Monthly Allocation:** The total budget set for a month
- **Remaining Balance:** Allocated budget minus total spent
- **Savings:** Manually entered savings amounts, tracked separately from budget

---

## 14. Appendix

### 14.1 Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Categories collection
    match /categories/{categoryId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Category Budgets collection
    match /categoryBudgets/{budgetId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Expenses collection
    match /expenses/{expenseId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Savings collection
    match /savings/{savingId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### 14.2 Sample Data Structure

**User Document:**
```json
{
  "userId": "abc123",
  "name": "John Doe",
  "currency": "LKR",
  "monthlyAllocation": 170000,
  "budgetCycleStartDay": 10,
  "createdAt": "2026-06-01T10:00:00Z",
  "updatedAt": "2026-06-15T14:30:00Z"
}
```

**Expense Document:**
```json
{
  "expenseId": "exp123",
  "userId": "abc123",
  "title": "Grocery Shopping",
  "categoryId": "cat456",
  "amount": 5000,
  "date": "2026-06-25T18:00:00Z",
  "budgetCycle": "2026-06-10_2026-07-09",
  "createdAt": "2026-06-25T18:05:00Z",
  "updatedAt": "2026-06-25T18:05:00Z"
}
```

**Category Budget Document:**
```json
{
  "budgetId": "bud789",
  "userId": "abc123",
  "categoryId": "cat456",
  "budgetCycle": "2026-06-10_2026-07-09",
  "allocatedAmount": 30000,
  "createdAt": "2026-06-10T00:00:00Z",
  "updatedAt": "2026-06-10T00:00:00Z"
}
```

---

**Document End**

**Prepared by:** AI Assistant  
**Last Updated:** July 15, 2026  
**Version:** 1.0
