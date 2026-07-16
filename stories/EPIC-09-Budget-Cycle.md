# Epic 9: Budget Cycle Management

**Epic ID**: EPIC-09  
**Epic Name**: Budget Cycle Management  
**Epic Owner**: Development Team  
**Business Value**: Flexible budget tracking aligned with user's pay schedule  
**Target Release**: v1.0

---

## Story CYC-001: Budget Cycle Calculation Logic

**Story ID**: CYC-001  
**Story Title**: Calculate Current Budget Cycle  
**Priority**: Must Have (P0)  
**Story Points**: 5

### User Story
**As a** developer  
**I want** a reliable budget cycle calculation function  
**So that** the app can accurately track expenses within the correct cycle

### Acceptance Criteria

**Given** the user has set a budget cycle start day  
**When** the app needs to determine the current cycle  
**Then** the calculation should follow these rules:

1. **Cycle runs from start day to (start day - 1) of next month**
   - Example: Start day = 10
   - Cycle: 10th of Month A to 9th of Month B

2. **If current date < start day in current month:**
   - Current cycle: Previous month's start day to current month (start day - 1)
   - Example: Today = June 5, Start day = 10
   - Cycle: May 10 - June 9

3. **If current date ≥ start day in current month:**
   - Current cycle: Current month's start day to next month (start day - 1)
   - Example: Today = June 15, Start day = 10
   - Cycle: June 10 - July 9

4. **Edge case: Start day > days in month**
   - Example: Start day = 31, February
   - Use last day of that month (Feb 28 or 29)

**Given** a specific date is provided  
**When** the cycle is calculated  
**Then** return a cycle object with:
- startDate (DateTime)
- endDate (DateTime)
- cycleString (String: "2026-06-10_2026-07-09")

**Given** expenses are added  
**When** the expense date is set  
**Then** calculate which cycle the expense belongs to  
**And** assign the appropriate budgetCycle string

### Technical Notes
- Create utility class: `BudgetCycleUtil`
- Methods:
  - `getCurrentCycle(int startDay): BudgetCycle`
  - `getCycleForDate(DateTime date, int startDay): BudgetCycle`
  - `formatCycleString(BudgetCycle cycle): String`
  - `parseCycleString(String cycleString): BudgetCycle`
- Handle edge cases:
  - February with 28/29 days
  - Months with 30 days
  - Months with 31 days
- Use Dart DateTime class
- Format: ISO 8601 for dates

### Dependencies
- None (foundational utility)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Utility class created
- [ ] All calculation methods implemented
- [ ] Edge cases handled correctly
- [ ] Comprehensive unit tests written
- [ ] Test cases cover:
  - All 12 months
  - Start days 1-31
  - Leap years
  - Edge cases (Feb 30, etc.)
- [ ] Code documentation complete
- [ ] Performance acceptable (< 10ms per calculation)

---

## Story CYC-002: Apply Budget Cycle to Expenses

**Story ID**: CYC-002  
**Story Title**: Assign Expenses to Budget Cycles  
**Priority**: Must Have (P0)  
**Story Points**: 3

### User Story
**As a** user  
**I want** my expenses to be tracked within the correct budget cycle  
**So that** my budget summaries are accurate

### Acceptance Criteria

**Given** a new expense is added  
**When** the expense is saved  
**Then** calculate the budget cycle based on:
- Expense date
- User's budgetCycleStartDay from Firebase
**And** set the expense's budgetCycle field

**Given** an expense is edited and the date changes  
**When** the update is saved  
**Then** recalculate the budget cycle  
**And** update the budgetCycle field if different

**Given** expenses are filtered on Home page  
**When** calculating totals  
**Then** only include expenses where budgetCycle = current cycle

**Given** expenses are displayed on Expenses page  
**When** showing "Recent Expenses"  
**Then** filter by budgetCycle = current cycle

**Given** the user changes budgetCycleStartDay in settings  
**When** the change is saved  
**Then** trigger a background job to:
- Recalculate budgetCycle for all user's expenses
- Update expenses in Firestore
- Refresh all relevant UI components

### Technical Notes
- Firestore field: `expenses/{expenseId}/budgetCycle` (string)
- Format: "YYYY-MM-DD_YYYY-MM-DD" (e.g., "2026-06-10_2026-07-09")
- Query optimization: Index on userId + budgetCycle
- Background update: Use Cloud Functions or client-side batch update
- Batch size: 500 documents per batch (Firestore limit)
- Progress indicator during bulk update

### Dependencies
- CYC-001 (Calculation logic)
- EXP-001 (Add expense)
- EXP-003 (Edit expense)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Budget cycle assigned on expense creation
- [ ] Budget cycle updated on expense edit
- [ ] Filtering by cycle works correctly
- [ ] Bulk update on cycle start day change works
- [ ] Progress indicator during bulk update
- [ ] Performance acceptable (bulk update < 10s for 1000 expenses)
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story CYC-003: Budget Cycle History

**Story ID**: CYC-003  
**Story Title**: Generate and Display Past Budget Cycles  
**Priority**: Should Have (P1)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** view a list of all my past budget cycles  
**So that** I can review historical spending periods

