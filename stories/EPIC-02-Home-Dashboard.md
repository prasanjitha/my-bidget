# Epic 2: Home & Dashboard

**Epic ID**: EPIC-02  
**Epic Name**: Home & Dashboard  
**Epic Owner**: Development Team  
**Business Value**: Central hub for budget overview and quick insights  
**Target Release**: v1.0

---

## Story HOME-001: Home Page Navigation Structure

**Story ID**: HOME-001  
**Story Title**: Bottom Navigation Bar Implementation  
**Priority**: Must Have (P0)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** navigate between main app sections using a bottom navigation bar  
**So that** I can easily access different features of the app

### Acceptance Criteria

**Given** the user is authenticated  
**When** the Home page loads  
**Then** a bottom navigation bar should be displayed with 5 items:
- Home (icon + label)
- Expenses (icon + label)
- Add Expense (center FAB with + icon)
- Summary (icon + label)
- Settings (icon + label)

**Given** the user is on any page  
**When** the user taps a navigation item  
**Then** the app should navigate to the corresponding page  
**And** the selected item should be highlighted

**Given** the user taps the center FAB (+)  
**When** the button is pressed  
**Then** the "Add Expense" bottom sheet should open

**Given** the bottom navigation bar is displayed  
**When** the user scrolls content  
**Then** the navigation bar should remain fixed at the bottom

### Technical Notes
- Use Flutter's `BottomNavigationBar` widget
- Center FAB should float above navigation bar
- Use Material Icons for consistency
- Active tab indicator color: Primary color
- Navigation state management with Provider/Riverpod/BLoC

### Dependencies
- AUTH-002 (User must be authenticated)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Bottom navigation bar displays correctly
- [ ] All 5 navigation items functional
- [ ] Center FAB opens Add Expense sheet
- [ ] Navigation state persists correctly
- [ ] UI matches design specifications
- [ ] Unit tests written
- [ ] Widget tests passed

---

## Story HOME-002: User Greeting Display

**Story ID**: HOME-002  
**Story Title**: Personalized Greeting Message  
**Priority**: Should Have (P1)  
**Story Points**: 2

### User Story
**As a** user  
**I want to** see a personalized greeting on the home page  
**So that** I feel welcomed and know I'm in my account

### Acceptance Criteria

**Given** the user has not set a custom name  
**When** the Home page loads  
**Then** the greeting should display "Hello User"

**Given** the user has set a custom name in settings  
**When** the Home page loads  
**Then** the greeting should display "Hello [User Name]"  
**And** the name should be fetched from Firebase user document

**Given** the user's name is very long (>20 characters)  
**When** the greeting is displayed  
**Then** the name should be truncated with ellipsis  
**And** full name shown on tap

### Technical Notes
- Fetch user name from Firestore `users` collection
- Default value: "User"
- Use StreamBuilder for real-time updates
- Typography: 24sp, bold, primary text color
- Cache user name locally for quick display

### Dependencies
- HOME-001 (Navigation structure)
- SET-005 (Change Profile Name feature)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Greeting displays correctly
- [ ] Real-time updates when name changes
- [ ] Long name truncation works
- [ ] Default "User" displays when no name set
- [ ] Unit tests written
- [ ] Widget tests passed

---

## Story HOME-003: Monthly Budget Allocation Card

**Story ID**: HOME-003  
**Story Title**: Display and Set Monthly Budget  
**Priority**: Must Have (P0)  
**Story Points**: 5

### User Story
**As a** user  
**I want to** view and set my monthly budget allocation  
**So that** I can plan my spending for the month

### Acceptance Criteria

**Given** the user has set a monthly budget  
**When** the Home page loads  
**Then** the "Monthly Allocation Budget" card should display:
- Card title: "MONTHLY Allocation Budget"
- Current month name (e.g., "June 2026")
- Budget amount with currency symbol (e.g., "RS 170,000")
- "SET" button

**Given** the user has not set a monthly budget  
**When** the Home page loads  
**Then** the amount should display "RS 0" or "Not Set"  
**And** the SET button should be prominent

**Given** the user clicks the SET button  
**When** the button is pressed  
**Then** a popup modal should open with:
- Currency dropdown (LKR, USD, EUR, GBP, INR)
- Amount input field
- Save button
- Cancel button

**Given** the user enters a valid amount and saves  
**When** the Save button is pressed  
**Then** the budget should be saved to Firebase `users` collection  
**And** the card should update immediately  
**And** the Remaining Balance card should recalculate  
**And** a success message should display

**Given** the user enters an invalid amount (negative, text)  
**When** the Save button is pressed  
**Then** a validation error should display  
**And** the save should be prevented

### Technical Notes
- Store in Firestore: `users/{userId}/monthlyAllocation`
- Use number input keyboard for amount
- Min amount: 0, Max amount: 999,999,999
- Currency stored separately in `users/{userId}/currency`
- Real-time sync with StreamBuilder
- Format numbers with thousand separators

