import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class BioPage extends StatefulWidget {
  final bool isEditMode;
  const BioPage({super.key, required this.isEditMode});

  @override
  State<BioPage> createState() => _BioPageState();
}

class _BioPageState extends State<BioPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userEmail = 'bashalya@gmail.com';

  Map<String, dynamic> sections = {
    "Intro": "",
    "Education": "",
    "Skills": "",
    "Experience": "",
    "Hobbies": "",
  };

  String imageUrl = '';
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final doc = await _firestore.collection('users').doc(userEmail).get();
    if (doc.exists) {
      final data = doc.data()!;
      imageUrl = data['image'] ?? '';
      sections = Map<String, dynamic>.from(data['sections'] ?? sections);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    await _firestore.collection('users').doc(userEmail).set({
      'image': imageUrl,
      'sections': sections,
    }, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile saved.")));
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final ref = FirebaseStorage.instance.ref().child('profile_pics/$userEmail.jpg');
      await ref.putFile(File(file.path));
      imageUrl = await ref.getDownloadURL();
      setState(() {});
      _saveData();
    }
  }

  void _addCustomSection() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Section"),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: "Section Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final section = controller.text.trim();
              if (section.isNotEmpty && !sections.containsKey(section)) {
                setState(() => sections[section] = "");
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String key, String value) {
    bool isUrl = Uri.tryParse(value)?.hasAbsolutePath == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        widget.isEditMode
            ? TextFormField(
          initialValue: value,
          onChanged: (val) => sections[key] = val,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        )
            : isUrl
            ? GestureDetector(
          onTap: () async {
            final uri = Uri.parse(value);
            if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          child: Text(value, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
        )
            : Text(value, style: const TextStyle(fontSize: 16)),
      ]),
    );
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
        title: const Text('About Me', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: widget.isEditMode
            ? [
          IconButton(icon: const Icon(Icons.add), onPressed: _addCustomSection),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveData),
        ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : const NetworkImage("https://via.placeholder.com/150"),
                  ),
                  if (widget.isEditMode)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImageFromGallery,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          child: const Icon(Icons.edit, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                final entry = sections.entries.elementAt(index);
                return _buildSectionCard(entry.key, entry.value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String key, String value) {
    bool isUrl = Uri.tryParse(value)?.hasAbsolutePath == true;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            widget.isEditMode
                ? TextFormField(
              initialValue: value,
              onChanged: (val) => sections[key] = val,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Enter $key...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
            )
                : isUrl
                ? GestureDetector(
              onTap: () async {
                final uri = Uri.parse(value);
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            )
                : Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

}
