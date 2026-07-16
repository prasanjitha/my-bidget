# Home Feature Module

This module implements the Home & Dashboard functionality (EPIC-02) for the Bidget app.

## Structure

```
home/
├── data/
│   └── repositories/
│       └── home_repository.dart          # Firebase data access layer
├── domain/
│   └── models/
│       ├── category.dart                 # Category model
│       ├── expense.dart                  # Expense model
│       └── user_profile.dart             # User profile model
└── presentation/
    ├── providers/
    │   └── home_provider.dart            # State management
    ├── screens/
    │   ├── expenses_screen.dart          # Expenses tab (placeholder)
    │   ├── home_screen.dart              # Home tab (main dashboard)
    │   ├── main_navigation_screen.dart   # Bottom navigation container
    │   ├── settings_screen.dart          # Settings tab (placeholder)
    │   └── summary_screen.dart           # Summary tab (placeholder)
    └── widgets/
        ├── category_budget_card.dart     # Category breakdown widget
        ├── monthly_budget_card.dart      # Budget allocation widget
        ├── monthly_overview_graph.dart   # Bar chart visualization
        ├── remaining_balance_card.dart   # Balance display widget
        ├── total_spend_card.dart         # Total spending widget
        └── user_greeting_widget.dart     # Greeting header widget
```

## Features

### Implemented (EPIC-02)
- ✅ **Bottom Navigation**: 5-tab navigation with center FAB
- ✅ **User Greeting**: Personalized welcome message
- ✅ **Monthly Budget**: Set and view monthly allocation
- ✅ **Category Management**: Create categories, set budgets, track spending
- ✅ **Spending Tracking**: Real-time total spend calculation
- ✅ **Balance Display**: Remaining balance with color coding
- ✅ **Visual Analytics**: Interactive bar chart

### Pending (Future Epics)
- ⚠️ Expense CRUD operations
- ⚠️ Settings implementation
- ⚠️ Summary/Analytics

## Usage

### Initialize Provider

In `main.dart`:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => HomeProvider()),
    // ... other providers
  ],
  child: MaterialApp(...),
)
```

### Initialize Home Data

In `home_screen.dart`:
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final userId = context.read<AuthProvider>().userId;
    if (userId != null) {
      context.read<HomeProvider>().initialize(userId);
    }
  });
}
```

### Use in Widgets

```dart
// Watch for changes
final homeProvider = context.watch<HomeProvider>();

// Access data
final budget = homeProvider.userProfile?.monthlyAllocation ?? 0.0;
final spent = homeProvider.totalSpent;
final remaining = homeProvider.remainingBalance;

// Perform actions
await homeProvider.setMonthlyBudget(170000, 'LKR');
await homeProvider.createCategory('Transportation');
await homeProvider.updateCategoryBudget(categoryId, 50000);
```

## Data Flow

```
User Action → Widget → Provider → Repository → Firebase
                ↓         ↑          ↑
              Stream ← notifyListeners() ← Stream Update
```

1. User interacts with widget
2. Widget calls provider method
3. Provider calls repository method
4. Repository writes to Firebase
5. Firebase triggers stream update
6. Provider receives update via stream
7. Provider calls `notifyListeners()`
8. All watching widgets rebuild

## Models

### UserProfile
```dart
UserProfile(
  userId: 'abc123',
  name: 'John Doe',
  currency: 'LKR',
  monthlyAllocation: 170000.0,
  budgetCycleStartDay: 1,
)
```

### Category
```dart
Category(
  id: 'cat_001',
  name: 'Food',
  isDefault: true,
  allocatedBudget: 50000.0,
)
```

### Expense
```dart
Expense(
  id: 'exp_001',
  userId: 'abc123',
  categoryId: 'cat_001',
  amount: 1500.0,
  description: 'Lunch at cafe',
  date: DateTime.now(),
  budgetCycle: '2026-06',
)
```

## Repository Methods

### User Profile
- `getUserProfile(userId)` → Stream<UserProfile?>
- `updateUserProfile(userId, data)` → Future<void>
- `setMonthlyBudget(userId, amount, currency)` → Future<void>

