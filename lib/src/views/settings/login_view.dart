import 'package:flutter/material.dart';
import '../view_components/google_signin_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/pop_logo.png', width: 200, height: 200),
            const SizedBox(
              height: 50,
            ),
            const GoogleSignInButton(),
          ],
        ),
      ),
    );
  }
}