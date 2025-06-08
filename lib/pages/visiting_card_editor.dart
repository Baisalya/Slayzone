import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import 'FullCardDesignerPage.dart';
class VisitingCardEditor extends StatefulWidget {
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
  State<VisitingCardEditor> createState() => _VisitingCardEditorState();
}

class _VisitingCardEditorState extends State<VisitingCardEditor> {
  double rotationAngle = 0;
  bool useCustomDesign = false;
  Color _backgroundColor = Colors.white;
  final ScreenshotController _screenshotController = ScreenshotController();
  final List<_CardElement> _customElements = [];

  void _addTextElement() {
    _customElements.add(_CardElement(
      id: const Uuid().v4(),
      child: Text(
        'Edit Me',
        style:TextStyle(fontSize: 18, color: Colors.black),
      ),
    ));
    setState(() {});
  }

  void _pickBackgroundColor() async {
    Color pickerColor = _backgroundColor;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick Background Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                setState(() => _backgroundColor = pickerColor);
                Navigator.pop(context);
              },
              child: const Text("Apply"))
        ],
      ),
    );
  }

  Future<void> _shareCard() async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = File('${directory.path}/visiting_card.png');
      await imagePath.writeAsBytes(image);

      await Share.shareXFiles([XFile(imagePath.path)], text: 'My Digital Visiting Card');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isEditMode) ...[
          SwitchListTile(
            title: const Text("Use Custom Design", style: TextStyle(color: Colors.white)),
            value: useCustomDesign,
            onChanged: (val) => setState(() => useCustomDesign = val),
          ),
          if (useCustomDesign) ...[
            Row(
              children: [
                IconButton(
                  onPressed: _addTextElement,
                  icon: const Icon(Icons.text_fields, color: Colors.white),
                ),
                IconButton(
                  onPressed: _pickBackgroundColor,
                  icon: const Icon(Icons.color_lens, color: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullDesignEditor(
                          nameController: widget.nameController,
                          titleController: widget.titleController,
                          addressController: widget.addressController,
                          phoneController: widget.phoneController,
                          emailController: widget.emailController,
                          websiteController: widget.websiteController,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.design_services),
                  label: const Text("Edit in Full Designer"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                ),
              ],
            ),
          ]
          else ...[
            _buildTextField(widget.nameController, 'Name'),
            _buildTextField(widget.titleController, 'Title'),
            _buildTextField(widget.addressController, 'Address'),
            _buildTextField(widget.phoneController, 'Phone'),
            _buildTextField(widget.emailController, 'Email'),
            _buildTextField(widget.websiteController, 'Website'),
          ]
        ] else ...[
          ElevatedButton.icon(
            onPressed: () => _showCardDialog(context),
            icon: const Icon(Icons.account_box_rounded),
            label: const Text("Show Visiting Card"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          )
        ]
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
      ),
    );
  }

  void _showCardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Screenshot(
            controller: _screenshotController,
            child: useCustomDesign ? _buildCustomCanvas() : _buildDefaultCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultCard() {
    return Transform.rotate(
      angle: rotationAngle * pi / 180,
      child: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            rotationAngle += details.rotation * 180 / pi;
          });
        },
        onTap: _shareCard,
        child: Container(
          width: 350,
          height: 180,
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
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(backgroundColor: Colors.white, radius: 26, child: Icon(Icons.person, color: Colors.black, size: 32)),
                      const SizedBox(height: 16),
                      Text(widget.nameController.text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(widget.titleController.text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.orange.shade800, Colors.red.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.addressController.text.isNotEmpty)
                        _infoRow(Icons.home, widget.addressController.text),
                      if (widget.phoneController.text.isNotEmpty)
                        _infoRow(Icons.phone, widget.phoneController.text),
                      if (widget.emailController.text.isNotEmpty)
                        _infoRow(Icons.email, widget.emailController.text),
                      if (widget.websiteController.text.isNotEmpty)
                        _infoRow(Icons.language, widget.websiteController.text),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCanvas() {
    return Container(
      width: 350,
      height: 200,
      color: _backgroundColor,
      child: Stack(
        children: _customElements
            .map((e) => DraggableResizableWidget(
          key: Key(e.id),
          element: e,
          onUpdate: () => setState(() {}),
          onDelete: () {
            _customElements.removeWhere((el) => el.id == e.id);
            setState(() {});
          },
        ))
            .toList(),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _CardElement {
  final String id;
  Widget child;
  Offset position;
  double scale;
  double rotation;

  _CardElement({
    required this.id,
    required this.child,
    this.position = const Offset(50, 50),
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

class DraggableResizableWidget extends StatefulWidget {
  final _CardElement element;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const DraggableResizableWidget({
    super.key,
    required this.element,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<DraggableResizableWidget> createState() => _DraggableResizableWidgetState();
}

class _DraggableResizableWidgetState extends State<DraggableResizableWidget> {
  late Offset position;
  late double scale;
  late double rotation;

  @override
  void initState() {
    super.initState();
    position = widget.element.position;
    scale = widget.element.scale;
    rotation = widget.element.rotation;
  }

  void _editText() async {
    TextEditingController controller = TextEditingController(text: (widget.element.child as Text).data ?? "");
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Text"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                widget.element.child = Text(controller.text, style: TextStyle(fontSize: 18, color: Colors.black));
                Navigator.of(context).pop();
                widget.onUpdate();
              },
              child: const Text("Save")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() => position += details.delta);
          widget.element.position = position;
          widget.onUpdate();
        },
        onLongPress: _editText,
        onDoubleTap: widget.onDelete,
        onScaleUpdate: (details) {
          setState(() {
            scale = details.scale.clamp(0.5, 2.5);
            rotation += details.rotation;
          });
          widget.element.scale = scale;
          widget.element.rotation = rotation;
          widget.onUpdate();
        },
        child: Transform.scale(
          scale: scale,
          child: Transform.rotate(angle: rotation, child: widget.element.child),
        ),
      ),
    );
  }
}
