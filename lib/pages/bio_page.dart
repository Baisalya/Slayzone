import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BioPage extends StatefulWidget {
  final bool isEditMode;

  const BioPage({super.key, required this.isEditMode});

  @override
  State<BioPage> createState() => _BioPageState();
}

class _BioPageState extends State<BioPage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();

    _loadUserBio();
  }

  Future<void> _loadUserBio() async {
    try {
      // Query Firestore to get user document with email `bashalya@gmail.com`
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: 'bashalya@gmail.com')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        _nameController.text = data['name'] ?? "Hi, I'm Emma!";
        _bioController.text = data['bio'] ?? "I love photography, music, and traveling the world.";
      } else {
        // If not found, fallback defaults
        _nameController.text = "Hi, I'm Emma!";
        _bioController.text = "I love photography, music, and traveling the world.";
      }
    } catch (e) {
      // Error case fallback
      _nameController.text = "Hi, I'm Emma!";
      _bioController.text = "I love photography, music, and traveling the world.";
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    try {
      final email = 'bashalya@gmail.com';

      // Query Firestore for this email
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // Update existing document
        final docId = query.docs.first.id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .update({
          'name': _nameController.text,
          'bio': _bioController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Changes saved")),
        );
        // Reload data to reflect the latest changes in the UI
        _loadUserBio(); // 👈 Add this
      } else {
        // Create new document
        await FirebaseFirestore.instance.collection('users').add({
          'email': email,
          'name': _nameController.text,
          'bio': _bioController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found. Created new profile.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving changes: $e")),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Me'),
        actions: widget.isEditMode
            ? [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          )
        ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://img.freepik.com/premium-vector/man-avatar-profile-picture-isolated-background-avatar-profile-picture-man_1293239-4841.jpg?semt=ais_hybrid&w=740'),
            ),
            const SizedBox(height: 16),

            // Name field
            widget.isEditMode
                ? TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Name',
              ),
            )
                : Text(
              _nameController.text,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Bio field
            widget.isEditMode
                ? TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'About Me',
              ),
            )
                : Text(
              _bioController.text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
