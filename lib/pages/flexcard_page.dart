import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FlexCardPage extends StatelessWidget {
  final String name = "Emma Johnson";
  final String spotifyUrl = "https://open.spotify.com/user/xyz";
  final String instagramUrl = "https://instagram.com/emma.flex";
  final String snapcodeUrl = "https://snapchat.com/add/emmaflex";

  @override
  Widget build(BuildContext context) {
    final profileLink = "https://flexverse.app/emma";

    return Scaffold(
      appBar: AppBar(title: Text('My FlexCard')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(radius: 60, backgroundImage: AssetImage('assets/profile.jpg')),
            SizedBox(height: 12),
            Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.music_note),
              label: Text("Spotify Playlist"),
              onPressed: () => launchUrl(Uri.parse(spotifyUrl)),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text("Snapcode"),
              onPressed: () => launchUrl(Uri.parse(snapcodeUrl)),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.share),
              label: Text("Instagram"),
              onPressed: () => launchUrl(Uri.parse(instagramUrl)),
            ),
            SizedBox(height: 20),
            QrImageView(data: profileLink, version: QrVersions.auto, size: 150),
            Text("Scan to view profile", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
