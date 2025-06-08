// Enhanced MS Publisher-like Visiting Card Editor with Custom Shapes, Text Styles, and Margin Color Zones

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(MaterialApp(home: FullDesignEditor(
  nameController: TextEditingController(),
  titleController: TextEditingController(),
  addressController: TextEditingController(),
  phoneController: TextEditingController(),
  emailController: TextEditingController(),
  websiteController: TextEditingController(),
)));

class FullDesignEditor extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController titleController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController websiteController;

  const FullDesignEditor({super.key,
    required this.nameController,
    required this.titleController,
    required this.addressController,
    required this.phoneController,
    required this.emailController,
    required this.websiteController,
  });

  @override
  State<FullDesignEditor> createState() => _FullDesignEditorState();
}

class _FullDesignEditorState extends State<FullDesignEditor> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final List<_CardElement> _elements = [];
  Color _backgroundColor = Colors.white;

  void _addText(String text) {
    _elements.add(_CardElement(
        id: const Uuid().v4(),
        child: Text(text, style: const TextStyle(fontSize: 18))));
    setState(() {});
  }

  void _addTextFromField(String type) {
    switch (type) {
      case 'name': _addText(widget.nameController.text); break;
      case 'title': _addText(widget.titleController.text); break;
      case 'address': _addText(widget.addressController.text); break;
      case 'phone': _addText(widget.phoneController.text); break;
      case 'email': _addText(widget.emailController.text); break;
      case 'website': _addText(widget.websiteController.text); break;
    }
  }

  void _addImageElement() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _elements.add(_CardElement(
        id: const Uuid().v4(),
        child: Image.file(File(picked.path), width: 80, height: 80),
      ));
      setState(() {});
    }
  }

  void _addShape(String type) async {
    Color startColor = Colors.orange;
    Color endColor = Colors.purple;
    bool useGradient = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text("Customize Shape"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text("Use Gradient"),
                  value: useGradient,
                  onChanged: (val) => setInnerState(() => useGradient = val),
                ),
                const Text("Start Color"),
                ColorPicker(pickerColor: startColor, onColorChanged: (c) => setInnerState(() => startColor = c)),
                const Text("End Color"),
                ColorPicker(pickerColor: endColor, onColorChanged: (c) => setInnerState(() => endColor = c)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Add")),
          ],
        ),
      ),
    );

    BoxDecoration decoration = useGradient
        ? BoxDecoration(gradient: LinearGradient(colors: [startColor, endColor]), shape: type == 'circle' ? BoxShape.circle : BoxShape.rectangle)
        : BoxDecoration(color: startColor, shape: type == 'circle' ? BoxShape.circle : BoxShape.rectangle);

    Widget shape = Container(
      width: type == 'line' ? 100 : 60,
      height: type == 'line' ? 2 : 60,
      decoration: decoration,
    );

    _elements.add(_CardElement(id: const Uuid().v4(), child: shape));
    setState(() {});
  }

  void _addColorZone() async {
    Color startColor = Colors.lightBlue;
    Color endColor = Colors.blue;
    double height = 30;
    bool useGradient = false;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Color Zone"),
        content: StatefulBuilder(
          builder: (context, setInnerState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(value: height, min: 10, max: 100, onChanged: (v) => setInnerState(() => height = v)),
                SwitchListTile(
                  title: const Text("Use Gradient"),
                  value: useGradient,
                  onChanged: (v) => setInnerState(() => useGradient = v),
                ),
                const Text("Start Color"),
                ColorPicker(pickerColor: startColor, onColorChanged: (c) => setInnerState(() => startColor = c)),
                if (useGradient) ...[
                  const SizedBox(height: 10),
                  const Text("End Color"),
                  ColorPicker(pickerColor: endColor, onColorChanged: (c) => setInnerState(() => endColor = c)),
                ]
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Add")),
        ],
      ),
    );

    BoxDecoration decoration = useGradient
        ? BoxDecoration(gradient: LinearGradient(colors: [startColor, endColor]))
        : BoxDecoration(color: startColor);

    _elements.add(_CardElement(
      id: const Uuid().v4(),
      child: Container(width: 360, height: height, decoration: decoration),
    ));

    setState(() {});
  }

  void _pickBackgroundColor() async {
    Color pickerColor = _backgroundColor;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick Background Color'),
        content: ColorPicker(pickerColor: pickerColor, onColorChanged: (c) => pickerColor = c),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () {
            setState(() => _backgroundColor = pickerColor);
            Navigator.pop(context);
          }, child: const Text("Apply"))
        ],
      ),
    );
  }

  Future<void> _shareCard() async {
    final image = await _screenshotController.capture();
    if (image == null) return;
    final directory = await getTemporaryDirectory();
    final path = File('${directory.path}/custom_card.png');
    await path.writeAsBytes(image);
    await Share.shareXFiles([XFile(path.path)], text: 'My Visiting Card');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Visiting Card Designer"),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareCard),
          IconButton(icon: const Icon(Icons.color_lens), onPressed: _pickBackgroundColor),
          IconButton(icon: const Icon(Icons.image), onPressed: _addImageElement),
          IconButton(icon: const Icon(Icons.border_style), onPressed: _addColorZone),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _toolbarButton("Name", () => _addTextFromField("name")),
            _toolbarButton("Email", () => _addTextFromField("email")),
            _toolbarButton("Phone", () => _addTextFromField("phone")),
            _toolbarButton("Website", () => _addTextFromField("website")),
            _toolbarButton("Title", () => _addTextFromField("title")),
            _toolbarButton("Address", () => _addTextFromField("address")),
            PopupMenuButton<String>(
              icon: const Icon(Icons.crop_square, color: Colors.white),
              onSelected: _addShape,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rectangle', child: Text('Rectangle')),
                PopupMenuItem(value: 'circle', child: Text('Circle')),
                PopupMenuItem(value: 'line', child: Text('Line')),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Screenshot(
          controller: _screenshotController,
          child: Container(
            width: 360,
            height: 200,
            color: _backgroundColor,
            child: Stack(
              children: _elements.map((e) => DraggableResizableWidget(
                key: Key(e.id),
                element: e,
                onUpdate: () => setState(() {}),
                onDelete: () {
                  _elements.removeWhere((el) => el.id == e.id);
                  setState(() {});
                },
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbarButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.text_fields, color: Colors.white, size: 20),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12))
        ],
      ),
    );
  }
}

