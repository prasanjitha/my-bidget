# Epic 6: Savings Tracker

**Epic ID**: EPIC-06  
**Epic Name**: Savings Tracker  
**Epic Owner**: Development Team  
**Business Value**: Track and monitor personal savings separately from budget  
**Target Release**: v1.0

---

## Story SAV-001: View Savings Summary

**Story ID**: SAV-001  
**Story Title**: Display Total and Monthly Savings  
**Priority**: Should Have (P1)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** view my total savings and monthly breakdown  
**So that** I can track my savings progress

### Acceptance Criteria

**Given** the user is on the Summary page  
**When** the "Savings" FAB (bottom right) is tapped  
**Then** a new Savings page should open displaying:
- Back button (top left)
- Header: "Savings" (center)
- Total Savings card at the top
- Monthly savings list below
- Add Savings FAB (bottom right)

**Given** the Total Savings card is displayed  
**When** the card renders  
**Then** it should show:
- Title: "Total Savings"
- Total amount: Sum of all savings (e.g., "RS 80,000")
- Currency based on app settings

**Given** the user has saved money in multiple months  
**When** the monthly savings list is displayed  
**Then** each month should appear as a card showing:
- Month name (e.g., "June 2026")
- Savings amount (e.g., "RS 20,000")
**And** sorted in descending order (most recent first)

**Given** no savings entries exist  
**When** the page loads  
**Then** an empty state should display: "No savings yet. Tap + to add."

**Given** savings data is loading  
**When** the page is fetching data  
**Then** a loading indicator should display

### Technical Notes
- Firestore collection: `savings`
- Query: Filter by userId, order by month DESC
- Total calculation: Sum all savings amounts
- Month format: "YYYY-MM" (e.g., "2026-06")
- Display format: "June 2026"
- Use StreamBuilder for real-time updates

### Dependencies
- HOME-001 (Navigation structure)
- SUM-002 (Summary page for FAB placement)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Savings FAB navigates to new page
- [ ] Total Savings card displays correctly
- [ ] Monthly list shows all entries
- [ ] Total calculation accurate
- [ ] Sorting correct (descending)
- [ ] Empty state handled
- [ ] Loading state handled
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story SAV-002: Add New Savings Entry

**Story ID**: SAV-002  
**Story Title**: Record Monthly Savings  
**Priority**: Should Have (P1)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** add a savings entry for a specific month  
**So that** I can track my savings over time

### Acceptance Criteria

**Given** the user is on the Savings page  
**When** the "Add Savings" FAB is tapped  
**Then** a popup dialog should open with:
- Header: "Add Savings"
- Month dropdown (select month)
- Amount input field
- Save button
- Cancel button

**Given** the month dropdown is opened  
**When** the dropdown is tapped  
**Then** it should display:
- Current month
- Past 12 months
- Future 3 months
**And** format: "June 2026"

**Given** the user selects a month and enters an amount  
**When** the Save button is pressed  
**Then** the savings entry should be saved to Firebase with:
- userId
- month (string: "2026-06")
- amount (number)
- currency (string from app settings)
- createdAt timestamp
- updatedAt timestamp
**And** the popup should close  
**And** the savings list should update  
**And** total savings should recalculate

**Given** an entry already exists for the selected month  
**When** Save is attempted  
**Then** an error should display: "Savings entry already exists for this month. Edit the existing entry instead."  
**And** save should be prevented

**Given** the amount is invalid (negative, zero, or not a number)  
**When** Save is attempted  
**Then** a validation error should display  
**And** save should be prevented

**Given** the user taps Cancel  
**When** the button is pressed  
**Then** the popup should close  
**And** no data should be saved

### Technical Notes
- Firestore collection: `savings`
- Duplicate check: Query where userId = X AND month = Y
- Amount validation: Min: 0.01, Max: 999,999,999
- Month picker: Use dropdown with pre-generated month list
- Currency: Fetch from SharedPreferences or user settings
- Number format: Decimal input keyboard

### Dependencies
- SAV-001 (Savings page structure)
- SET-003 (Currency setting)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Add Savings FAB opens popup
- [ ] Month dropdown displays correctly
- [ ] Amount input validation works
- [ ] Duplicate prevention works
- [ ] Save creates entry in Firebase
- [ ] List updates automatically
- [ ] Total recalculates
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story SAV-003: Edit and Delete Savings Entry

**Story ID**: SAV-003  
**Story Title**: Modify Existing Savings Records  
**Priority**: Should Have (P1)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** edit or delete savings entries  
**So that** I can correct mistakes or remove incorrect data

### Acceptance Criteria

**Given** a savings card is displayed  
**When** the card is long-pressed or tapped  
**Then** a context menu or action sheet should appear with options:
- Edit
- Delete

**Given** the user selects "Edit"  
**When** the option is chosen  
**Then** the add/edit savings popup should open  
**And** fields should be pre-filled with existing data:
- Month (read-only)
- Amount (editable)

**Given** the user modifies the amount and saves  
**When** the Save button is pressed  
**Then** the savings entry should be updated in Firebase  
**And** updatedAt timestamp should be set  
**And** the list should update  
**And** total savings should recalculate

**Given** the user selects "Delete"  
**When** the option is chosen  
**Then** a confirmation dialog should appear:
- Message: "Are you sure you want to delete savings for [Month]?"
- Cancel button
- Delete button (red)

**Given** the user confirms deletion  
**When** the Delete button is pressed  
**Then** the savings entry should be deleted from Firebase  
**And** the card should be removed from the list  
**And** total savings should recalculate  
**And** a success message should display: "Savings entry deleted"

**Given** the user cancels deletion  
**When** the Cancel button is pressed  
**Then** the dialog should close  
**And** no changes should occur

### Technical Notes
- Update Firestore: `savings/{savingId}`
- Delete Firestore: Remove document
- Month field: Read-only during edit (use disabled TextField)
- Optimistic UI: Update immediately, rollback on error
- Confirmation dialog: AlertDialog widget

### Dependencies
- SAV-002 (Savings entry must exist to edit/delete)

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Long-press or tap shows action menu
- [ ] Edit opens pre-filled popup
- [ ] Month is read-only during edit
- [ ] Save updates Firebase
- [ ] Delete shows confirmation
- [ ] Delete removes from Firebase
- [ ] UI updates immediately
- [ ] Total recalculates correctly
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Epic 6 Summary

**Total Stories**: 3  
**Total Story Points**: 9  
**Estimated Duration**: 2 days  
**Must Have Stories**: 0  
**Should Have Stories**: 3  
**Could Have Stories**: 0

### Epic Acceptance Criteria
- [ ] All savings stories completed
- [ ] CRUD operations functional
- [ ] Total savings calculation accurate
- [ ] Real-time updates working
- [ ] UI/UX intuitive
- [ ] All tests passing
