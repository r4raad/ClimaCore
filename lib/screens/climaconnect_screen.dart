import 'package:flutter/material.dart';
import '../models/school.dart';
import '../services/school_service.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import '../widgets/school_card.dart';
import 'community_screen.dart';

class ClimaConnectScreen extends StatefulWidget {
  final AppUser user;
  const ClimaConnectScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ClimaConnectScreen> createState() => _ClimaConnectScreenState();
}

class _ClimaConnectScreenState extends State<ClimaConnectScreen> {
  final SchoolService _schoolService = SchoolService();
  final UserService _userService = UserService();
  List<School> _schools = [];
  bool _loading = true;
  String? _joinedSchoolId;

  @override
  void initState() {
    super.initState();
    _joinedSchoolId = widget.user.joinedSchoolId;
    _fetchSchools();
  }

  Future<void> _fetchSchools() async {
    final schools = await _schoolService.getSchools();
    setState(() {
      _schools = schools;
      _loading = false;
    });
  }

  void _joinSchool(School school) async {
    await _userService.joinSchool(widget.user.id, school.id);
    setState(() {
      _joinedSchoolId = school.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_joinedSchoolId != null) {
      return CommunityScreen(user: widget.user, schoolId: _joinedSchoolId!);
    }
    return Scaffold(
      appBar: AppBar(title: Text('ClimaConnect')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text('Join your school community', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                ..._schools.map((school) => SchoolCard(
                      school: school,
                      joined: false,
                      onJoin: () => _joinSchool(school),
                    )),
              ],
            ),
    );
  }
} 