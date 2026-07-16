# Home Dashboard Architecture

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Interface                           │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              MainNavigationScreen                         │  │
│  │  ┌────────┬────────┬─────┬────────┬─────────┐           │  │
│  │  │  Home  │Expenses│ FAB │Summary │Settings │           │  │
│  │  └────────┴────────┴─────┴────────┴─────────┘           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                     │
│  ┌─────────────────────────▼──────────────────────────────┐   │
│  │              HomeScreen (Scrollable)                     │   │
│  │                                                           │   │
│  │  ┌─────────────────────────────────────────────┐        │   │
│  │  │  UserGreetingWidget                         │        │   │
│  │  │  "Hello [Name]"                             │        │   │
│  │  └─────────────────────────────────────────────┘        │   │
│  │  ┌─────────────────────────────────────────────┐        │   │
│  │  │  MonthlyBudgetCard                          │        │   │
│  │  │  - Month: June 2026                         │        │   │
│  │  │  - Budget: RS 170,000                       │        │   │
│  │  │  - [SET] button                             │        │   │
│  │  └─────────────────────────────────────────────┘        │   │
│  │  ┌─────────────────────────────────────────────┐        │   │
│  │  │  CategoryBudgetCard (Expandable)            │        │   │
│  │  │  ▼ Budget Categories                        │        │   │
│  │  │    - Food     [█████████▁▁] 85%  [SET]     │        │   │
│  │  │    - Rent     [████▁▁▁▁▁▁▁] 40%  [SET]     │        │   │
│  │  │    [+ Add New Category]                     │        │   │
│  │  └─────────────────────────────────────────────┘        │   │
│  │  ┌─────────────────────────────────────────────┐        │   │
│  │  │  TotalSpendCard                             │        │   │
│  │  │  Total Spend: RS 20,000                     │        │   │
│  │  └─────────────────────────────────────────────┘        │   │
│  │  ┌─────────────────────────────────────────────┐        │   │
│  │  │  RemainingBalanceCard                       │        │   │
│  │  │  Remaining: RS 150,000 (Green)              │        │   │
│  │  └─────────────────────────────────────────────┘        │   │
│  │  ┌─────────────────────────────────────────────┐        │   │
│  │  │  MonthlyOverviewGraph                       │        │   │
│  │  │  [Chart: Budget | Spent | Remaining]        │        │   │
│  │  └─────────────────────────────────────────────┘        │   │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            │
                            │ context.watch<HomeProvider>()
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      State Management Layer                       │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  HomeProvider                            │   │
│  │  (ChangeNotifier)                                        │   │
│  │                                                           │   │
│  │  State:                                                   │   │
│  │  - _userProfile: UserProfile?                            │   │
│  │  - _categories: List<Category>                           │   │
│  │  - _expenses: List<Expense>                              │   │
│  │                                                           │   │
│  │  Computed:                                                │   │
│  │  - totalSpent: double                                     │   │
│  │  - remainingBalance: double                               │   │
│  │  - currentBudgetCycle: String                             │   │
│  │                                                           │   │
│  │  Subscriptions:                                           │   │
│  │  - _profileSubscription: StreamSubscription              │   │
│  │  - _categoriesSubscription: StreamSubscription           │   │
│  │  - _expensesSubscription: StreamSubscription             │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                            │
                            │ Repository methods
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Repository Layer                             │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              HomeRepository                              │   │
│  │                                                           │   │
│  │  Methods:                                                 │   │
│  │  - getUserProfile(userId): Stream<UserProfile?>          │   │
│  │  - updateUserProfile(userId, data): Future<void>         │   │
│  │  - setMonthlyBudget(userId, amount, currency)            │   │
│  │  - getCategories(userId): Stream<List<Category>>         │   │
│  │  - createCategory(userId, name): Future<void>            │   │
│  │  - updateCategoryBudget(userId, catId, budget)           │   │
│  │  - getExpenses(userId, cycle): Stream<List<Expense>>     │   │
│  │  - getCategorySpent(userId, catId, cycle): double        │   │
│  │  - initializeDefaultCategories(userId)                   │   │
│  │  - getCurrentBudgetCycle(startDay): String               │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                            │
                            │ Firestore SDK
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Firebase Firestore                           │
│                                                                   │
│  Collections:                                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  users/{userId}                                          │   │
│  │  ├─ name: "John Doe"                                     │   │
│  │  ├─ currency: "LKR"                                      │   │
│  │  ├─ monthlyAllocation: 170000                            │   │
│  │  └─ budgetCycleStartDay: 1                               │   │
│  │                                                           │   │
│  │  users/{userId}/categories/{categoryId}                  │   │
│  │  ├─ name: "Food"                                         │   │
│  │  ├─ isDefault: true                                      │   │
│  │  └─ allocatedBudget: 50000                               │   │
│  │                                                           │   │
│  │  expenses/{expenseId}                                    │   │
│  │  ├─ userId: "abc123"                                     │   │
│  │  ├─ categoryId: "food_001"                               │   │
│  │  ├─ amount: 1500.00                                      │   │
│  │  ├─ description: "Lunch"                                 │   │
│  │  ├─ date: Timestamp                                      │   │
│  │  └─ budgetCycle: "2026-06"                               │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## State Update Flow

