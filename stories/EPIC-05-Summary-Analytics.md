# Epic 5: Summary & Analytics

**Epic ID**: EPIC-05  
**Epic Name**: Summary & Analytics  
**Epic Owner**: Development Team  
**Business Value**: Provide insights into spending patterns  
**Target Release**: v1.0

---

## Story SUM-001: Daily Summary Tab

**Story ID**: SUM-001  
**Story Title**: Daily Spending Overview  
**Priority**: Must Have (P0)  
**Story Points**: 5

### User Story
**As a** user  
**I want to** view my daily spending summary  
**So that** I can track my day-to-day expenses

### Acceptance Criteria

**Given** the user navigates to the Summary page  
**When** the page loads  
**Then** the page should display:
- Header: "Summary" (center)
- Two tabs: "Daily" and "Monthly"
- Daily tab selected by default

**Given** the Daily tab is active  
**When** the tab content loads  
**Then** the following components should display:
- "Spent Today" card at the top
- Daily spending list below

**Given** the "Spent Today" card is displayed  
**When** the card renders  
**Then** it should show:
- Title: "Spent Today"
- Current date
- Total amount spent today with currency (e.g., "RS 1,200")

**Given** no expenses exist for today  
**When** the card is displayed  
**Then** the amount should show "RS 0"

**Given** the daily spending list is displayed  
**When** the list renders  
**Then** expenses should be grouped by date (descending order)  
**And** each date card should show:
- Large date number (e.g., "25")
- Full date with day (e.g., "June 25, Thursday")
- Total spent that day (e.g., "RS 12,000")

**Given** a date card is tapped  
**When** the card is pressed  
**Then** the card should expand  
**And** show detailed expense list for that day with:
- Expense title
- Category name
- Amount

**Given** no expenses exist  
**When** the daily list is empty  
**Then** an empty state should display: "No expenses yet"

### Technical Notes
- Firestore query: Filter by userId + budgetCycle, group by date
- Today's total: Sum expenses where date = today
- Daily totals: Aggregate expenses by date
- Use ExpansionTile for expandable cards
- Date formatting: Use `intl` package
- Lazy loading: Load 30 days at a time

### Dependencies
- EXP-002 (Expenses must exist)
- HOME-001 (Navigation to Summary page)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Summary page displays correctly
- [ ] Tabs functional
- [ ] Spent Today card shows correct amount
- [ ] Daily list displays grouped expenses
- [ ] Date cards expandable
- [ ] Totals calculate correctly
- [ ] Empty state handled
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story SUM-002: Monthly Summary Tab

**Story ID**: SUM-002  
**Story Title**: Monthly Spending Overview  
**Priority**: Must Have (P0)  
**Story Points**: 5

### User Story
**As a** user  
**I want to** view my monthly spending summary  
**So that** I can understand my overall monthly financial status

### Acceptance Criteria

**Given** the user taps the "Monthly" tab  
**When** the tab is selected  
**Then** the following components should display:
- Current month summary card
- Category budget breakdown
- Monthly history list

**Given** the current month summary card is displayed  
**When** the card renders  
**Then** it should show:
- Month name (e.g., "June 2026")
- Total Spent: Amount (e.g., "RS 25,600")
- Allocated Budget: Amount (e.g., "RS 170,000")
- Remaining: Calculated amount

**Given** spending exceeds budget  
**When** the card is displayed  
**Then** the Total Spent should be in red  
**And** Remaining should show negative amount in red

**Given** the category budget breakdown is displayed  
**When** the section renders  
**Then** each category should show:
- Category name
- Progress bar (spent/allocated)
- Allocated amount
- Spent amount
- Remaining amount
**And** same as Home page category card

**Given** the monthly history is displayed  
**When** the section renders  
**Then** cards for past months should appear (descending order)  
**And** each card should show:
- Month name (e.g., "May 2026")
- Status badge: "In Budget" or "Over Budget"
- Total Spent
- Allocated Budget
- Remaining (can be negative)

**Given** a month's status is "In Budget"  
**When** Spent ≤ Allocated  
**Then** the badge should be green

**Given** a month's status is "Over Budget"  
**When** Spent > Allocated  
**Then** the badge should be red

**Given** a monthly history card is tapped  
**When** the card is pressed  
**Then** it should expand  
**And** show detailed category breakdown for that month

### Technical Notes
- Aggregate by budgetCycle
- Current month: Use current cycle
- Past months: Query previous cycles
- Status calculation: spent <= allocated ? "In Budget" : "Over Budget"
- Badge colors: Green (in budget), Red (over budget)
- Load 12 months initially, paginate for more

### Dependencies
- SUM-001 (Summary page structure)
- HOME-004 (Category breakdown component)
- CYC-003 (Budget cycle history)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Monthly tab displays correctly
- [ ] Current month summary accurate
- [ ] Category breakdown shows correctly
- [ ] Monthly history lists all past months
- [ ] Status badges calculate correctly
- [ ] Expandable cards work
- [ ] Color coding applied correctly
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story SUM-003: Budget Status Indicator

**Story ID**: SUM-003  
**Story Title**: Visual Budget Status Badge  
**Priority**: Should Have (P1)  
**Story Points**: 2

### User Story
**As a** user  
**I want to** see at a glance whether I'm within budget  
**So that** I can quickly assess my financial status

### Acceptance Criteria

**Given** monthly summary is displayed  
**When** the status is calculated  
**Then** a badge should display with appropriate status:
- "In Budget" if Spent ≤ Allocated
- "Over Budget" if Spent > Allocated

**Given** the status is "In Budget"  
**When** the badge is rendered  
**Then** it should have:
- Green background
- White text
- Check icon (optional)

