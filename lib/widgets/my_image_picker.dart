import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class MyImagePicker extends StatefulWidget {
  MyImagePicker({super.key, required this.onPickImage, this.isPost = false});
  final void Function(File pickedImage) onPickImage;
  bool isPost = false;

  @override
  State<MyImagePicker> createState() => _MyImagePickerState();
}

class _MyImagePickerState extends State<MyImagePicker> {
  File? _pickedImageFile;

  void _takeImage() async {
      final pickedImage = await ImagePicker().pickImage(
          source: ImageSource.camera, imageQuality: widget.isPost? 75:50, maxWidth:widget.isPost? 400:150);
    

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickImage(_pickedImageFile!);
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
           source: ImageSource.gallery, imageQuality: widget.isPost? 75:50, maxWidth:widget.isPost? 400:150);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _takeImage,
          child: CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey,
            foregroundImage:
                _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: const Icon(
              Icons.image,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}
