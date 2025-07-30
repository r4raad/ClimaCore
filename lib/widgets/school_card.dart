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
    print('🎨 SchoolCard: Building card for "${school.name}" (ID: ${school.id})');
    print('🎨 SchoolCard: School object is null? ${school == null}');
    print('🎨 SchoolCard: School name length: ${school.name.length}');
    print('🎨 SchoolCard: School name is empty? ${school.name.isEmpty}');
    
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
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ SchoolCard: Image failed to load for "${school.name}": $error');
                      return Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[300],
                        ),
                        child: Center(child: Icon(Icons.school, size: 48)),
                      );
                    },
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    school.name.isNotEmpty ? school.name : 'Unnamed School',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    // Colored dots
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${school.memberCount} members',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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