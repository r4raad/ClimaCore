import 'package:flutter/material.dart';
import '../models/school.dart';

class SchoolCard extends StatelessWidget {
  final School school;
  final bool joined;
  final VoidCallback onJoin;

  const SchoolCard({
    Key? key,
    required this.school,
    required this.joined,
    required this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          school.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    school.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[300],
                  ),
                  child: Center(child: Icon(Icons.school, size: 48)),
                ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              school.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: joined
                ? Chip(label: Text('Joined'), backgroundColor: Colors.green)
                : ElevatedButton(
                    onPressed: onJoin,
                    child: Text('Join'),
                  ),
          ),
        ],
      ),
    );
  }
} 