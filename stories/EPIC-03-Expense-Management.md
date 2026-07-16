# Epic 3: Expense Management

**Epic ID**: EPIC-03  
**Epic Name**: Expense Management  
**Epic Owner**: Development Team  
**Business Value**: Core functionality for tracking daily expenses  
**Target Release**: v1.0

---

## Story EXP-001: Add New Expense

**Story ID**: EXP-001  
**Story Title**: Create New Expense Entry  
**Priority**: Must Have (P0)  
**Story Points**: 5

### User Story
**As a** user  
**I want to** add a new expense quickly  
**So that** I can track my spending in real-time

### Acceptance Criteria

**Given** the user taps the center FAB (+) button  
**When** the button is pressed  
**Then** a bottom sheet should slide up displaying the add expense form

**Given** the add expense bottom sheet is open  
**When** the form loads  
**Then** the following fields should be displayed:
- Title input (optional, placeholder: "Enter title (optional)")
- Category dropdown (required)
- Date picker (required, default: today)
- Amount input (required, numeric)
- ADD button (primary)
- Cancel button (secondary)

**Given** the user selects a category  
**When** the dropdown is tapped  
**Then** all categories from Firebase should be displayed  
**And** a "+" button should be visible to add new category

**Given** the user taps the "+" button in category dropdown  
**When** the button is pressed  
**Then** a popup should open to add a new category  
**And** after saving, the new category should appear in the dropdown

**Given** the user selects a date  
**When** the date picker is tapped  
**Then** a calendar picker should open  
**And** allow selection of past and future dates

**Given** the user enters an amount  
**When** the amount field is focused  
**Then** a numeric keyboard should appear  
**And** the currency symbol should be prefixed (based on app settings)

**Given** the user fills required fields and taps ADD  
**When** the button is pressed  
**Then** the expense should be saved to Firebase with:
- userId
- title (optional)
- categoryId
- amount
- date
- budgetCycle (calculated from date)
- createdAt timestamp
**And** the bottom sheet should close  
**And** navigate to Recent Expenses page  
**And** Home page values should update

**Given** required fields are missing  
**When** the ADD button is pressed  
**Then** validation errors should display  
**And** save should be prevented

**Given** the user taps Cancel  
**When** the button is pressed  
**Then** the bottom sheet should close  
**And** no data should be saved

### Technical Notes
- Firestore collection: `expenses`
- Budget cycle calculation: Use cycleStartDay from user settings
- Amount validation: Min: 0.01, Max: 999,999,999
- Date format: ISO 8601 timestamp
- Bottom sheet: Max height 80%, rounded corners 16dp
- Keyboard type: decimal for amount input

### Dependencies
- HOME-001 (Navigation with FAB)
- CAT-002 (Category dropdown data)
- CYC-002 (Budget cycle calculation)

### Definition of Done
- [x] Code implemented and reviewed
- [x] Bottom sheet opens from FAB
- [x] All fields display and function correctly
- [x] Category dropdown loads from Firebase
- [x] Add new category from dropdown works
- [x] Date picker functional
- [x] Amount input validation works
- [x] Expense saves to Firebase
- [x] Navigation to Recent Expenses works
- [x] Home page updates automatically
- [ ] Unit tests written
- [ ] Integration tests passed
- [ ] Widget tests for form validation

---

## Story EXP-002: View Recent Expenses

**Story ID**: EXP-002  
**Story Title**: Display Recent Expenses List  
**Priority**: Must Have (P0)  
**Story Points**: 5

### User Story
**As a** user  
**I want to** view my recent expenses  
**So that** I can see my spending history

### Acceptance Criteria

**Given** the user navigates to the Expenses tab  
**When** the page loads  
**Then** the "Recent Expenses" page should display with:
- Header: "Recent Expenses" (center)
- Search icon (top right)
- Category filter icon (right side)
- List of expenses grouped by date

**Given** expenses exist for the current budget cycle  
**When** the list is displayed  
**Then** expenses should be grouped by date (descending order)  
**And** each date group should show:
- Date header (e.g., "June 25, Thursday")
- Expense cards for that day

**Given** an expense card is displayed  
**When** the card is rendered  
**Then** it should show:
- Title (if provided)
- Category name with icon
- Amount with currency
- Edit icon
- Delete icon