### Dependencies
- HOME-001 (Navigation structure)
- SET-003 (Currency setting)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Card displays budget correctly
- [ ] SET button opens popup
- [ ] Currency dropdown works
- [ ] Amount validation implemented
- [ ] Save updates Firebase
- [ ] UI updates in real-time
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story HOME-004: Category Budget Allocation Expanded Card

**Story ID**: HOME-004  
**Story Title**: Category-wise Budget Breakdown  
**Priority**: Must Have (P0)  
**Story Points**: 8

### User Story
**As a** user  
**I want to** see and manage budget allocations for each expense category  
**So that** I can track spending by category and stay within limits

### Acceptance Criteria

**Given** the user is on the Home page  
**When** the page loads  
**Then** a "Budget Categories" card should be displayed in collapsed state  
**And** an expand/collapse icon should be visible

**Given** the card is collapsed  
**When** the user taps the card or expand icon  
**Then** the card should expand and show all categories

**Given** the card is expanded  
**When** categories are displayed  
**Then** each category should show:
- Category name (e.g., "Food", "Rent")
- Progress bar (visual: spent/allocated)
- Allocated budget amount
- Remaining amount
- "SET" button

**Given** no expenses have been added for a category  
**When** the category is displayed  
**Then** the progress bar should be at 0%  
**And** spent amount should be "RS 0"

**Given** expenses exist for a category  
**When** the category is displayed  
**Then** the progress bar should reflect spent/allocated percentage  
**And** color should be:
- Green: 0-70% spent
- Orange: 71-90% spent
- Red: 91%+ spent

**Given** the user taps a category's SET button  
**When** the button is pressed  
**Then** a popup should open to set category budget  
**And** popup should contain:
- Category name (read-only)
- Budget amount input
- Save and Cancel buttons

**Given** the user saves a category budget  
**When** the Save button is pressed  
**Then** the budget should be saved to Firebase `categoryBudgets` collection  
**And** the category card should update immediately  
**And** progress bar should recalculate

**Given** the card is expanded  
**When** the bottom of the list is reached  
**Then** an "Add New Category" button should be visible

**Given** the user taps "Add New Category"  
**When** the button is pressed  
**Then** a popup should open to create a new category  
**And** popup should contain:
- Category name input
- Save and Cancel buttons

**Given** the user enters a valid category name  
**When** the Save button is pressed  
**Then** the category should be saved to Firebase `categories` collection  
**And** the new category should appear in the list  
**And** default budget should be 0

**Given** the user enters a duplicate category name  
**When** Save is attempted  
**Then** an error should display: "Category already exists"

### Technical Notes
- Firestore collections: `categories`, `categoryBudgets`
- Real-time calculation: Sum expenses by categoryId and budgetCycle
- Default categories: Food, Rent (isDefault: true)
- Progress bar widget with dynamic colors
- Pagination if categories > 20
- Use ExpansionTile or custom expandable widget

### Dependencies
- HOME-003 (Monthly budget must exist)
- CAT-001 to CAT-005 (Category management stories)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Card expands/collapses correctly
- [ ] All category data displays correctly
- [ ] Progress bars show accurate percentages
- [ ] Color coding works (green/orange/red)
- [ ] SET button opens category budget popup
- [ ] Category budget saves to Firebase
- [ ] Add New Category button works
- [ ] Duplicate category validation works
- [ ] Real-time updates functional
- [ ] Unit tests written
- [ ] Integration tests passed
- [ ] Performance tested with 50+ categories

---

## Story HOME-005: Total Spend Card

**Story ID**: HOME-005  
**Story Title**: Current Month Total Spend Display  
**Priority**: Must Have (P0)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** see my total spending for the current budget cycle  
**So that** I can monitor how much I've spent overall

### Acceptance Criteria

**Given** the user is on the Home page  
**When** the page loads  
**Then** the "Total Spend" card should display:
- Card title: "Total Spend"
- Current budget cycle month name (e.g., "June 2026")
- Total amount spent with currency (e.g., "RS 20,000")

**Given** no expenses have been added  
**When** the card is displayed  
**Then** the amount should show "RS 0"

**Given** expenses are added/edited/deleted  
**When** any expense operation occurs  
**Then** the total spend should update automatically in real-time

**Given** the budget cycle changes  
**When** the cycle start day is modified in settings  
**Then** the total spend should recalculate for the new cycle  
**And** display the correct amount

**Given** the total spend exceeds allocated budget  
**When** the card is displayed  
**Then** the amount should be displayed in red/warning color

### Technical Notes
- Aggregate query: Sum all expenses where budgetCycle = current cycle
- Firestore query: `expenses` collection filtered by userId + budgetCycle
- Real-time listener for expense changes
- Cache result for 5 seconds to reduce reads
- Format with thousand separators