**Given** the status is "Over Budget"  
**When** the badge is rendered  
**Then** it should have:
- Red background
- White text
- Warning icon (optional)

**Given** no budget is set  
**When** the badge is calculated  
**Then** it should display "No Budget Set" with neutral styling

### Technical Notes
- Badge widget: Container with rounded corners
- Colors: Green (#4CAF50), Red (#F44336), Gray (#9E9E9E)
- Icons: Check (in budget), Warning (over budget)
- Typography: 12sp, bold, uppercase

### Dependencies
- SUM-002 (Monthly summary display)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Badge displays correctly
- [ ] Status calculation accurate
- [ ] Color coding applied
- [ ] Icons display (optional)
- [ ] No budget state handled
- [ ] Widget tests passed

---

## Story SUM-004: Category Spending Progress

**Story ID**: SUM-004  
**Story Title**: Visual Category Budget Progress Bars  
**Priority**: Should Have (P1)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** see visual progress bars for each category  
**So that** I can quickly identify which categories I'm spending most on

### Acceptance Criteria

**Given** category breakdown is displayed  
**When** each category renders  
**Then** a progress bar should show the percentage: (Spent / Allocated) × 100

**Given** the progress is 0-70%  
**When** the bar is displayed  
**Then** the bar should be green

**Given** the progress is 71-90%  
**When** the bar is displayed  
**Then** the bar should be orange  
**And** serve as a warning indicator

**Given** the progress is 91-100%+  
**When** the bar is displayed  
**Then** the bar should be red  
**And** indicate approaching or over budget

**Given** no budget is allocated for a category  
**When** the category is displayed  
**Then** the progress bar should show "Not Set" or empty state

**Given** spending exceeds allocation  
**When** progress > 100%  
**Then** the bar should be full (100%) and red  
**And** show exceeded amount separately

### Technical Notes
- Use LinearProgressIndicator or custom widget
- Height: 8dp
- Border radius: 4dp
- Colors:
  - Green: 0-70% (#4CAF50)
  - Orange: 71-90% (#FF9800)
  - Red: 91%+ (#F44336)
- Animation: Smooth transition on data change

### Dependencies
- SUM-002 (Category breakdown display)
- HOME-004 (Category budget card)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Progress bars display correctly
- [ ] Percentage calculation accurate
- [ ] Color coding applied correctly
- [ ] Animation smooth
- [ ] Over 100% handled
- [ ] No allocation state handled
- [ ] Widget tests passed

---

## Story SUM-005: Expense Details Expansion

**Story ID**: SUM-005  
**Story Title**: Expandable Expense Details in Summary  
**Priority**: Could Have (P2)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** expand summary cards to see detailed expenses  
**So that** I can view details without leaving the summary page

### Acceptance Criteria

**Given** a daily spending card is displayed  
**When** the card is tapped  
**Then** it should expand to show:
- List of expenses for that day
- Each expense: title, category, amount

**Given** a monthly history card is displayed  
**When** the card is tapped  
**Then** it should expand to show:
- Category-wise breakdown
- Each category: allocated, spent, remaining

**Given** an expanded card is tapped again  
**When** the card is tapped  
**Then** it should collapse back to summary view

**Given** multiple cards are expanded  
**When** a new card is tapped  
**Then** previously expanded cards should remain expanded  
**Or** collapse others based on UX preference

### Technical Notes
- Use ExpansionTile widget
- Animation duration: 300ms
- Maintain expansion state during scrolling
- Fetch detailed data on expansion (lazy load)
- Consider performance with many expanded cards

### Dependencies
- SUM-001 (Daily summary)
- SUM-002 (Monthly summary)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Cards expand/collapse correctly
- [ ] Detailed data displays
- [ ] Animation smooth
- [ ] Performance acceptable
- [ ] Widget tests passed

---

## Story SUM-006: Summary Data Refresh

**Story ID**: SUM-006  
**Story Title**: Real-time Summary Updates  
**Priority**: Must Have (P0)  
**Story Points**: 2

### User Story
**As a** user  
**I want** summary data to update automatically  
**So that** I always see accurate, current information

### Acceptance Criteria

**Given** the Summary page is open  
**When** a new expense is added  
**Then** all summary cards should update automatically:
- Spent Today amount
- Daily totals
- Monthly summary
- Category breakdown

**Given** an expense is edited  
**When** the update occurs  
**Then** affected summaries should recalculate  
**And** UI should reflect changes within 2 seconds

**Given** an expense is deleted  
**When** the deletion occurs  
**Then** all related summaries should update  
**And** progress bars should adjust

**Given** the user pulls to refresh  
**When** pull-to-refresh gesture is performed  
**Then** all data should reload from Firebase  
**And** a loading indicator should display

### Technical Notes
- Use StreamBuilder for real-time Firestore updates
- Subscribe to expenses collection changes
- Debounce updates: Wait 500ms before recalculating
- Pull-to-refresh: RefreshIndicator widget
- Show loading shimmer during refresh

### Dependencies
- SUM-001 (Daily summary)
- SUM-002 (Monthly summary)
- EXP-001 to EXP-004 (Expense operations)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Real-time updates work
- [ ] All summaries update on expense changes
- [ ] Pull-to-refresh functional
- [ ] Loading states handled
- [ ] Performance acceptable
- [ ] Integration tests passed

---

## Epic 5 Summary

**Total Stories**: 6  
**Total Story Points**: 20  
**Estimated Duration**: 4 days  
**Must Have Stories**: 4  
**Should Have Stories**: 2  
**Could Have Stories**: 1

### Epic Acceptance Criteria
- [ ] All summary stories completed
- [ ] Daily and monthly tabs functional
- [ ] Real-time updates working
- [ ] Visual indicators accurate
- [ ] Performance acceptable
- [ ] All tests passing
