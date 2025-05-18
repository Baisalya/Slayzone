import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoritesPage extends StatelessWidget {
  final List<String> favoriteQuotes = [
    "Be yourself; everyone else is already taken.",
    "Dream big. Work hard. Stay focused.",
    "Happiness is a direction, not a place.",
  ];

  final List<Map<String, String>> favoriteSongs = [
    {
      'title': 'Levitating - Dua Lipa',
      'url': 'https://open.spotify.com/track/4k6Uh1HXdhtgGpFfTi27nL',
    },
    {
      'title': 'As It Was - Harry Styles',
      'url': 'https://open.spotify.com/track/4LRPiXqCikLlN15c3yImP7',
    },
    {
      'title': 'Good 4 U - Olivia Rodrigo',
      'url': 'https://open.spotify.com/track/6PERP62TejQjgHu81z2Kjq',
    },
  ];

  final List<String> favoritePlaces = [
    "Paris, France 🇫🇷",
    "Kyoto, Japan 🇯🇵",
    "New York City, USA 🗽",
  ];

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildQuoteCard(String quote) {
    return Card(
      color: Colors.deepPurple.shade700,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          "\"$quote\"",
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSongTile(Map<String, String> song) {
    return ListTile(
      leading: Icon(Icons.music_note, color: Colors.pinkAccent),
      title: Text(song['title'] ?? ''),
      trailing: Icon(Icons.open_in_new),
      onTap: () => _launchURL(song['url'] ?? ''),
    );
  }

  Widget _buildPlaceChip(String place) {
    return Chip(
      label: Text(place),
      backgroundColor: Colors.purple.shade300,
      labelStyle: TextStyle(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Favorites')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("✨ Favorite Quotes"),
            ...favoriteQuotes.map(_buildQuoteCard).toList(),

            _buildSectionTitle("🎧 Favorite Songs"),
            ...favoriteSongs.map(_buildSongTile).toList(),

            _buildSectionTitle("📍 Favorite Places"),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: favoritePlaces.map(_buildPlaceChip).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
