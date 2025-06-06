import 'package:flutter/material.dart';

class VisitingCardEditor extends StatelessWidget {
  final bool isEditMode;
  final TextEditingController nameController;
  final TextEditingController titleController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController websiteController;

  const VisitingCardEditor({
    super.key,
    required this.isEditMode,
    required this.nameController,
    required this.titleController,
    required this.addressController,
    required this.phoneController,
    required this.emailController,
    required this.websiteController,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEditMode) {
      return ElevatedButton.icon(
        onPressed: () => _showVisitingCardDialog(context),
        icon: Icon(Icons.account_box_rounded),
        label: Text("Show Visiting Card"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(nameController, 'Name'),
        _buildTextField(titleController, 'Title'),
        _buildTextField(addressController, 'Address'),
        _buildTextField(phoneController, 'Phone'),
        _buildTextField(emailController, 'Email'),
        _buildTextField(websiteController, 'Website'),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white30)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white)),
        ),
      ),
    );
  }

  void _showVisitingCardDialog(BuildContext context) {
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
                // Left
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
                          nameController.text,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          titleController.text,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right
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
                        if (addressController.text.isNotEmpty)
                          _infoRow(Icons.home, addressController.text),
                        if (phoneController.text.isNotEmpty)
                          _infoRow(Icons.phone, phoneController.text),
                        if (emailController.text.isNotEmpty)
                          _infoRow(Icons.email, emailController.text),
                        if (websiteController.text.isNotEmpty)
                          _infoRow(Icons.language, websiteController.text),
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
}
