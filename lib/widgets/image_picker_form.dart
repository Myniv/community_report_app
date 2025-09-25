import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerExample extends StatefulWidget {
  final void Function(String?) onImageSelected;
  final String? initialImage;
  const ImagePickerExample({
    super.key,
    required this.onImageSelected,
    this.initialImage,
  });

  @override
  _ImagePickerExampleState createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {
  File? _image;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      widget.onImageSelected(pickedFile.path);
    } else {
      setState(() {
        _image = null;
      });
      widget.onImageSelected(widget.initialImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = 120;

    ImageProvider? imageProvider;

    if (_image != null) {
      // kalau ada file lokal, pakai FileImage
      imageProvider = FileImage(_image!);
    } else if (widget.initialImage != null) {
      // kalau ada link awal
      if (widget.initialImage!.startsWith('http')) {
        // URL dari Supabase
        imageProvider = NetworkImage(widget.initialImage!);
      } else if (widget.initialImage!.startsWith('assets/')) {
        imageProvider = AssetImage(widget.initialImage!);
      } else {
        // fallback ke file lokal
        imageProvider = FileImage(File(widget.initialImage!));
      }
    } else {
      // fallback ke default asset
      // imageProvider = const AssetImage('assets/images/profile.jpg');
      imageProvider = null;
    }

    return Center(
      child: Stack(
        children: [
          // Circular Avatar
          CircleAvatar(
            radius: size / 2,
            backgroundColor: Colors.grey[200],
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(Icons.person, size: 55)
                : null,
          ),

          // Edit button (bottom right)
          Positioned(
            bottom: 0,
            right: 4,
            child: InkWell(
              onTap: pickImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
