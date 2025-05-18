import 'package:flutter/material.dart';
import 'pages/bio_page.dart';
import 'pages/gallery_page.dart';
import 'pages/favorites_page.dart';
import 'pages/journal_page.dart';
import 'pages/flexcard_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  runApp(FlexVerseApp());
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

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> sections = [
    {'title': 'About Me', 'page': BioPage()},
    {'title': 'Gallery', 'page': GalleryPage()},
    {'title': 'Favorites', 'page': FavoritesPage()},
    {'title': 'Journal', 'page': JournalPage()},
    {'title': 'FlexCard', 'page': FlexCardPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FlexVerse: My Life")),
      body: ListView.builder(
        itemCount: sections.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(sections[index]['title']),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => sections[index]['page']),
              );
            },
          );
        },
      ),
    );
  }
}
