import 'dart:io';
import 'package:fav_loc/model/Location.dart';
import 'package:fav_loc/widgets/imageInput.dart';
import 'package:fav_loc/widgets/loc_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fav_loc/providers/location_of_user.dart';
import 'package:google_fonts/google_fonts.dart';

const softPurple = Color(0xFFB39DDB);
const softOrange = Color.fromARGB(255, 236, 96, 53);

class AddLocationScreen extends ConsumerStatefulWidget {
  const AddLocationScreen({super.key});

  @override
  ConsumerState<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends ConsumerState<AddLocationScreen> {
  final TextEditingController _titleController = TextEditingController();
  File? _takenImage;
  yourLocation? _pickedLocation;

  void _saveLocation() {
    if (_titleController.text.isEmpty ||
        _takenImage == null ||
        _pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter all information.'),
          backgroundColor: softOrange,
        ),
      );
      return;
    }
    ref
        .read(userLocationProvider.notifier)
        .addLocation(_titleController.text, _takenImage!, _pickedLocation!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: softPurple.withAlpha(235),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: softOrange),
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .hideCurrentSnackBar(); // Hide the SnackBar
              Navigator.of(context).pop(); // Then navigate back
            },
          ),
          title: Text('Add New Location',
              style: GoogleFonts.nunito(color: softOrange)),
          backgroundColor: softPurple,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Location Name',
                    hintStyle:
                        GoogleFonts.nunito(color: softPurple.withOpacity(0.5)),
                    fillColor: Color.fromARGB(255, 249, 217, 154),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.nunito(color: softPurple),
                ),
                const SizedBox(height: 20),
                ImageInput(
                    onPickImage: (image) =>
                        setState(() => _takenImage = image)),
                const SizedBox(height: 20),
                LocInput(
                    onSelectLocation: (location) =>
                        setState(() => _pickedLocation = location)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _saveLocation,
                  icon: Icon(Icons.add_location, color: Colors.white),
                  label: Text('Add Location',
                      style: GoogleFonts.nunito(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    primary: softOrange,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