**Given** no expenses exist  
**When** the page loads  
**Then** an empty state should display: "No expenses yet. Tap + to add one."

**Given** expenses are loading  
**When** data is being fetched  
**Then** a loading indicator should display

**Given** there's a network error  
**When** data fetch fails  
**Then** an error message should display: "Unable to load expenses. Please check your connection."

### Technical Notes
- Firestore query: Filter by userId + current budgetCycle + order by date DESC
- Group expenses by date in client-side logic
- Use StreamBuilder for real-time updates
- Pagination: Load 20 expenses at a time, lazy load more
- Date formatting: Use `intl` package
- Cache recent expenses locally for offline viewing

### Dependencies
- EXP-001 (Expenses must exist to display)
- CYC-002 (Budget cycle for filtering)

### Definition of Done
- [x] Code implemented and reviewed
- [x] Recent Expenses page displays correctly
- [x] Expenses grouped by date
- [x] All expense card fields display
- [x] Empty state handled
- [x] Loading state handled
- [x] Error state handled
- [x] Real-time updates work
- [ ] Pagination implemented
- [ ] Unit tests written
- [ ] Integration tests passed
- [ ] Performance tested with 100+ expenses

---

## Story EXP-003: Edit Expense

**Story ID**: EXP-003  
**Story Title**: Update Existing Expense  
**Priority**: Must Have (P0)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** edit an existing expense  
**So that** I can correct mistakes or update information

### Acceptance Criteria

**Given** the user is viewing an expense card  
**When** the edit icon is tapped  
**Then** the add/edit expense bottom sheet should open  
**And** all fields should be pre-filled with existing data

**Given** the edit bottom sheet is open  
**When** the user modifies any field  
**Then** the changes should be reflected in the form  
**And** validation should apply

**Given** the user saves changes  
**When** the ADD/UPDATE button is pressed  
**Then** the expense should be updated in Firebase  
**And** updatedAt timestamp should be set  
**And** the bottom sheet should close  
**And** the expense list should update immediately  
**And** Home page values should recalculate

**Given** the updated expense changes budget cycle  
**When** the date is changed to a different cycle  
**Then** the expense's budgetCycle field should update  
**And** both old and new cycle summaries should recalculate

**Given** validation errors occur  
**When** the user tries to save  
**Then** error messages should display  
**And** save should be prevented

### Technical Notes
- Reuse same bottom sheet component as add expense
- Pre-populate fields from existing expense document
- Update Firestore: `expenses/{expenseId}`
- Update budgetCycle if date changes
- Optimistic UI update for immediate feedback

### Dependencies
- EXP-001 (Add expense form component)
- EXP-002 (View expenses to edit)

### Definition of Done
- [x] Code implemented and reviewed
- [x] Edit icon opens pre-filled form
- [x] All fields editable
- [x] Validation works
- [x] Save updates Firebase
- [x] Budget cycle updates if needed
- [x] UI updates immediately
- [x] Home page recalculates
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story EXP-004: Delete Expense

**Story ID**: EXP-004  
**Story Title**: Remove Expense Entry  
**Priority**: Must Have (P0)  
**Story Points**: 2

### User Story
**As a** user  
**I want to** delete an expense  
**So that** I can remove incorrect or unwanted entries

### Acceptance Criteria

**Given** the user is viewing an expense card  
**When** the delete icon is tapped  
**Then** a confirmation dialog should appear with:
- Message: "Are you sure you want to delete this expense?"
- Cancel button
- Delete button (red/warning color)

**Given** the user confirms deletion  
**When** the Delete button is pressed  
**Then** the expense should be deleted from Firebase  
**And** the expense should be removed from the list immediately  
**And** Home page values should recalculate  
**And** a success message should display: "Expense deleted"

**Given** the user cancels deletion  
**When** the Cancel button is pressed  
**Then** the dialog should close  
**And** no changes should occur

**Given** deletion fails due to network error  
**When** the delete operation fails  
**Then** an error message should display  
**And** the expense should remain in the list

### Technical Notes
- Firestore operation: Delete document from `expenses` collection
- Trigger recalculation of totals after deletion
- Optimistic deletion: Remove from UI immediately, rollback on error
- Consider soft delete (isDeleted: true) for future recovery feature

