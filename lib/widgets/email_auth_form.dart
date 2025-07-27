
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class EmailAuthForm extends StatefulWidget {
  final Function(String) showSuccessDialog;
  final TextStyle? registerButtonTextStyle;

  const EmailAuthForm({Key? key, required this.showSuccessDialog, this.registerButtonTextStyle}) : super(key: key);

  @override
  _EmailAuthFormState createState() => _EmailAuthFormState();
}

class _EmailAuthFormState extends State<EmailAuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _firstName = '';
  String _lastName = '';
  bool _isLogin = false; 

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        if (_isLogin) {
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
          final userService = UserService();
          final firebaseUser = userCredential.user;
          if (firebaseUser != null) {
            AppUser? appUser = await userService.getUserById(firebaseUser.uid);
            if (appUser == null) {
              await userService.addUser(AppUser(
                id: firebaseUser.uid,
                name: firebaseUser.displayName ?? '',
                points: 0,
                savedPosts: [],
                likedPosts: [],
                profilePic: null,
                actions: 0,
                streak: 0,
                weekPoints: 0,
                weekGoal: 800,
              ));
            }
          }
          widget.showSuccessDialog('''Welcome Back to ClimaCore!\nYour all-in-one space to learn, act, and lead the way in climate action.''');
        } else {
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
          final userService = UserService();
          final firebaseUser = userCredential.user;
          if (firebaseUser != null) {
            await userService.addUser(AppUser(
              id: firebaseUser.uid,
              name: (_firstName + ' ' + _lastName).trim(),
              points: 0,
              savedPosts: [],
              likedPosts: [],
              profilePic: null,
              actions: 0,
              streak: 0,
              weekPoints: 0,
              weekGoal: 800,
            ));
          }
          widget.showSuccessDialog('''Welcome to ClimaCore!\nYour all-in-one space to learn, act, and lead the way in climate action.''');
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (_isLogin) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'No user found for that email.';
              break;
            case 'wrong-password':
              errorMessage = 'Wrong password provided for that user.';
              break;
             case 'invalid-email':
              errorMessage = 'The email address is not valid.';
              break;
            default:
              errorMessage = 'Login failed. Please try again.';
          }
        } else {
           switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'The account already exists for that email.';
              break;
            case 'invalid-email':
              errorMessage = 'The email address is not valid.';
              break;
            case 'operation-not-allowed':
              errorMessage = 'Email/password accounts are not enabled.'; 
              break;
            case 'weak-password':
              errorMessage = 'The password provided is too weak.';
              break;
            default:
              errorMessage = 'Registration failed. Please try again.';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(errorMessage),
             backgroundColor: Colors.redAccent,
           ),
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isLogin) ...[ 
            TextFormField(
              decoration: InputDecoration(labelText: 'First Name', border: OutlineInputBorder()), 
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
              onSaved: (value) {
                _firstName = value!;
              },
            ),
            SizedBox(height: 15), 
            TextFormField(
              decoration: InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
               validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
              onSaved: (value) {
                _lastName = value!;
              },
            ),
            SizedBox(height: 15), 
          ],
          TextFormField(
            decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()), 
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onSaved: (value) {
              _email = value!;
            },
          ),
          SizedBox(height: 15), 
          TextFormField(
            decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(), suffixIcon: Icon(Icons.visibility)), 
            obscureText: true,
             validator: (value) {
                if (value == null || value.isEmpty || value.length < 6) {
                  return 'Password must be at least 6 characters long';
                }
                return null;
              },
            onSaved: (value) {
              _password = value!;
            },
          ),
           if (_isLogin) ...[ 
              SizedBox(height: 15), 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Row(
                     children: [
                       Checkbox(value: false, onChanged: (value) {}), 
                       Text("Remember me"),
                     ],
                   ),
                   TextButton(onPressed: () {}, child: Text("Forgot password?")) 
                ],
              ),
           ],
          SizedBox(height: 20), 
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom( 
              backgroundColor: Colors.green[700], 
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              textStyle: TextStyle(fontSize: 18),
            ),
            child: Text(_isLogin ? 'Sign In' : 'Register', style: _isLogin ? null : widget.registerButtonTextStyle),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = !_isLogin;
              });
            },
            child: Text(
              _isLogin ? 'Need an account? Register Here' : 'Already have an account? Login',
              style: TextStyle(color: Colors.green[700]), 
            ),
          ),
        ],
      ),
    );
  }
}
