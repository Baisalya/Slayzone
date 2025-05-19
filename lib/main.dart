import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'pages/bio_page.dart';
import 'pages/gallery_page.dart';
import 'pages/favorites_page.dart';
import 'pages/journal_page.dart';
import 'pages/flexcard_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("Firebase initialized successfully");

    await _createMasterUser(); // 👈 Call here

  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(FlexVerseApp());
}



Future<void> _createMasterUser() async {
  const email = 'baishalya@gmail.com';
  const password = 'lala';

  try {
    // Try to sign in to check if user already exists
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    print("Master user already exists.");
    await FirebaseAuth.instance.signOut();
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      try {
        // Create the user
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;
        print("Master user created with UID: ${user?.uid}");

        // ✅ Add user data to Firestore
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': email,
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
          });
          print("Master user added to Firestore.");
        }

        await FirebaseAuth.instance.signOut();
      } catch (e) {
        print("Error creating master user: $e");
      }
    } else if (e.code == 'wrong-password') {
      print("Master user exists but wrong password.");
    } else {
      print("Auth error: ${e.message}");
    }
  }
}

class FlexVerseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SlayZone: My Life',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.purpleAccent,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: HomePage(),
    );
  }
}

// lib/pages/home_page.dart


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isAuthenticated = false;

  final List<Widget> _pages =  [
    BioPage(isEditMode: false),
    GalleryPage(isEditMode: false),
    FavoritesPage(isEditMode: false),
    JournalPage(isEditMode: false),
    FlexCardPage(isEditMode: false),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleEditButton() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );

    if (result == true) {
      setState(() {
        _isAuthenticated = true;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HomePageAuthenticated(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Life'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _handleEditButton,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
         selectedItemColor: Colors.orange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'About'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_album), label: 'Gallery'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'FlexCard'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePageAuthenticated extends StatefulWidget {
  const HomePageAuthenticated({super.key});

  @override
  State<HomePageAuthenticated> createState() => _HomePageAuthenticatedState();
}

class _HomePageAuthenticatedState extends State<HomePageAuthenticated> {
  int _selectedIndex = 0;

  final List<Widget> _pages =  [
    BioPage(isEditMode: true),
    GalleryPage(isEditMode: true),
    FavoritesPage(isEditMode: true),
    JournalPage(isEditMode: true),
    FlexCardPage(isEditMode: true),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit My Life'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
              );
            },
          )
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'About'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_album), label: 'Gallery'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'FlexCard'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
// lib/pages/login_page.dart

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  final String masterPassword = 'lala'; // Set a simple fixed password

  void _login() {
    if (_passwordController.text == masterPassword) {
      Navigator.pop(context, true); // return true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Authenticate")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Enter password to enable editing"),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Confirm"),
            )
          ],
        ),
      ),
    );
  }
}