### Dependencies
- EXP-002 (View expenses to delete)

### Definition of Done
- [x] Code implemented and reviewed
- [x] Delete icon triggers confirmation
- [x] Confirmation dialog displays
- [x] Delete removes from Firebase
- [x] UI updates immediately
- [x] Home page recalculates
- [x] Success message displays
- [x] Error handling works
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story EXP-005: Search Expenses

**Story ID**: EXP-005  
**Story Title**: Search Expenses by Title or Amount  
**Priority**: Should Have (P1)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** search for expenses by title or amount  
**So that** I can quickly find specific transactions

### Acceptance Criteria

**Given** the user is on Recent Expenses page  
**When** the search icon is tapped  
**Then** a search input field should appear at the top  
**And** keyboard should focus automatically

**Given** the search input is active  
**When** the user types a search query  
**Then** the expense list should filter in real-time  
**And** show only expenses matching the query

**Given** the search query matches expense titles  
**When** results are displayed  
**Then** expenses with matching titles should appear  
**And** search term should be highlighted

**Given** the search query is a number  
**When** results are displayed  
**Then** expenses with matching amounts should appear

**Given** no expenses match the search  
**When** the list is filtered  
**Then** an empty state should display: "No expenses found for '[query]'"

**Given** the user clears the search  
**When** the search input is cleared  
**Then** the full expense list should display again

### Technical Notes
- Client-side filtering for better performance
- Search fields: title and amount
- Case-insensitive matching
- Debounce search input: 300ms delay
- Highlight matching text in results
- Maintain date grouping in results

### Dependencies
- EXP-002 (Expense list to search)

### Definition of Done
- [x] Code implemented and reviewed
- [x] Search icon opens input field
- [x] Real-time filtering works
- [x] Title and amount search functional
- [x] Case-insensitive matching
- [x] Empty state handled
- [x] Clear search works
- [ ] Debouncing implemented
- [ ] Unit tests written
- [ ] Widget tests passed

---

## Story EXP-006: Filter Expenses by Category

**Story ID**: EXP-006  
**Story Title**: Category-based Expense Filtering  
**Priority**: Should Have (P1)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** filter expenses by category  
**So that** I can see spending for specific categories

### Acceptance Criteria

**Given** the user is on Recent Expenses page  
**When** the category filter icon is tapped  
**Then** a dropdown/bottom sheet should open showing all categories

**Given** the category list is displayed  
**When** categories are shown  
**Then** all categories from Firebase should appear  
**And** a "+" button should be visible to add new category  
**And** edit/delete icons for each category

**Given** the user selects a category  
**When** a category is tapped  
**Then** the expense list should filter to show only that category's expenses  
**And** the category name should appear as a filter chip

**Given** a filter is active  
**When** the filter chip is displayed  
**Then** an "X" icon should allow removing the filter  
**And** tapping X should show all expenses again

**Given** the user tries to delete a category with expenses in current cycle  
**When** delete is attempted  
**Then** an error should display: "Cannot delete category with expenses in current cycle"  
**And** deletion should be prevented

**Given** a category has no expenses in current cycle  
**When** delete is attempted  
**Then** a confirmation dialog should appear  
**And** on confirm, the category should be deleted  
**And** expenses from past cycles should retain the category reference

### Technical Notes
- Load categories from Firestore `categories` collection
- Client-side filtering by categoryId
- Check for expenses before allowing deletion
- Query: Count expenses where categoryId = X AND budgetCycle = current
- Soft delete option: isActive: false instead of hard delete

### Dependencies
- EXP-002 (Expense list to filter)
- CAT-004 (Delete category logic)

### Definition of Done
- [x] Code implemented and reviewed
- [x] Category filter icon opens dropdown
- [x] All categories display
- [x] Category selection filters expenses
- [x] Filter chip displays
- [x] Remove filter works
- [x] Delete prevention works for categories with expenses
- [x] Delete works for unused categories
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story EXP-007: View All Expenses by Budget Cycle

**Story ID**: EXP-007  
**Story Title**: Historical Expense View with Cycle Selector  
**Priority**: Should Have (P1)  
**Story Points**: 5

### User Story
**As a** user  
**I want to** view expenses from previous budget cycles  
**So that** I can review my historical spending

### Acceptance Criteria

