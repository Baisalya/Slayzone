import 'package:flutter/material.dart';

class BioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Me')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/profile.jpg')),
            SizedBox(height: 16),
            Text("Hi, I'm Emma!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("I love photography, music, and traveling the world. This app is all about me."),
          ],
        ),
      ),
    );
  }
}
