import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/main.dart';

import '../../services/auth_service.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;
  final AuthService _authService = AuthService();

  Future<bool> checkIfUserIsWhitelisted(String? email) async {
    if (email == null) return false;

    final collection = FirebaseFirestore.instance.collection('users');
    final querySnapshot =
        await collection.where('email', isEqualTo: email).get();

    return querySnapshot
        .docs.isNotEmpty; // True if user is found in the whitelist
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _isSigningIn
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });

                try {
                  User? user = await _authService.signInWithGoogle();
                  if (user != null) {
                    // Check if user is whitelisted
                    bool isWhitelisted =
                        await checkIfUserIsWhitelisted(user.email);
                    if (isWhitelisted) {
                      if (!mounted) return; // Add this check here
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const HomePage(
                              initialTabIndex:
                                  0))); // Assuming the Requests tab is at index 0
                    } else {
                      // User is not in the whitelist
                      await _authService
                          .signOut(); // Optional: sign out the user
                      if (!mounted) return; // Add this check here
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Access Denied'),
                          content: const Text(
                              'Your account does not have access to this app.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                if (!mounted)
                                  return; // Guard with mounted check
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  }
                } catch (e) {
                  print('error during signin');
                } finally {
                  if (mounted) {
                    // This check ensures the widget is still in the tree
                    setState(() {
                      _isSigningIn = false;
                    });
                  }
                }
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage("assets/google_logo.png"),
                      height: 35.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
