import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesPage extends StatefulWidget {
  final bool isEditMode;
  const FavoritesPage({super.key, required this.isEditMode});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> quotes = [];
  List<Map<String, String>> songs = [];
  List<String> places = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String email = 'bashalya@gmail.com'; // 🔒 hardcoded like BioPage
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final doc = await _firestore.collection('favorites').doc(email).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          quotes = List<String>.from(data['quotes'] ?? []);
          songs = List<Map<String, String>>.from(
            (data['songs'] ?? []).map((s) => Map<String, String>.from(s)),
          );
          places = List<String>.from(data['places'] ?? []);
        });
      } else {
        // Fallback defaults
        setState(() {
          quotes = ['"Be yourself; everyone else is already taken."'];
          songs = [
            {'title': 'Shape of You', 'url': 'https://open.spotify.com/track/7qiZfU4dY1lWllzX7mPBI3'}
          ];
          places = ['Paris', 'Tokyo'];
        });
      }
    } catch (e) {
      // Error fallback
      setState(() {
        quotes = ['"Be yourself; everyone else is already taken."'];
        songs = [];
        places = [];
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateFavorites() async {
    try {
      await _firestore.collection('favorites').doc(email).set({
        'quotes': quotes,
        'songs': songs,
        'places': places,
        'email': email, // optional if you want to query by email too
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Favorites saved")),
      );

      _loadFavorites(); // optional: refresh after save
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving favorites: $e")),
      );
    }
  }

  void _addQuote() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Quote"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => quotes.add(controller.text.trim()));
              _updateFavorites();
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _addSong() async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Song"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: urlController, decoration: const InputDecoration(labelText: "Spotify URL")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => songs.add({
                'title': titleController.text.trim(),
                'url': urlController.text.trim(),
              }));
              _updateFavorites();
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _addPlace() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Place"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => places.add(controller.text.trim()));
              _updateFavorites();
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        actions: widget.isEditMode
            ? [
          PopupMenuButton<String>(
            onSelected: (choice) {
              if (choice == "Add Quote") _addQuote();
              else if (choice == "Add Song") _addSong();
              else if (choice == "Add Place") _addPlace();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "Add Quote", child: Text("➕ Quote")),
              const PopupMenuItem(value: "Add Song", child: Text("➕ Song")),
              const PopupMenuItem(value: "Add Place", child: Text("➕ Place")),
            ],
          )
        ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("✨ Favorite Quotes", style: Theme.of(context).textTheme.headline6),
          ...quotes.map((q) => Card(
            color: Colors.deepPurple.shade700,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text("\"$q\"", style: const TextStyle(color: Colors.white)),
            ),
          )),
          const SizedBox(height: 20),
          Text("🎧 Favorite Songs", style: Theme.of(context).textTheme.headline6),
          ...songs.map((s) => ListTile(
            leading: const Icon(Icons.music_note, color: Colors.pink),
            title: Text(s['title'] ?? ''),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launchURL(s['url'] ?? ''),
          )),
          const SizedBox(height: 20),
          Text("📍 Favorite Places", style: Theme.of(context).textTheme.headline6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: places
                .map((p) => Chip(label: Text(p), backgroundColor: Colors.purple.shade300))
                .toList(),
          ),
        ]),
      ),
    );
  }
}
