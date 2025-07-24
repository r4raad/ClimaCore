import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityDetailScreen extends StatelessWidget {
  final Activity activity;
  final String schoolName;
  const ActivityDetailScreen({Key? key, required this.activity, required this.schoolName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isUpcoming = activity.date.isAfter(now);
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Details'),
        leading: BackButton(),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (activity.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                activity.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  activity.title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(Icons.emoji_events, color: Colors.green),
              SizedBox(width: 4),
              Text('${activity.points}', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Text('${activity.participantCount} Participant${activity.participantCount == 1 ? '' : 's'} • ${activity.date.toLocal().toString().split(' ')[0]}'),
          SizedBox(height: 16),
          Text('About Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 4),
          Text(activity.description),
          SizedBox(height: 16),
          Text(schoolName, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: isUpcoming ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isUpcoming ? Colors.green : Colors.grey,
              minimumSize: Size(double.infinity, 48),
            ),
            child: Text(isUpcoming ? 'Going' : 'Activity Ended'),
          ),
        ],
      ),
    );
  }
} 