class _CardElement {
  final String id;
  Widget child;
  Offset position;
  double scale;
  double rotation;

  _CardElement({required this.id, required this.child, this.position = const Offset(40, 40), this.scale = 1.0, this.rotation = 0.0});
}

class DraggableResizableWidget extends StatefulWidget {
  final _CardElement element;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const DraggableResizableWidget({super.key, required this.element, required this.onUpdate, required this.onDelete});

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
    if (widget.element.child is! Text) return;
    String currentText = (widget.element.child as Text).data ?? "";
    TextEditingController controller = TextEditingController(text: currentText);
    bool isBold = false;
    bool isItalic = false;
    bool isUnderline = false;
    TextDecorationStyle underlineStyle = TextDecorationStyle.solid;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Text"),
        content: StatefulBuilder(
          builder: (context, setInnerState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controller),
              Row(
                children: [
                  Checkbox(value: isBold, onChanged: (v) => setInnerState(() => isBold = v!)),
                  const Text("Bold"),
                  Checkbox(value: isItalic, onChanged: (v) => setInnerState(() => isItalic = v!)),
                  const Text("Italic"),
                  Checkbox(value: isUnderline, onChanged: (v) => setInnerState(() => isUnderline = v!)),
                  const Text("Underline"),
                ],
              ),
              if (isUnderline)
                DropdownButton<TextDecorationStyle>(
                  value: underlineStyle,
                  items: TextDecorationStyle.values.map((style) {
                    return DropdownMenuItem(
                      value: style,
                      child: Text(style.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (style) => setInnerState(() => underlineStyle = style!),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          ElevatedButton(onPressed: () {
            widget.element.child = Text(controller.text, style: TextStyle(
              fontSize: 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
              decorationStyle: isUnderline ? underlineStyle : null,
            ));
            Navigator.of(context).pop();
            widget.onUpdate();
          }, child: const Text("Save"))
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
        onLongPress: _editText,
        onDoubleTap: widget.onDelete,
        onScaleUpdate: (details) {
          setState(() {
            position += details.focalPointDelta;
            scale = details.scale.clamp(0.5, 2.5);
            rotation += details.rotation;
            widget.element.position = position;
            widget.element.scale = scale;
            widget.element.rotation = rotation;
          });
          widget.onUpdate();
        },
        child: Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation,
            child: widget.element.child,
          ),
        ),
      ),
    );
  }
}
