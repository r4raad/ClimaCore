import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;

  const ActivityCard({Key? key, required this.activity, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: activity.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  activity.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: Icon(Icons.event, size: 32),
              ),
        title: Text(activity.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${activity.type} • ${activity.participantCount} Participant${activity.participantCount == 1 ? '' : 's'}\n${activity.date.toLocal().toString().split(' ')[0]}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: Colors.green),
            Text('${activity.points}', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
} 