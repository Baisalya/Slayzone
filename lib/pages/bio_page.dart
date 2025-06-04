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
    "Name":"",
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
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved.")));
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pics/$userEmail.jpg');
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
        content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Section Name")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
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

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;

    final keys = sections.keys.toList();
    final values = sections.values.toList();

    final movedKey = keys.removeAt(oldIndex);
    final movedValue = values.removeAt(oldIndex);

    keys.insert(newIndex, movedKey);
    values.insert(newIndex, movedValue);

    setState(() {
      sections = Map.fromIterables(keys, values);
    });
  }

  Widget _buildSectionCard(String key, String value) {
    bool isUrl = Uri.tryParse(value)?.hasAbsolutePath == true;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.article_outlined, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  key,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            widget.isEditMode
                ? TextFormField(
              initialValue: value,
              onChanged: (val) => sections[key] = val,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Enter $key...",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 12),
              ),
            )
                : isUrl
                ? GestureDetector(
              onTap: () async {
                final uri = Uri.parse(value);
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri,
                      mode: LaunchMode.externalApplication);
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
                : Text(
              value,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final sectionEntries = sections.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Resume',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: widget.isEditMode
            ? [
          IconButton(icon: const Icon(Icons.add), onPressed: _addCustomSection),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveData),
        ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : const NetworkImage(
                            "https://imgv3.fotor.com/images/blog-richtext-image/10-profile-picture-ideas-to-make-you-stand-out.jpg"),
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
                              child: const Icon(Icons.edit,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  widget.isEditMode
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: sections["Name"],
                          onChanged: (val) => sections["Name"] = val,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: sections["Intro"],
                          onChanged: (val) => sections["Intro"] = val,
                          decoration: const InputDecoration(
                            labelText: 'Intro',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  )
                      : Column(
                    children: [
                      Text(
                        sections["Name"]?.split('\n').first ?? "Your Name",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (sections["Intro"] != null)
                        Text(
                          sections["Intro"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: Colors.red),
                        ),
                    ],
                  ),

                ],
              ),
            ),
            const SizedBox(height: 20),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: _onReorder,
              buildDefaultDragHandles: true, // Optional: Use custom drag handles if needed
              children: [
                for (final entry in sectionEntries)
                  if (entry.key != "Intro")
                    Padding(
                      key: ValueKey(entry.key), // ✅ THIS is required
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        key: ValueKey('${entry.key}_row'), // ✅ Redundant key but double safe
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
/*
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0, top: 12),
                            child: Icon(Icons.drag_handle), // Drag handle
                          ),
*/
                          Expanded(child: _buildSectionCard(entry.key, entry.value)),
                        ],
                      ),
                    ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
