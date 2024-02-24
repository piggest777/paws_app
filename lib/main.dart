import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:paws_app/src/services/group_state.dart';
import 'package:paws_app/src/utils/dropdown_list_provider.dart';
import 'package:paws_app/src/views/login_view.dart';
import 'package:paws_app/src/views/request_view.dart';
import 'package:paws_app/src/views/send_manager_page.dart';
import 'package:paws_app/src/views/storage_page.dart';
import 'package:provider/provider.dart';
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
  debugPaintSizeEnabled = false;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DropdownItemsProvider([])),
        ChangeNotifierProvider(create: (context) => GroupExpandedState()),
      ],
      child: const PawsApp(),
    ),
  );
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
        switchTheme: SwitchThemeData(
          // // Define the thumb color when the switch is on
          thumbColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return myColor; // Replace 'myColor' with your color
              }
              return Colors.white; // Default thumb color when not selected
            },
          ),
          // Define the track color when the switch is on
          trackColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return myColor.withOpacity(
                    0.5); // Replace 'myColor' with your color and adjust opacity
              }
              return Colors.grey
                  .withOpacity(0.5); // Default track color when not selected
            },
          ),
        ),
        appBarTheme: const AppBarTheme(
          color: myColor, // sets the color of the AppBar
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: myColor,
            hoverColor:
                myColor // sets the background color of the FloatingActionButton
            ),
                    iconTheme: const IconThemeData(
          color: Colors.black, // Default icon color
        ),
        primaryIconTheme: const IconThemeData(
          color: Colors.black, // Primary icon color, used in AppBar etc.
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/requests': (context) => const HomePage(initialTabIndex: 0),
        '/sentItems': (context) => const HomePage(initialTabIndex: 1),
      },
      // home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  final int initialTabIndex;
  const HomePage({super.key, this.initialTabIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

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
            return _buildTabView();
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

  Widget _buildTabView() {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != widget.initialTabIndex) {
          setState(() {
            _currentIndex = widget.initialTabIndex;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            RequestsPage(),
            SentItemsManagerPage(),
            StoragePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.send),
              label: 'Sent Items',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storage),
              label: 'Storage',
            ),
          ],
        ),
      ),
    );
  }
}