### When User Sets Monthly Budget:

```
1. User taps [SET] button
   │
   ▼
2. MonthlyBudgetCard shows dialog
   │
   ▼
3. User enters amount & currency
   │
   ▼
4. Dialog calls: homeProvider.setMonthlyBudget(amount, currency)
   │
   ▼
5. HomeProvider calls: repository.setMonthlyBudget(userId, amount, currency)
   │
   ▼
6. Repository writes to: Firestore users/{userId}
   │
   ▼
7. Firestore snapshot triggers
   │
   ▼
8. Stream updates: _profileSubscription receives new data
   │
   ▼
9. HomeProvider updates: _userProfile = newProfile
   │
   ▼
10. Provider calls: notifyListeners()
    │
    ▼
11. All widgets rebuild:
    - MonthlyBudgetCard shows new amount
    - RemainingBalanceCard recalculates
    - MonthlyOverviewGraph updates chart
```

---

## Real-Time Update Flow

### When Expense is Added (Future):

```
User adds expense → expenses collection updated
         │
         ▼
Firestore triggers snapshot
         │
         ▼
_expensesSubscription receives update
         │
         ▼
HomeProvider._expenses updated
         │
         ▼
notifyListeners() called
         │
         ├─▶ TotalSpendCard rebuilds (shows new total)
         │
         ├─▶ RemainingBalanceCard rebuilds (shows new balance)
         │
         ├─▶ MonthlyOverviewGraph rebuilds (updates chart)
         │
         └─▶ CategoryBudgetCard recalculates progress bars
```

---

## Component Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                      MainNavigationScreen                    │
│                                                               │
│  Current Index: _currentIndex                                │
│                                                               │
│  ┌─────────┬──────────┬──────────┬──────────┐              │
│  │ Home    │ Expenses │ Summary  │ Settings │              │
│  │ (idx 0) │ (idx 1)  │ (idx 2)  │ (idx 3)  │              │
│  └─────────┴──────────┴──────────┴──────────┘              │
│                                                               │
│  Center FAB: Opens Add Expense Bottom Sheet                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                       HomeScreen                             │
│                                                               │
│  Uses HomeProvider:                                          │
│  - context.watch<HomeProvider>()                             │
│  - Rebuilds when provider notifies                           │
│                                                               │
│  Child Widgets:                                              │
│  ├─ UserGreetingWidget                                       │
│  ├─ MonthlyBudgetCard                                        │
│  ├─ CategoryBudgetCard                                       │
│  ├─ TotalSpendCard                                           │
│  ├─ RemainingBalanceCard                                     │
│  └─ MonthlyOverviewGraph                                     │
└─────────────────────────────────────────────────────────────┘

Each Widget:
  ├─ Reads from HomeProvider
  ├─ Displays data
  └─ User actions → Provider methods → Firebase update → Stream → Rebuild
```

---

## Provider Lifecycle

```
1. App starts
   │
   ▼
2. MultiProvider creates HomeProvider instance
   │
   ▼
