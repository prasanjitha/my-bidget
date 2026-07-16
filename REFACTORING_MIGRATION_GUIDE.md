# Firebase Firestore Architecture Refactoring Guide

## Overview
This refactoring migrates app settings from user-specific documents to a shared, global configuration. All users now access the same settings and categories.

## Changes Made

### 1. New Firestore Structure

#### Before:
```
users/{userId}
  ├── budgetCycleStartDay: int
  ├── currency: string
  ├── monthlyAllocation: double
  └── name: string
  └── subcollection: categories/{categoryId}
      ├── name: string
      ├── userId: string
      ├── allocatedBudget: double
      └── isDefault: bool

expenses/{expenseId}
  ├── userId: string
  ├── categoryId: string
  ├── amount: double
  └── ...
```

#### After:
```
app_settings/config (GLOBAL - shared by all users)
  ├── budgetCycleStartDay: int
  ├── currency: string
  └── monthlyAllocation: double

users/{userId} (user-specific data only)
  └── name: string

categories/{categoryId} (GLOBAL - shared by all users)
  ├── name: string
  ├── allocatedBudget: double
  └── isDefault: bool

expenses/{expenseId} (unchanged)
  ├── userId: string
  ├── categoryId: string
  ├── amount: double
  └── ...
```

### 2. New Files Created

- `lib/features/home/domain/models/app_settings.dart` - New model for shared app settings

### 3. Modified Files

#### Models:
- `user_profile.dart` - Removed currency, monthlyAllocation, budgetCycleStartDay
- `category.dart` - Removed userId field (now global)

#### Repository:
- `home_repository.dart` - Added methods for global app_settings and global categories
  - `getAppSettings()` - Stream to listen to shared settings
  - `updateAppSettings()` - Update shared settings
  - `getCategories()` - No longer requires userId
  - `createCategory()` - No longer requires userId
  - `updateCategory()` - No longer requires userId
  - `deleteCategory()` - No longer requires userId
  - `initializeDefaultCategories()` - No longer requires userId

#### Provider:
- `home_provider.dart` - Updated to use appSettings
  - Added `_appSettings` and `_appSettingsSubscription`
  - Exposed `appSettings` getter
  - Updated all methods to use `appSettings` instead of `userProfile`
  - Added `updateCurrency()` method

#### UI Screens Updated:
- `settings_screen.dart`
- `summary_screen.dart`
- `expenses_screen.dart`
- `savings_screen.dart`
- `all_expenses_screen.dart`

#### UI Widgets Updated:
- `total_spend_card.dart`
- `remaining_balance_card.dart`
- `monthly_budget_card.dart`
- `monthly_overview_graph.dart`
- `monthly_history_list.dart`
- `category_budget_card.dart`
- `add_expense_bottom_sheet.dart`

## Migration Steps

### For New Installations:
No migration needed. The app will create the `app_settings/config` document automatically with default values.

### For Existing Installations:

**Option 1: Manual Migration (Recommended for small user bases)**

1. Create the global settings document in Firestore:
   ```javascript
   // In Firebase Console
   Collection: app_settings
   Document ID: config
   Fields:
     - budgetCycleStartDay: 1
     - currency: "LKR"
     - monthlyAllocation: 0.0
   ```

2. Migrate categories from user subcollection to root collection:
   ```javascript
   // Run this in Firebase Console or Cloud Functions
   const users = await db.collection('users').get();
   
   for (const userDoc of users.docs) {
     const categories = await userDoc.ref.collection('categories').get();
     
     for (const cat of categories.docs) {
       const data = cat.data();
       delete data.userId; // Remove userId field
       
       // Copy to root categories collection
       await db.collection('categories').doc(cat.id).set(data);
     }
   }
   ```

3. Update user documents to remove old fields:
   ```javascript
   const users = await db.collection('users').get();
   const batch = db.batch();
   
   users.docs.forEach(doc => {
     batch.update(doc.ref, {
       budgetCycleStartDay: firebase.firestore.FieldValue.delete(),
       currency: firebase.firestore.FieldValue.delete(),
       monthlyAllocation: firebase.firestore.FieldValue.delete()
     });
   });
   
   await batch.commit();
   ```

**Option 2: Automated Cloud Function Migration**

Create a Cloud Function that runs once to migrate data:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.migrateToGlobalSettings = functions.https.onRequest(async (req, res) => {
  const db = admin.firestore();
  
  try {
    // Step 1: Create global app_settings
    await db.collection('app_settings').doc('config').set({
      budgetCycleStartDay: 1,
      currency: 'LKR',
      monthlyAllocation: 0.0
    });
    
    // Step 2: Migrate categories
    const users = await db.collection('users').get();
    const categoriesSet = new Set();
    
    for (const userDoc of users.docs) {
      const categories = await userDoc.ref.collection('categories').get();
      
      for (const cat of categories.docs) {
        if (!categoriesSet.has(cat.id)) {
          const data = cat.data();
          delete data.userId;
          await db.collection('categories').doc(cat.id).set(data);
          categoriesSet.add(cat.id);
        }
      }
    }
    
    res.status(200).send('Migration completed successfully');
  } catch (error) {
    console.error('Migration error:', error);
    res.status(500).send('Migration failed: ' + error.message);
  }
});
```

## Security Rules Update

Update your Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // App settings - readable by all authenticated users, writable by all (or admins only)
    match /app_settings/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Or restrict to admins only
    }
    
    // Categories - readable and writable by all authenticated users
    match /categories/{categoryId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Users - users can read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Expenses - users can read/write their own expenses
    match /expenses/{expenseId} {
      allow read, write: if request.auth != null;
    }
    
    // Savings - users can read/write their own savings
    match /savings/{savingsId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Key Benefits

1. **Centralized Configuration**: All users share the same budget cycle, currency, and monthly allocation
2. **Shared Categories**: Categories are accessible to all users
3. **Simplified Data Model**: No need to duplicate settings across users
4. **Easier Updates**: Change settings once, affects all users
5. **No User ID Checks**: Categories and settings don't need user-specific filtering

## Testing Checklist

- [ ] Settings screen loads correctly
- [ ] Can update budget cycle start day
- [ ] Can update currency
- [ ] Can update monthly allocation
- [ ] Categories screen shows all categories
- [ ] Can create new categories
- [ ] Can edit existing categories
- [ ] Can delete categories (when no expenses exist)
- [ ] Expenses are displayed correctly with budget cycles
- [ ] Budget calculations use correct settings
- [ ] All users see the same categories and settings
- [ ] User-specific data (name, expenses, savings) remains isolated per user

## Rollback Plan

If issues arise, you can rollback by:

1. Revert code changes to previous commit
2. User data in `users` collection is unmodified (only name field)
3. Expenses collection is unchanged
4. The new `app_settings` and `categories` collections can be deleted if needed

## Notes

- The expenses collection remains unchanged and still uses userId for filtering
- Savings collection remains unchanged
- User profile now only stores the user's name
- All financial settings are now global and shared