**Given** the user is on Recent Expenses page  
**When** the "View All" FAB is tapped  
**Then** a new page should open with:
- Back button (top left)
- Budget cycle selector (dropdown)
- Expense list filtered by selected cycle

**Given** the View All page loads  
**When** the page is rendered  
**Then** the budget cycle dropdown should display  
**And** default to current cycle  
**And** show all past and current cycles

**Given** the user opens the cycle dropdown  
**When** the dropdown is tapped  
**Then** all budget cycles should be listed (descending order)  
**And** format: "June 10, 2026 - July 9, 2026"

**Given** the user selects a different cycle  
**When** a cycle is selected  
**Then** the expense list should update to show only that cycle's expenses  
**And** expenses should be grouped by date

**Given** expenses are displayed for a cycle  
**When** expense cards are shown  
**Then** each card should be expandable  
**And** clicking should show full expense details

**Given** the user deletes an expense from a past cycle  
**When** delete is confirmed  
**Then** the expense should be removed  
**And** that cycle's summary should recalculate

### Technical Notes
- Generate cycle list from user's budgetCycleStartDay and account creation date
- Firestore query: Filter by userId + selected budgetCycle
- Lazy load cycles: Initially show last 12 months
- Expandable cards: Use ExpansionTile
- Back button: Navigator.pop()

### Dependencies
- EXP-002 (Expense list component)
- CYC-003 (Budget cycle history)

### Definition of Done
- [x] Code implemented and reviewed
- [x] View All FAB navigates to new page
- [x] Back button works
- [x] Cycle dropdown displays all cycles
- [x] Cycle selection filters expenses
- [x] Expenses grouped by date
- [x] Expandable cards work
- [x] Delete from past cycles functional
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Story EXP-008: Add Category from Expense Form

**Story ID**: EXP-008  
**Story Title**: Quick Category Creation During Expense Entry  
**Priority**: Should Have (P1)  
**Story Points**: 3

### User Story
**As a** user  
**I want to** create a new category while adding an expense  
**So that** I don't have to navigate away from the expense form

### Acceptance Criteria

**Given** the user is filling the add expense form  
**When** the category dropdown is opened  
**Then** a "+" button should be visible next to the dropdown

**Given** the user taps the "+" button  
**When** the button is pressed  
**Then** a popup dialog should open with:
- Category name input field
- Save button
- Cancel button

**Given** the user enters a valid category name  
**When** the Save button is pressed  
**Then** the category should be saved to Firebase `categories` collection  
**And** the popup should close  
**And** the new category should appear in the dropdown  
**And** be auto-selected

**Given** the user enters a duplicate category name  
**When** Save is attempted  
**Then** an error should display: "Category already exists"  
**And** save should be prevented

**Given** the user enters an empty name  
**When** Save is attempted  
**Then** validation error should display: "Category name required"

**Given** the user taps Cancel  
**When** the button is pressed  
**Then** the popup should close  
**And** no category should be created

### Technical Notes
- Reuse category creation logic from HOME-004
- Firestore collection: `categories`
- Check for duplicates: case-insensitive query
- Auto-select: Set dropdown value to new categoryId
- Real-time update: Use StreamBuilder for category list

### Dependencies
- EXP-001 (Add expense form)
- CAT-001 (Create category logic)

### Definition of Done
- [x] Code implemented and reviewed
- [x] "+" button appears in dropdown
- [x] Popup opens on button press
- [x] Category name validation works
- [x] Duplicate check works
- [x] Save creates category in Firebase
- [x] New category appears in dropdown
- [x] Auto-selection works
- [x] Cancel closes without saving
- [ ] Unit tests written
- [ ] Integration tests passed

---

## Epic 3 Summary

**Total Stories**: 8  
**Total Story Points**: 29  
**Estimated Duration**: 5-6 days  
**Must Have Stories**: 5  
**Should Have Stories**: 3  
**Could Have Stories**: 0

### Epic Acceptance Criteria
- [x] All expense management stories completed
- [x] CRUD operations fully functional
- [x] Real-time updates work correctly
- [x] Search and filter features operational
- [x] Budget cycle filtering accurate
- [x] UI/UX smooth and intuitive
- [ ] All tests passing
- [x] Performance acceptable (list load < 2s)
