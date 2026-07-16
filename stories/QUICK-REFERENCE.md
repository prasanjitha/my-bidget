# Bidget User Stories - Quick Reference

**Quick navigation to all stories by ID**

---

## Epic 1: Authentication & Security (11 pts)

| Story ID | Title | Priority | Points |
|----------|-------|----------|--------|
| AUTH-001 | Biometric Authentication Setup | P0 | 5 |
| AUTH-002 | Biometric Login | P0 | 3 |
| AUTH-003 | Session Management | P0 | 3 |

[View Epic 1 Details →](./EPIC-01-Authentication.md)

---

## Epic 2: Home & Dashboard (28 pts)

| Story ID | Title | Priority | Points |
|----------|-------|----------|--------|
| HOME-001 | Bottom Navigation Bar | P0 | 3 |
| HOME-002 | User Greeting Display | P1 | 2 |
| HOME-003 | Monthly Budget Allocation | P0 | 5 |
| HOME-004 | Category Budget Allocation | P0 | 8 |
| HOME-005 | Total Spend Card | P0 | 3 |
| HOME-006 | Remaining Balance Card | P0 | 2 |
| HOME-007 | Monthly Overview Graph | P1 | 5 |

[View Epic 2 Details →](./EPIC-02-Home-Dashboard.md)

---

## Epic 3: Expense Management (29 pts)

| Story ID | Title | Priority | Points |
|----------|-------|----------|--------|
| EXP-001 | Add New Expense | P0 | 5 |
| EXP-002 | View Recent Expenses | P0 | 5 |
| EXP-003 | Edit Expense | P0 | 3 |
| EXP-004 | Delete Expense | P0 | 2 |
| EXP-005 | Search Expenses | P1 | 3 |
| EXP-006 | Filter by Category | P1 | 3 |
| EXP-007 | View All by Cycle | P1 | 5 |
| EXP-008 | Add Category from Form | P1 | 3 |

[View Epic 3 Details →](./EPIC-03-Expense-Management.md)

---

## Epic 4: Category Management (12 pts)

| Story ID | Title | Priority | Points |
|----------|-------|----------|--------|
| CAT-001 | Create New Category | P0 | 3 |
| CAT-002 | List All Categories | P0 | 2 |
| CAT-003 | Edit Category | P1 | 2 |
| CAT-004 | Delete Category | P1 | 3 |
| CAT-005 | Initialize Default Categories | P0 | 2 |

[View Epic 4 Details →](./EPIC-04-Category-Management.md)

---

## Epic 5: Summary & Analytics (20 pts)

| Story ID | Title | Priority | Points |
|----------|-------|----------|--------|
| SUM-001 | Daily Summary Tab | P0 | 5 |
| SUM-002 | Monthly Summary Tab | P0 | 5 |
| SUM-003 | Budget Status Indicator | P1 | 2 |
| SUM-004 | Category Spending Progress | P1 | 3 |
| SUM-005 | Expense Details Expansion | P2 | 3 |
| SUM-006 | Summary Data Refresh | P0 | 2 |

[View Epic 5 Details →](./EPIC-05-Summary-Analytics.md)

---

## Epic 6: Savings Tracker (9 pts)

| Story ID | Title | Priority | Points |
|----------|-------|----------|--------|
| SAV-001 | View Savings Summary | P1 | 3 |
| SAV-002 | Add New Savings Entry | P1 | 3 |
| SAV-003 | Edit and Delete Savings | P1 | 3 |

[View Epic 6 Details →](./EPIC-06-Savings-Tracker.md)

---

## Epic 7: Settings & Customization (23 pts)

| Story ID | Title | Priority | Points |
|----------|-------|----------|--------|
| SET-001 | Settings Page Layout | P0 | 2 |
| SET-002 | Dark Mode Toggle | P1 | 5 |
| SET-003 | Currency Selection | P0 | 3 |
| SET-004 | Set Monthly Allocation | P1 | 2 |
| SET-005 | Change Profile Name | P1 | 2 |
| SET-006 | Budget Cycle Configuration | P0 | 5 |
| SET-007 | Logout | P0 | 2 |
| SET-008 | Settings Persistence | P0 | 2 |

[View Epic 7 Details →](./EPIC-07-Settings.md)

---

## Epic 8: Reports & Export (11 pts)

| Story ID | Title | Priority | Points |
|----------|-------|----------|--------|
| REP-001 | Generate PDF Report | P1 | 8 |
| REP-002 | Share PDF Report | P1 | 3 |

[View Epic 8 Details →](./EPIC-08-Reports-Export.md)

---

## Epic 9: Budget Cycle Management (11 pts)

