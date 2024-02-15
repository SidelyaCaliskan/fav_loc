import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});

  final void Function(File image) onPickImage;

  @override
  State<StatefulWidget> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _takenImage;

  Future<void> _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _takenImage = File(pickedImage.path);
    });

    widget.onPickImage(_takenImage!);
  }

  @override
  Widget build(BuildContext context) {
    // Japanese-style color palette
    const Color borderColor =
        Color(0xFFD7CCC8); // Soft beige, reminiscent of tatami mats
    const Color iconColor =
        Color(0xFFA5D6A7); // Matcha green, inspired by Japanese tea

    return InkWell(
      onTap: _takePicture,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white, // White color for a clean and minimalist look
        ),
        child: _takenImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _takenImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_enhance,
                    color: iconColor,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Take Picture',
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
