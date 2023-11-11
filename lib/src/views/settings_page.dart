import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paws_app/src/services/auth_service.dart';
import 'package:paws_app/src/views/login_view.dart';

class SettingsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    AuthService _authService = AuthService();

    _logout() async {
      await _authService.signOut();
    Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => LoginPage()),
    (Route<dynamic> route) => false,
  );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: user == null
          ? Center(child: Text('Not logged in'))
          : Center(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          user.photoURL ?? 'https://via.placeholder.com/150'),
                      radius: 50,
                    ),
                    SizedBox(height: 8),
                    Text(user.displayName ?? 'No Name'),
                    SizedBox(height: 8),
                    Text(user.email ?? 'No Email'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: ()  {
                        _logout();
                      },
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}
