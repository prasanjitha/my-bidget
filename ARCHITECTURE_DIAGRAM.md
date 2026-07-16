# Architecture Diagram: Before vs After

## BEFORE: User-Specific Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      FIRESTORE DATABASE                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  users (collection)                                          │
│  ├── user1 (document)                                        │
│  │   ├── name: "John"                                        │
│  │   ├── currency: "LKR"                    ┐                │
│  │   ├── monthlyAllocation: 50000           │ User-Specific  │
│  │   ├── budgetCycleStartDay: 1             │ Settings       │
│  │   │                                       ┘                │
│  │   └── categories (subcollection)                          │
│  │       ├── cat1: {name: "Food", userId: "user1"}           │
│  │       └── cat2: {name: "Rent", userId: "user1"}           │
│  │                                                            │
│  ├── user2 (document)                                        │
│  │   ├── name: "Jane"                                        │
│  │   ├── currency: "LKR"                    ┐                │
│  │   ├── monthlyAllocation: 60000           │ Duplicated     │
│  │   ├── budgetCycleStartDay: 1             │ Settings       │
│  │   │                                       ┘                │
│  │   └── categories (subcollection)                          │
│  │       ├── cat3: {name: "Food", userId: "user2"}  ← Duplicate! │
│  │       └── cat4: {name: "Rent", userId: "user2"}  ← Duplicate! │
│  │                                                            │
│  └── user3 (document)                                        │
│      ├── name: "Bob"                                         │
│      ├── currency: "LKR"                     ┐                │
│      ├── monthlyAllocation: 45000            │ Duplicated     │
│      ├── budgetCycleStartDay: 1              │ Settings       │
│      │                                        ┘                │
│      └── categories (subcollection)                           │
│          ├── cat5: {name: "Food", userId: "user3"}  ← Duplicate! │
│          └── cat6: {name: "Rent", userId: "user3"}  ← Duplicate! │
│                                                               │
│  expenses (collection)                                       │
│  ├── exp1: {userId: "user1", categoryId: "cat1", ...}        │
│  ├── exp2: {userId: "user2", categoryId: "cat3", ...}        │
│  └── exp3: {userId: "user3", categoryId: "cat5", ...}        │
│                                                               │
└─────────────────────────────────────────────────────────────┘

Problems:
❌ Settings duplicated across all users
❌ Categories duplicated (same names, different IDs)
❌ Hard to manage global changes
❌ Inconsistent data between users
```

## AFTER: Shared Global Architecture ✨

```
┌─────────────────────────────────────────────────────────────┐
│                      FIRESTORE DATABASE                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  app_settings (collection) ← NEW! GLOBAL                     │
│  └── config (document)                                       │
│      ├── currency: "LKR"                     ┐               │
│      ├── monthlyAllocation: 50000            │ SHARED        │
│      └── budgetCycleStartDay: 1              │ BY ALL USERS  │
│                                               ┘               │
│                                                               │
│  categories (collection) ← NEW! GLOBAL                       │
│  ├── cat1 (document)                                         │
│  │   ├── name: "Food"                        ┐               │
│  │   ├── allocatedBudget: 20000              │ SHARED        │
│  │   └── isDefault: true                     │ BY ALL USERS  │
│  │                                            ┘               │
│  └── cat2 (document)                                         │
│      ├── name: "Rent"                                        │
│      ├── allocatedBudget: 15000                              │
│      └── isDefault: true                                     │
│                                                               │
│  users (collection)                                          │
│  ├── user1: {name: "John"}        ← Only user-specific data  │
│  ├── user2: {name: "Jane"}        ← No duplicate settings!   │
│  └── user3: {name: "Bob"}         ← No duplicate categories! │
│                                                               │
│  expenses (collection) ← UNCHANGED                           │
│  ├── exp1: {userId: "user1", categoryId: "cat1", ...}        │
│  ├── exp2: {userId: "user2", categoryId: "cat1", ...}  ← Same cat! │
│  └── exp3: {userId: "user3", categoryId: "cat2", ...}  ← Same cat! │
│                                                               │
└─────────────────────────────────────────────────────────────┘

