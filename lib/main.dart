import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:paws_app/src/views/login_view.dart';
import 'package:paws_app/src/views/request_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PawsApp());
}

class PawsApp extends StatelessWidget {
  const PawsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paws of peace',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();

    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        // Check if the widget is still in the tree
        if (user != null) {
          // If the user is not null, we're authenticated
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => RequestsPage()),
          );
        }
        // Handle the 'null' user case if necessary
      }
    });
  }

    @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading screen while the auth state is being determined
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          // If the user is null, we're not authenticated
          if (user == null) {
            return LoginPage();
          } else {
            return RequestsPage();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }
}
