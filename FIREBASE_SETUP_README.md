# Firebase Setup Guide

## Overview
This app now relies entirely on Firebase Firestore for data. No hardcoded data is used in the code. All user data, quiz submissions, activities, and statistics are fetched from Firestore.

## Database Structure

### Collections
- **users**: User profiles and statistics
- **quizzes**: Available quizzes
- **quiz_progress**: User quiz completion records
- **activities**: Community activities
- **posts**: Community posts

### User Document Structure
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "points": 1250,
  "savedPosts": [],
  "likedPosts": [],
  "profilePic": null,
  "actions": 15,
  "streak": 5,
  "weekPoints": 180,
  "weekGoal": 800
}
```

## Setting Up Firebase

### Option 1: Manual Setup (Recommended)
1. Go to Firebase Console
2. Navigate to Firestore Database
3. Create the collections manually
4. Add sample data directly in the console

### Option 2: Programmatic Setup with Dummy Users
Use the `DatabasePopulator` utility to add dummy users to your Firebase database:

```dart
// In your app initialization or a separate setup script
import 'utils/database_populator.dart';

// Add dummy users to the database
await DatabasePopulator.populateWithDummyUsers();

// Or initialize the entire database with sample data
await DatabasePopulator.initializeDatabase();

// Get database statistics
final stats = await DatabasePopulator.getDatabaseStats();
print('Database stats: $stats');

// Clear dummy data when needed
await DatabasePopulator.clearDummyData();
```

### Option 3: Using FirebaseSetup Directly
```dart
import 'utils/firebase_setup.dart';

// Create only dummy users
await FirebaseSetup.createDummyUsers();

// Initialize with complete sample data
await FirebaseSetup.initializeWithSampleData();

// Check if database has enough users
final hasEnough = await FirebaseSetup.hasEnoughUsers(minUsers: 3);
```

### Option 4: Import JSON Data
1. Export sample data as JSON
2. Import into Firebase Console
3. Structure matches the document format above

## Dummy Users Created

The `DatabasePopulator` will create the following dummy users:

1. **Alex Johnson** - 1250 points, 15 actions, 5-day streak
2. **Maria Garcia** - 980 points, 12 actions, 3-day streak  
3. **David Chen** - 650 points, 8 actions, 2-day streak
4. **Sarah Williams** - 420 points, 6 actions, 1-day streak
5. **Michael Brown** - 320 points, 4 actions, 1-day streak

## Sample Data

### Quizzes
- Climate Change Basics (50 points)
- Carbon Footprint Quiz (40 points)

### Activities
- Community Tree Planting (100 points)
- Beach Cleanup Drive (75 points)

## Data Flow

### Profile Screen
- Fetches user data from `users` collection
- Loads quiz submissions from `quiz_progress` collection
- Displays real-time statistics from Firestore

### Leaderboard
- Queries `users` collection ordered by points
- Shows actual user rankings from database

### Activities & Quizzes
- Updates user points in Firestore when completed
- Tracks progress in `quiz_progress` collection
- Maintains user statistics in real-time

## Important Notes

1. **No Hardcoded Data**: All values come from Firestore
2. **Real-time Updates**: Profile refreshes data on each load
3. **Dynamic Statistics**: Points, streaks, and progress calculated from database
4. **User-driven**: New users start with 0 points and build up through activities
5. **Dummy Data Management**: Dummy users are created programmatically, not hardcoded in app runtime

## How to Add Dummy Users

### Method 1: Temporary Code Addition
Add this to your `main.dart` temporarily:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // TEMPORARY: Add dummy users (remove after first run)
  await DatabasePopulator.populateWithDummyUsers();
  
  runApp(ClimaCore());
}
```

### Method 2: Manual Console Setup
1. Go to Firebase Console → Firestore Database
2. Create a `users` collection
3. Add documents with the structure shown above
4. Use the dummy user data provided in this README

### Method 3: Development Script
Create a separate development script:

```dart
// dev_setup.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/database_populator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await DatabasePopulator.populateWithDummyUsers();
  print('✅ Dummy users added successfully!');
}
```

## Troubleshooting

### Empty Profile
- Check if user document exists in Firestore
- Verify user authentication is working
- Ensure Firestore rules allow read access

### No Quiz Submissions
- Check `quiz_progress` collection for user records
- Verify quiz completion is saving to Firestore
- Look for completed quizzes with `isCompleted: true`

### Missing Activities
- Check `activities` collection in Firestore
- Verify user's `joinedSchoolId` matches activity school
- Ensure activities have valid dates and points

### No Dummy Users
- Run `DatabasePopulator.populateWithDummyUsers()`
- Check Firebase Console for user documents
- Verify Firestore rules allow write access

## Security Rules

Make sure your Firestore security rules allow:
- Users to read their own data
- Users to update their own statistics
- Public read access to leaderboards
- Authenticated users to create quiz progress

Example rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /quiz_progress/{progressId} {
      allow read, write: if request.auth != null;
    }
    match /quizzes/{quizId} {
      allow read: if true;
    }
  }
}
``` 