| Story ID | Title | Priority | Points |
|----------|-------|----------|--------|
| CYC-001 | Budget Cycle Calculation Logic | P0 | 5 |
| CYC-002 | Apply Budget Cycle to Expenses | P0 | 3 |
| CYC-003 | Budget Cycle History | P1 | 3 |

[View Epic 9 Details →](./EPIC-09-Budget-Cycle.md)

---

## Priority Summary

### P0 (Must Have) - 29 stories, 103 points
- AUTH-001, AUTH-002, AUTH-003
- HOME-001, HOME-003, HOME-004, HOME-005, HOME-006
- EXP-001, EXP-002, EXP-003, EXP-004
- CAT-001, CAT-002, CAT-005
- SUM-001, SUM-002, SUM-006
- SET-001, SET-003, SET-006, SET-007, SET-008
- CYC-001, CYC-002

### P1 (Should Have) - 12 stories, 37 points
- HOME-002, HOME-007
- EXP-005, EXP-006, EXP-007, EXP-008
- CAT-003, CAT-004
- SUM-003, SUM-004
- SAV-001, SAV-002, SAV-003
- SET-002, SET-004, SET-005
- REP-001, REP-002
- CYC-003

### P2 (Could Have) - 1 story, 3 points
- SUM-005

---

## Development Timeline

### Sprint 1 (Week 1-2): Foundation - 34 points
**Focus**: Authentication, Budget Cycle, Categories, Basic Settings

**Stories**: AUTH-001, AUTH-002, AUTH-003, CYC-001, CYC-002, CAT-001, CAT-002, CAT-005, SET-001, SET-003, SET-008

### Sprint 2 (Week 3-4): Home Dashboard - 28 points
**Focus**: Complete home page with all cards and navigation

**Stories**: HOME-001, HOME-002, HOME-003, HOME-004, HOME-005, HOME-006, HOME-007

### Sprint 3 (Week 5-6): Expense Management - 29 points
**Focus**: Full expense CRUD with search and filters

**Stories**: EXP-001, EXP-002, EXP-003, EXP-004, EXP-005, EXP-006, EXP-007, EXP-008, CAT-003, CAT-004

### Sprint 4 (Week 7): Summary & Analytics - 30 points
**Focus**: Daily/monthly summaries with visual indicators

**Stories**: SUM-001, SUM-002, SUM-003, SUM-004, SUM-005, SUM-006, SET-006, CYC-003

### Sprint 5 (Week 8): Additional Features - 32 points
**Focus**: Savings, complete settings, PDF reports

**Stories**: SAV-001, SAV-002, SAV-003, SET-002, SET-004, SET-005, SET-007, REP-001, REP-002

### Sprint 6 (Week 9): Testing & Polish
**Focus**: Quality assurance and production readiness

---

## Story Dependencies (Critical Path)

```
AUTH-001 → AUTH-002 → AUTH-003
    ↓
CYC-001 → CYC-002 → CYC-003
    ↓
CAT-001 → CAT-002 → CAT-005
    ↓
HOME-001 → HOME-003 → HOME-005 → HOME-006
    ↓
EXP-001 → EXP-002 → EXP-003
    ↓
SUM-001 → SUM-002
```

---

## Quick Search by Feature

### Authentication
- Biometric login: AUTH-001, AUTH-002
- Session: AUTH-003
- Logout: SET-007

### Budget Management
- Set budget: HOME-003, SET-004
- Budget cycle: CYC-001, CYC-002, CYC-003, SET-006
- Category budgets: HOME-004

### Expense Tracking
- Add/Edit/Delete: EXP-001, EXP-003, EXP-004
- View/Search/Filter: EXP-002, EXP-005, EXP-006, EXP-007

### Categories
- CRUD operations: CAT-001, CAT-002, CAT-003, CAT-004, CAT-005
- Quick add: EXP-008

### Summaries
- Daily: SUM-001
- Monthly: SUM-002
- Visual indicators: SUM-003, SUM-004, HOME-007
- Real-time updates: SUM-006

### Savings
- All operations: SAV-001, SAV-002, SAV-003

### Settings
- Page structure: SET-001
- Theme: SET-002
- Currency: SET-003
- Profile: SET-005
- Persistence: SET-008

### Reports
- PDF: REP-001, REP-002

---

## Contact & Support

For questions about user stories:
- Review [STORY-SUMMARY.md](./STORY-SUMMARY.md) for comprehensive overview
- Check individual epic files for detailed acceptance criteria
- Refer to [PRD](../docs/PRD.md) for product requirements

---

**Last Updated**: July 15, 2026  
**Total Stories**: 42  
**Total Story Points**: 143
