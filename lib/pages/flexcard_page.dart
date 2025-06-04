import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlexCardPage extends StatefulWidget {
  final bool isEditMode;
  const FlexCardPage({super.key, required this.isEditMode});

  @override
  State<FlexCardPage> createState() => _FlexCardPageState();
}

class _FlexCardPageState extends State<FlexCardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userEmail = 'bashalya@gmail.com';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _spotifyController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _snapcodeController = TextEditingController();
  final TextEditingController _qrDataController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
//visting card
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
////
  String _selectedQRType = 'URL';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final doc = await _firestore.collection('users').doc(userEmail).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      final flexCard = data['flexCard'] ?? {};
      _spotifyController.text = flexCard['spotify'] ?? '';
      _instagramController.text = flexCard['instagram'] ?? '';
      _snapcodeController.text = flexCard['snapcode'] ?? '';
      _qrDataController.text = flexCard['qrData'] ?? '';
      _selectedQRType = flexCard['qrType'] ?? 'URL';
      _youtubeController.text = flexCard['youtube'] ?? '';
      _twitterController.text = flexCard['twitter'] ?? '';
      _githubController.text = flexCard['github'] ?? '';
      //visting card
      _titleController.text = flexCard['title'] ?? '';
      _addressController.text = flexCard['address'] ?? '';
      _phoneController.text = flexCard['phone'] ?? '';
      _emailController.text = flexCard['email'] ?? '';
      _websiteController.text = flexCard['website'] ?? '';


    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    await _firestore.collection('users').doc(userEmail).set({
      'name': _nameController.text.trim(),
      'flexCard': {
        'spotify': _spotifyController.text.trim(),
        'instagram': _instagramController.text.trim(),
        'snapcode': _snapcodeController.text.trim(),
        'youtube': _youtubeController.text.trim(),
        'twitter': _twitterController.text.trim(),
        'github': _githubController.text.trim(),
        'qrData': _qrDataController.text.trim(),
        'qrType': _selectedQRType,
        //visting card
        'title': _titleController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'website': _websiteController.text.trim(),
      }
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully 🎉')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: widget.isEditMode
    ?AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: widget.isEditMode
            ? [
          IconButton(icon: Icon(Icons.save_rounded), onPressed: _saveData),
        ]
            : null,
      )
      :null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.indigo.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
                const SizedBox(height: 16),
                widget.isEditMode
                    ? _buildTextField(_nameController, "Name")
                    : Text(
                  _nameController.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionCard("Spotify Playlist", _spotifyController, FontAwesomeIcons.spotify),
                _buildSectionCard("Snapcode", _snapcodeController, FontAwesomeIcons.snapchat),
                _buildSectionCard("Instagram", _instagramController, FontAwesomeIcons.instagram),
                _buildSectionCard("YouTube", _youtubeController, FontAwesomeIcons.youtube),
                _buildSectionCard("Twitter", _twitterController, FontAwesomeIcons.twitter),
                _buildSectionCard("GitHub", _githubController, FontAwesomeIcons.github),

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQRTypeDropdown(),  // 🔽 Always show dropdown
                      const SizedBox(height: 10),
                      widget.isEditMode ? _buildTextField(_qrDataController, "QR Code Data") : _buildQRView(),
                    ],
                  )

                ),
                const SizedBox(height: 10),
                Text(
                  "Scan to ${_selectedQRType.toLowerCase()}",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  Widget _buildSectionCard(String label, TextEditingController controller, IconData icon) {
    final text = controller.text.trim();

    // In view mode, hide the card if there's no data
    if (!widget.isEditMode && text.isEmpty) {
      return SizedBox.shrink(); // Return nothing
    }

    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: widget.isEditMode
            ? _buildTextField(controller, label)
            : ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(label, style: TextStyle(color: Colors.white)),
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(text))) {
              await launchUrl(Uri.parse(text));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invalid link for $label')),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildQREditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("QR Code Action", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            dropdownColor: Colors.deepPurple.shade300,
            isExpanded: true,
            borderRadius: BorderRadius.circular(10),
            value: _selectedQRType,
            items: ['Portfolio', 'Download CV', 'Visiting Card']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _selectedQRType = value!),
            underline: SizedBox(),
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField(_qrDataController, "QR Code Data"),
      ],
    );
  }

  Widget _buildQRView() {
    final qrData = _qrDataController.text.trim();

    if (_selectedQRType == 'Visiting Card') {
      return ElevatedButton.icon(
        onPressed: _showVisitingCardDialog,
        icon: Icon(Icons.account_box_rounded),
        label: Text("Show Visiting Card"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
      );
    }

    if (qrData.isEmpty) {
      return Text('No QR data available', style: TextStyle(color: Colors.white70));
    }

    return Center(
      child: QrImageView(
        backgroundColor: Colors.white,
        data: qrData,
        version: QrVersions.auto,
        size: 180,
      ),
    );
  }
  void _showVisitingCardDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.transparent,
        child: AspectRatio(
          aspectRatio: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey.shade900, Colors.black],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Left side (Name and Role)
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 28,
                          child: Icon(Icons.person, color: Colors.black, size: 36),
                        ),
                        SizedBox(height: 20),
                        Text(
                          _nameController.text,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _titleController.text,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right side (Contact Info)
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade800, Colors.red.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_addressController.text.isNotEmpty)
                          _infoRow(Icons.home, _addressController.text),
                        if (_phoneController.text.isNotEmpty)
                          _infoRow(Icons.phone, _phoneController.text),
                        if (_emailController.text.isNotEmpty)
                          _infoRow(Icons.email, _emailController.text),
                        if (_websiteController.text.isNotEmpty)
                          _infoRow(Icons.language, _websiteController.text),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  Widget _buildQRTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "QR Code Type",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            dropdownColor: Colors.deepPurple.shade300,
            isExpanded: true,
            borderRadius: BorderRadius.circular(10),
            value: _selectedQRType,
            items: ['Portfolio', 'Download CV', 'Visiting Card']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedQRType = value!);
            },
            underline: SizedBox(),
          ),
        ),
      ],
    );
  }

}
