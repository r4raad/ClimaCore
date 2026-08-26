import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Future<AppUser?> getUserById(String id) async {
    final doc = await usersCollection.doc(id).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> addUser(AppUser user) async {
    await usersCollection.doc(user.id).set(user.toMap());
  }

  Future<void> updateUserPoints(String userId, int points) async {
    await usersCollection.doc(userId).update({'points': points});
  }

  Future<void> addUserPoints(String userId, int pointsToAdd) async {
    if (pointsToAdd == 0) return;

    final doc = await usersCollection.doc(userId).get();
    if (doc.exists) {
      final userData = doc.data() as Map<String, dynamic>;
      final currentPoints = userData['points'] ?? 0;
      final newPoints = currentPoints + pointsToAdd;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dayKey = 'points_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';

      final currentDayPoints = userData[dayKey] ?? 0;
      final newDayPoints = currentDayPoints + pointsToAdd;

      final updates = <String, dynamic>{
        'points': newPoints,
        dayKey: newDayPoints,
      };

      final monthKey = 'points_${now.year}_${now.month.toString().padLeft(2, '0')}';
      final currentMonthPoints = userData[monthKey] ?? 0;
      final newMonthPoints = currentMonthPoints + pointsToAdd;
      updates[monthKey] = newMonthPoints;

      await usersCollection.doc(userId).update(updates);

      final newWeekPoints = await _calculateWeeklyPoints(userId, now);

      await usersCollection.doc(userId).update({
        'weekPoints': newWeekPoints,
      });

      print('✅ UserService: Added $pointsToAdd points to user $userId');
      print('   📊 Daily: $newDayPoints | Weekly: $newWeekPoints | Monthly: $newMonthPoints | Total: $newPoints');
    }
  }

  Future<int> _calculateWeeklyPoints(String userId, DateTime referenceDate) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (!doc.exists) return 0;

      final userData = doc.data() as Map<String, dynamic>;
      int weeklyTotal = 0;

      for (int i = 0; i < 7; i++) {
        final date = referenceDate.subtract(Duration(days: i));
        final dayKey = 'points_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';
        weeklyTotal += (userData[dayKey] ?? 0) as int;
      }

      return weeklyTotal;
    } catch (e) {
      print('❌ Error calculating weekly points: $e');
      return 0;
    }
  }

  Future<int> _calculateMonthlyPoints(String userId, DateTime referenceDate) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (!doc.exists) return 0;

      final userData = doc.data() as Map<String, dynamic>;
      int monthlyTotal = 0;

      final firstDayOfMonth = DateTime(referenceDate.year, referenceDate.month, 1);
      final lastDayOfMonth = DateTime(referenceDate.year, referenceDate.month + 1, 0);

      for (int day = 1; day <= lastDayOfMonth.day; day++) {
        final date = DateTime(referenceDate.year, referenceDate.month, day);
        final dayKey = 'points_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';
        monthlyTotal += (userData[dayKey] ?? 0) as int;
      }

      return monthlyTotal;
    } catch (e) {
      print('❌ Error calculating monthly points: $e');
      return 0;
    }
  }

  Future<int> getDailyPoints(String userId, DateTime date) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (!doc.exists) return 0;

      final userData = doc.data() as Map<String, dynamic>;
      final dayKey = 'points_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

      return userData[dayKey] ?? 0;
    } catch (e) {
      print('❌ Error getting daily points: $e');
      return 0;
    }
  }

  Future<void> refreshWeeklyPointsForAllUsers() async {
    try {
      print('🔄 UserService: Refreshing weekly points for all users...');

      final snapshot = await usersCollection.get();
      int updatedCount = 0;

      for (final doc in snapshot.docs) {
        try {
          final userId = doc.id;
          final newWeekPoints = await _calculateWeeklyPoints(userId, DateTime.now());

          await usersCollection.doc(userId).update({
            'weekPoints': newWeekPoints,
          });

          updatedCount++;
          print('✅ Updated weekly points for user $userId: $newWeekPoints');
        } catch (e) {
          print('❌ Error updating weekly points for user ${doc.id}: $e');
        }
      }

      print('🎉 UserService: Successfully refreshed weekly points for $updatedCount users');
    } catch (e) {
      print('❌ Error refreshing weekly points: $e');
    }
  }

  Future<int> getWeeklyPoints(String userId) async {
    return await _calculateWeeklyPoints(userId, DateTime.now());
  }

  Future<int> getMonthlyPoints(String userId) async {
    return await _calculateMonthlyPoints(userId, DateTime.now());
  }

  Future<int> getWeeklyPointsForDate(String userId, DateTime endDate) async {
    return await _calculateWeeklyPoints(userId, endDate);
  }

  Future<int> getMonthlyPointsForDate(String userId, DateTime date) async {
    return await _calculateMonthlyPoints(userId, date);
  }

  Future<List<Map<String, dynamic>>> getDailyPointsHistory(String userId, int days) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (!doc.exists) return [];

      final userData = doc.data() as Map<String, dynamic>;
      final dailyHistory = <Map<String, dynamic>>[];
      final now = DateTime.now();

      for (int i = days - 1; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayKey = 'points_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';
        final points = userData[dayKey] ?? 0;

        dailyHistory.add({
          'date': date,
          'points': points,
          'label': '${date.month}/${date.day}',
        });
      }

      return dailyHistory;
    } catch (e) {
      print('❌ Error getting daily points history: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserHistoricalPoints(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (!doc.exists) return [];

      final userData = doc.data() as Map<String, dynamic>;
      final historicalPoints = <Map<String, dynamic>>[];

      final now = DateTime.now();
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthKey = 'points_${month.year}_${month.month.toString().padLeft(2, '0')}';

        final monthPoints = userData[monthKey] ?? 0;
        historicalPoints.add({
          'month': month,
          'points': monthPoints,
          'label': '${month.month}/${month.year}',
        });
      }

      return historicalPoints;
    } catch (e) {
      print('❌ Error getting user historical points: $e');
      return [];
    }
  }

  Future<void> updateUserStreakFromDailyActivity(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (!doc.exists) return;

      final userData = doc.data() as Map<String, dynamic>;
      final now = DateTime.now();
      int currentStreak = userData['streak'] ?? 0;

      final today = DateTime(now.year, now.month, now.day);
      final dayKey = 'points_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
      final todayPoints = userData[dayKey] ?? 0;

      if (todayPoints > 0) {

        final yesterday = today.subtract(Duration(days: 1));
        final yesterdayKey = 'points_${yesterday.year}_${yesterday.month.toString().padLeft(2, '0')}_${yesterday.day.toString().padLeft(2, '0')}';
        final yesterdayPoints = userData[yesterdayKey] ?? 0;

        if (yesterdayPoints > 0) {

          currentStreak++;
        } else {

          currentStreak = 1;
        }
      } else {

        final yesterday = today.subtract(Duration(days: 1));
        final yesterdayKey = 'points_${yesterday.year}_${yesterday.month.toString().padLeft(2, '0')}_${yesterday.day.toString().padLeft(2, '0')}';
        final yesterdayPoints = userData[yesterdayKey] ?? 0;

        if (yesterdayPoints == 0) {

          currentStreak = 0;
        }
      }

      await usersCollection.doc(userId).update({'streak': currentStreak});
      print('✅ UserService: Updated streak for user $userId to $currentStreak days');
    } catch (e) {
      print('❌ Error updating user streak: $e');
    }
  }

  Future<void> updateUserActions(String userId, int actions) async {
    await usersCollection.doc(userId).update({'actions': actions});
  }

  Future<void> addUserAction(String userId) async {
    final doc = await usersCollection.doc(userId).get();
    if (doc.exists) {
      final currentActions = (doc.data() as Map<String, dynamic>)['actions'] ?? 0;
      await usersCollection.doc(userId).update({'actions': currentActions + 1});
    }
  }

  Future<void> updateUserStreak(String userId, int streak) async {
    await usersCollection.doc(userId).update({'streak': streak});
  }

  Future<void> updateWeekPoints(String userId, int weekPoints) async {
    await usersCollection.doc(userId).update({'weekPoints': weekPoints});
  }

  Future<void> addWeekPoints(String userId, int pointsToAdd) async {

    await addUserPoints(userId, pointsToAdd);
  }

  Future<void> joinSchool(String userId, String schoolId) async {
    await usersCollection.doc(userId).update({'joinedSchoolId': schoolId});
  }

  Future<void> updateUserProfilePic(String userId, String profilePicUrl) async {
    await usersCollection.doc(userId).update({'profilePic': profilePicUrl});
  }

  Future<void> ensureDummyUsersExist() async {
    try {
      print('🔍 UserService: Checking if dummy users exist...');
      final snapshot = await usersCollection.get();

      if (snapshot.docs.length < 3) {
        print('📝 UserService: Not enough users found. Please add users directly to Firebase Firestore.');
        print('📝 UserService: You can add users through the Firebase Console or create them programmatically.');
      } else {
        print('✅ UserService: Sufficient users already exist in Firebase');
      }
    } catch (e) {
      print('❌ UserService: Error checking users: $e');
      rethrow;
    }
  }
}