### Acceptance Criteria

**Given** the user opens the "View All Expenses" page  
**When** the budget cycle dropdown is opened  
**Then** a list of all cycles should be displayed:
- Current cycle (highlighted or marked)
- Past cycles (descending order)
- Format: "June 10, 2026 - July 9, 2026"

**Given** the user account has been active for multiple months  
**When** generating the cycle list  
**Then** create cycles from:
- User's account creation date (or first expense date)
- Up to current cycle

**Given** no expenses exist in a past cycle  
**When** that cycle is selected  
**Then** show empty state: "No expenses in this cycle"

**Given** the user selects a past cycle  
**When** the selection is made  
**Then** filter and display expenses for that cycle only

### Technical Notes
- Generate cycle list dynamically:
  - Start: User createdAt or first expense date
  - End: Current date
  - Interval: Based on budgetCycleStartDay
- Create utility method: `generateCycleList(DateTime from, DateTime to, int startDay): List<BudgetCycle>`
- Cache cycle list for performance
- Limit initial load: Show last 12 months, lazy load older
- Display format: Use DateFormat from `intl`

### Dependencies
- CYC-001 (Calculation logic)
- EXP-007 (View All Expenses page)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Cycle list generates correctly
- [ ] Current cycle highlighted
- [ ] Past cycles in descending order
- [ ] Lazy loading for older cycles
- [ ] Empty state handled
- [ ] Cycle selection filters expenses
- [ ] Performance acceptable
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Epic 9 Summary

**Total Stories**: 3  
**Total Story Points**: 11  
**Estimated Duration**: 2-3 days  
**Must Have Stories**: 2  
**Should Have Stories**: 1  
**Could Have Stories**: 0

### Epic Acceptance Criteria
- [ ] All budget cycle stories completed
- [ ] Calculation logic accurate and reliable
- [ ] Expenses correctly assigned to cycles
- [ ] Cycle changes handled properly
- [ ] Historical cycles accessible
- [ ] All edge cases handled
- [ ] Performance acceptable
- [ ] All tests passing
- [ ] Documentation complete

---

## Cross-Epic Dependencies

### Critical Path
1. **Authentication** (EPIC-01) → Must complete first
2. **Budget Cycle** (EPIC-09) → Core logic needed early
3. **Category Management** (EPIC-04) → Required for expenses
4. **Home & Dashboard** (EPIC-02) + **Expense Management** (EPIC-03) → Core features
5. **Summary** (EPIC-05) + **Settings** (EPIC-07) → Build on core features
6. **Savings** (EPIC-06) + **Reports** (EPIC-08) → Final features

### Parallel Development Opportunities
- EPIC-01 (Auth) can be developed independently
- EPIC-04 (Categories) and EPIC-09 (Budget Cycle) can be parallel
- EPIC-02 (Home) and EPIC-03 (Expenses) can be partially parallel
- EPIC-05 (Summary), EPIC-06 (Savings), EPIC-07 (Settings), EPIC-08 (Reports) can be parallel after core features

### Total Project Estimate
- **Total Stories**: 42
- **Total Story Points**: 143
- **Estimated Duration**: 7-9 weeks (including testing and polish)
- **Team Size Recommendation**: 2-3 developers

---

## Story Point Summary by Epic

| Epic | Stories | Story Points | Priority |
|------|---------|--------------|----------|
| EPIC-01: Authentication | 3 | 11 | Must Have |
| EPIC-02: Home & Dashboard | 7 | 28 | Must Have |
| EPIC-03: Expense Management | 8 | 29 | Must Have |
| EPIC-04: Category Management | 5 | 12 | Must Have |
| EPIC-05: Summary & Analytics | 6 | 20 | Must Have |
| EPIC-06: Savings Tracker | 3 | 9 | Should Have |
| EPIC-07: Settings & Customization | 8 | 23 | Mixed |
| EPIC-08: Reports & Export | 2 | 11 | Should Have |
| EPIC-09: Budget Cycle Management | 3 | 11 | Must Have |
| **TOTAL** | **42** | **143** | - |

---

## Sprint Planning Recommendation

### Sprint 1 (Week 1-2): Foundation
- EPIC-01: Authentication (11 points)
- EPIC-09: Budget Cycle (11 points)
- EPIC-04: Category Management (12 points)
- **Total**: 34 points

### Sprint 2 (Week 3-4): Core Features
- EPIC-02: Home & Dashboard (28 points)
- **Total**: 28 points

### Sprint 3 (Week 5-6): Expense Management
- EPIC-03: Expense Management (29 points)
- **Total**: 29 points

### Sprint 4 (Week 7): Summary & Settings
- EPIC-05: Summary & Analytics (20 points)
- EPIC-07: Settings (partial - 10 points)
- **Total**: 30 points

### Sprint 5 (Week 8): Additional Features
- EPIC-07: Settings (remaining - 13 points)
- EPIC-06: Savings Tracker (9 points)
- EPIC-08: Reports & Export (11 points)
- **Total**: 33 points

### Sprint 6 (Week 9): Testing & Polish
- Bug fixes
- Performance optimization
- UI/UX refinements
- Final testing
- Documentation
