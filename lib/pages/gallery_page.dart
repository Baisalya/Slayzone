import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  final List<String> imagePaths = [
    'assets/gallery1.jpg',
    'assets/gallery2.jpg',
    'assets/gallery3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gallery')),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Image.asset(imagePaths[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}