### Dependencies
- HOME-003 (Monthly budget allocation)
- EXP-001 to EXP-004 (Expense CRUD operations)
- CYC-001 (Budget cycle calculation)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Card displays correctly
- [ ] Total calculation is accurate
- [ ] Real-time updates work
- [ ] Budget cycle changes reflected
- [ ] Over-budget styling applied
- [ ] Number formatting correct
- [ ] Unit tests written
- [ ] Integration tests passed
- [ ] Performance tested with 1000+ expenses

---

## Story HOME-006: Remaining Balance Card

**Story ID**: HOME-006  
**Story Title**: Remaining Budget Balance Display  
**Priority**: Must Have (P0)  
**Story Points**: 2

### User Story
**As a** user  
**I want to** see my remaining budget balance  
**So that** I know how much I have left to spend

### Acceptance Criteria

**Given** the user has set a monthly budget and added expenses  
**When** the Home page loads  
**Then** the "Remaining Balance" card should display:
- Card title: "Remaining Balance"
- Calculated amount: (Allocated Budget - Total Spend)
- Amount with currency symbol (e.g., "RS 150,000")

**Given** no budget is set  
**When** the card is displayed  
**Then** the amount should show "RS 0" or "Set budget first"

**Given** the remaining balance is positive  
**When** the card is displayed  
**Then** the amount should be displayed in green

**Given** the remaining balance is negative (over budget)  
**When** the card is displayed  
**Then** the amount should be displayed in red  
**And** show negative sign (e.g., "RS -10,000")

**Given** expenses or budget allocation changes  
**When** any update occurs  
**Then** the remaining balance should recalculate automatically

### Technical Notes
- Formula: monthlyAllocation - totalSpent
- Real-time calculation using StreamBuilder
- Subscribe to both budget and expenses changes
- Color coding: Green (positive), Red (negative)
- Format with thousand separators

### Dependencies
- HOME-003 (Monthly budget allocation)
- HOME-005 (Total spend calculation)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Card displays correctly
- [ ] Calculation is accurate
- [ ] Real-time updates work
- [ ] Color coding applied correctly
- [ ] Negative balance displays properly
- [ ] Number formatting correct
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story HOME-007: Monthly Overview Graph

**Story ID**: HOME-007  
**Story Title**: Visual Budget Overview Bar Chart  
**Priority**: Should Have (P1)  
**Story Points**: 5

### User Story
**As a** user  
**I want to** see a visual graph of my budget, spending, and remaining balance  
**So that** I can quickly understand my financial status at a glance

### Acceptance Criteria

**Given** the user is on the Home page  
**When** the page loads  
**Then** a "Monthly Overview" card should display with:
- Header: "Monthly Overview - [Current Month Name]"
- Bar graph with 3 bars:
  - Budget (allocated amount)
  - Spent (total expenses)
  - Remaining (balance)

**Given** the graph is displayed  
**When** the user views the bars  
**Then** each bar should have a distinct color:
- Budget: Blue
- Spent: Orange
- Remaining: Green

**Given** the user taps a bar  
**When** touch is registered  
**Then** the exact amount for that bar should display  
**And** show a tooltip or label with the value

**Given** no data exists  
**When** the graph is rendered  
**Then** empty state should display: "Set budget to see overview"

**Given** spent exceeds budget  
**When** the graph is displayed  
**Then** the Spent bar should extend beyond Budget bar  
**And** Remaining bar should show negative (or not display)

**Given** data changes  
**When** budget or expenses update  
**Then** the graph should animate smoothly to new values

### Technical Notes
- Use `fl_chart` package (BarChart widget)
- X-axis labels: "Budget", "Spent", "Remaining"
- Y-axis: Auto-scale based on max value
- Touch interaction: `BarTouchData` for tooltips
- Animate transitions: Duration 300ms
- Responsive: Adjust to screen width

### Dependencies
- HOME-003 (Monthly budget)
- HOME-005 (Total spend)
- HOME-006 (Remaining balance)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Graph displays correctly
- [ ] All 3 bars shown with correct data
- [ ] Touch interaction works
- [ ] Tooltips display amounts
- [ ] Colors match design
- [ ] Animations smooth
- [ ] Empty state handled
- [ ] Over-budget scenario handled
- [ ] Responsive on different screen sizes
- [ ] Unit tests written
- [ ] Widget tests passed

---

## Epic 2 Summary

**Total Stories**: 7  
**Total Story Points**: 28  
**Estimated Duration**: 5-6 days  
**Must Have Stories**: 5  
**Should Have Stories**: 2  
**Could Have Stories**: 0

### Epic Acceptance Criteria
- [ ] All home page stories completed
- [ ] Home page displays all required components
- [ ] Real-time data updates work
- [ ] Navigation functional
- [ ] Budget calculations accurate
- [ ] UI matches design specifications
- [ ] All tests passing
- [ ] Performance acceptable (load < 2s)