### Categories
- `getCategories(userId)` → Stream<List<Category>>
- `createCategory(userId, name)` → Future<void>
- `updateCategoryBudget(userId, categoryId, budget)` → Future<void>
- `initializeDefaultCategories(userId)` → Future<void>

### Expenses
- `getExpenses(userId, budgetCycle)` → Stream<List<Expense>>
- `getCategorySpent(userId, categoryId, cycle)` → Future<double>

### Utilities
- `getCurrentBudgetCycle(startDay)` → String

## Provider Properties

### State
- `userProfile`: UserProfile? - Current user profile
- `categories`: List<Category> - User's categories
- `expenses`: List<Expense> - Current cycle expenses

### Computed
- `totalSpent`: double - Sum of all expenses
- `remainingBalance`: double - Budget - Spent
- `currentBudgetCycle`: String - Current cycle (YYYY-MM)

## Widgets

### UserGreetingWidget
Displays personalized greeting. Auto-truncates long names.

### MonthlyBudgetCard
Shows monthly budget. Click SET to edit. Validates 0-999,999,999.

### CategoryBudgetCard
Expandable list. Color-coded progress bars. Add/edit categories.

### TotalSpendCard
Current cycle total. Red text when over budget.

### RemainingBalanceCard
Remaining balance. Green (positive) / Red (negative).

### MonthlyOverviewGraph
Bar chart: Budget, Spent, Remaining. Interactive tooltips.

## Firestore Structure

```
users/{userId}
  - name: String
  - currency: String
  - monthlyAllocation: Number
  - budgetCycleStartDay: Number
  
  categories/{categoryId}
    - name: String
    - isDefault: Boolean
    - allocatedBudget: Number

expenses/{expenseId}
  - userId: String
  - categoryId: String
  - amount: Number
  - description: String
  - date: Timestamp
  - budgetCycle: String
```

## Dependencies

```yaml
dependencies:
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
  provider: ^6.1.2
  intl: ^0.20.1
  fl_chart: ^0.69.0
```

## Testing

### Unit Tests
```dart
// Test model serialization
test('UserProfile fromMap/toMap', () { ... });

// Test repository methods
test('setMonthlyBudget updates Firestore', () { ... });

// Test provider logic
test('totalSpent calculates correctly', () { ... });
```

### Widget Tests
```dart
testWidgets('MonthlyBudgetCard displays budget', (tester) async {
  // Arrange
  final homeProvider = MockHomeProvider();
  when(homeProvider.userProfile).thenReturn(mockProfile);
  
  // Act
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: homeProvider,
      child: MaterialApp(home: MonthlyBudgetCard()),
    ),
  );
  
  // Assert
  expect(find.text('RS 170,000.00'), findsOneWidget);
});
```

## Error Handling

All repository methods can throw exceptions. Handle in UI:

```dart
try {
  await homeProvider.createCategory(name);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Category created')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(e.toString()),
      backgroundColor: Colors.red,
    ),
  );
}
```

## Performance

### Optimizations
- Stream-based updates (no polling)
- Selective rebuilds with Provider
- Proper disposal of subscriptions
- Number formatting cached in variables

### Considerations
- Categories: Paginate if > 20
- Expenses: Query filtered by budget cycle
- Category spending: Calculated on-demand (consider caching)

## Future Enhancements

1. **Expense Management** (EPIC-03)
   - Add/Edit/Delete expenses
   - Expense list with filters
   - Search functionality

2. **Settings** (EPIC-04)
   - Profile editing
   - Budget cycle configuration
   - Theme settings
   - Notification preferences

3. **Analytics** (EPIC-05)
   - Spending trends
   - Category comparisons
   - Export reports
   - Predictions

4. **Advanced Features**
   - Multi-currency conversion
   - Recurring expenses
   - Budget templates
   - Shared budgets
   - Offline support

## Contributing

When adding features to this module:

1. Follow the existing architecture (data/domain/presentation)
2. Add models to `domain/models/`
3. Add data access to `home_repository.dart`
4. Update `HomeProvider` if new state needed
5. Create reusable widgets in `presentation/widgets/`
6. Write tests for new functionality
7. Update this README

## License

Part of the Bidget application.