3. HomeScreen.initState()
   │
   ▼
4. homeProvider.initialize(userId)
   │
   ▼
5. Provider starts 3 stream subscriptions:
   ├─ Profile stream
   ├─ Categories stream
   └─ Expenses stream
   │
   ▼
6. Streams emit data as it changes
   │
   ▼
7. Provider updates internal state
   │
   ▼
8. Provider calls notifyListeners()
   │
   ▼
9. All watching widgets rebuild
   │
   ▼
10. User closes app
    │
    ▼
11. Provider.dispose() called
    │
    ▼
12. All stream subscriptions cancelled
```

---

## Data Model Relationships

```
UserProfile
├─ userId (PK)
├─ name
├─ currency
├─ monthlyAllocation
└─ budgetCycleStartDay

Category
├─ id (PK)
├─ userId (FK → UserProfile)
├─ name
├─ isDefault
└─ allocatedBudget

Expense
├─ id (PK)
├─ userId (FK → UserProfile)
├─ categoryId (FK → Category)
├─ amount
├─ description
├─ date
└─ budgetCycle (calculated from UserProfile.budgetCycleStartDay)

Computed Values:
- totalSpent = SUM(Expense.amount) WHERE budgetCycle = current
- remainingBalance = UserProfile.monthlyAllocation - totalSpent
- categorySpent = SUM(Expense.amount) WHERE categoryId = X AND budgetCycle = current
- categoryProgress = categorySpent / Category.allocatedBudget
```

---

## Error Handling

```
User Action
    │
    ▼
UI Validation
    ├─ Pass → Continue
    └─ Fail → Show SnackBar (red)
         └─ Stay on same screen
    │
    ▼
Provider Method
    │
    ▼
Repository Call
    ├─ Success
    │   ├─ Firebase writes
    │   ├─ Stream updates automatically
    │   └─ Show SnackBar (green)
    │
    └─ Error (Exception)
        ├─ Caught in UI layer
        ├─ Show SnackBar (red) with error message
        └─ State unchanged (Firebase didn't update)
```

---

## Performance Optimizations

### Current:
- ✅ Stream subscriptions (not polling)
- ✅ Provider pattern (selective rebuilds)
- ✅ StreamBuilder caching
- ✅ Proper dispose (prevent memory leaks)

### Future:
- 🔄 Add pagination for large category lists
- 🔄 Cache category spending calculations
- 🔄 Debounce search/filter inputs
- 🔄 Firestore indexes for complex queries
- 🔄 Offline support with local caching

---

## Security Model

```
Firebase Security Rules (to be configured):

users/{userId}:
  - read: if request.auth.uid == userId
  - write: if request.auth.uid == userId

users/{userId}/categories/{categoryId}:
  - read: if request.auth.uid == userId
  - write: if request.auth.uid == userId

expenses/{expenseId}:
  - read: if request.auth.uid == resource.data.userId
  - write: if request.auth.uid == request.resource.data.userId
```

---

## Testing Strategy

### Unit Tests:
- ✅ Model serialization/deserialization
- ✅ Repository methods
- ✅ Provider state management
- ✅ Budget cycle calculations

### Widget Tests:
- ✅ Each card widget renders correctly
- ✅ User interactions trigger correct actions
- ✅ Dialog forms validate input
- ✅ Navigation switches screens

### Integration Tests:
- ✅ End-to-end user flows
- ✅ Firebase CRUD operations
- ✅ Real-time updates
- ✅ Multi-screen navigation

---

## Scalability Considerations

### Current Limits:
- Categories: No hard limit (UI pagination at 20+ recommended)
- Expenses: Firestore limit (1M documents per collection)
- Budget cycles: Infinite (stored as string "YYYY-MM")

### Future Scaling:
- Add pagination for expense lists
- Archive old budget cycles
- Implement search indexes
- Consider sharding for high-volume users

---

This architecture provides:
- 🎯 Clear separation of concerns
- 🔄 Real-time reactivity
- 🧪 Testable components
- 📈 Scalable structure
- 🛡️ Type safety
- 🎨 Reusable widgets