Benefits:
✅ Single source of truth for settings
✅ No duplicate categories
✅ Easy to update globally
✅ All users always in sync
✅ Consistent data across application
```

## Data Flow Comparison

### BEFORE: Multiple Queries Per User
```
User Login
   ↓
Get user/{userId} → currency, monthlyAllocation, budgetCycleStartDay
   ↓
Get user/{userId}/categories → User's specific categories
   ↓
Get expenses → Filter by userId
   ↓
Display data
```

### AFTER: Shared Data + User-Specific Queries
```
User Login
   ↓
┌─────────────────────────────────────────────────────┐
│ Parallel Streams:                                   │
│ 1. Get app_settings/config → GLOBAL settings        │
│ 2. Get categories → GLOBAL categories               │
│ 3. Get user/{userId} → User name                    │
│ 4. Get expenses → Filter by userId                  │
└─────────────────────────────────────────────────────┘
   ↓
Display data (same settings & categories for all users)
```

## Code Usage Example

### Setting Monthly Budget

#### BEFORE:
```dart
// Each user has their own budget
await repository.setMonthlyBudget(
  userId: 'user1',  // User-specific
  amount: 50000,
  currency: 'LKR'
);
// user2 and user3 still have old budgets!
```

#### AFTER:
```dart
// Update affects ALL users instantly
await repository.setMonthlyBudget(
  amount: 50000,
  currency: 'LKR'
);
// All users see new budget immediately!
```

### Managing Categories

#### BEFORE:
```dart
// Create category for specific user
await repository.createCategory(
  userId: 'user1',       // User-specific
  categoryName: 'Food'
);
// Other users don't see this category
```

#### AFTER:
```dart
// Create category for ALL users
await repository.createCategory(
  categoryName: 'Food'
);
// All users see it immediately!
```

## Real-World Scenario

### Tourism Budget App Use Case

**Scenario**: A tourism company wants all employees to use the same budget structure.

#### BEFORE (User-Specific) ❌
- Admin sets budget cycle to start on 1st
- Admin creates "Transportation", "Meals", "Accommodation" categories
- **Problem**: Only admin's account has these settings
- Other employees have default settings
- **Solution**: Manually replicate settings for each user (error-prone!)

#### AFTER (Shared Global) ✅
- Admin updates global settings once
- Admin creates categories once
- **Result**: All employees instantly see:
  - Same budget cycle (1st of month)
  - Same categories (Transportation, Meals, Accommodation)
  - Same monthly allocation
- **Benefit**: Zero manual replication needed!

## Access Control

### Who Can Access What?

```
┌─────────────────────────────────────────────────────┐
│ GLOBAL DATA (All authenticated users)              │
├─────────────────────────────────────────────────────┤
│ ✓ app_settings/config   (read/write by all)        │
│ ✓ categories/*          (read/write by all)        │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ USER-SPECIFIC DATA (Only that user)                │
├─────────────────────────────────────────────────────┤
│ ✓ users/{userId}        (read/write by user only)  │
│ ✓ expenses/*            (read/write own only)      │
│ ✓ savings/*             (read/write own only)      │
└─────────────────────────────────────────────────────┘
```

## Summary

| Aspect | Before | After |
|--------|--------|-------|
| **Settings** | Per user | Global (shared) |
| **Categories** | Per user subcollection | Root collection (shared) |
| **Expenses** | Per user (unchanged) | Per user (unchanged) |
| **Data Duplication** | High | Minimal |
| **Consistency** | Hard to maintain | Automatic |
| **Scalability** | Poor (N users = N copies) | Excellent (1 copy for all) |
| **Updates** | Update each user | Update once |

---

**This refactoring transforms a multi-tenant isolated system into a shared collaborative system while maintaining user-specific transaction data.**
