import 'package:flutter/material.dart';

class JournalPage extends StatefulWidget {
  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final List<String> entries = [];

  void _addEntry(String text) {
    setState(() {
      entries.insert(0, text);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text('Journal')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'New Entry', border: OutlineInputBorder()),
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  _addEntry(val);
                  _controller.clear();
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (_, index) => ListTile(
                title: Text(entries[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
