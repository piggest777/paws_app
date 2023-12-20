import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:paws_app/src/views/login_view.dart';
import 'package:paws_app/src/views/request_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDdVkMsfmWoy0HPcXiybLqIvaS62ZI1FX0",
            authDomain: "paws-of-peace.firebaseapp.com",
            projectId: "paws-of-peace",
            storageBucket: "paws-of-peace.appspot.com",
            messagingSenderId: "35895836921",
            appId: "1:35895836921:web:d4fec386893e7fb356e228",
            measurementId: "G-8Y708HDYBX"));
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const PawsApp());
}

class PawsApp extends StatelessWidget {
  const PawsApp({super.key});
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    const Color myColor = Color.fromARGB(255, 83, 136, 63);

    return MaterialApp(
      title: 'Paws of peace',
      theme: theme.copyWith(
        buttonTheme: const ButtonThemeData(
          buttonColor: myColor, // sets the color of `ElevatedButton`
          textTheme: ButtonTextTheme
              .primary, // makes text white on the `ElevatedButton`
        ),
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: myColor,
              secondary: Colors
                  .white, // sets the secondary color in the colorScheme which is used as an accent color in some contexts
            ),
        appBarTheme: const AppBarTheme(
          color: myColor, // sets the color of the AppBar
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: myColor,
            hoverColor:
                myColor // sets the background color of the FloatingActionButton
            ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/requestsPage': (context) => const RequestsPage(), // Home route
      },
      // home: const HomePage(),
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return const LoginPage();
          } else {
            return const RequestsPage();
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
}
