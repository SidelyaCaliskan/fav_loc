import 'dart:convert';

import 'package:fav_loc/model/Location.dart';
import 'package:fav_loc/screens/MapScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocInput extends StatefulWidget {
  const LocInput({super.key, required this.onSelectLocation});

  final void Function(yourLocation location) onSelectLocation;

  @override
  State<LocInput> createState() {
    return _LocInputState();
  }
}

class _LocInputState extends State<LocInput> {
  yourLocation? _pickedLocation;
  var _isGettingLocation = false;

  String get locImage {
    if (_pickedLocation == null) {
      return '';
    }

    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    // Ensure the API key is valid and replace 'YOUR_API_KEY' with your actual API key.
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=13&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&markers=color:purple%7Clabel:G%7A$lat,$lng&key=key=AIzaSyBnrGGY4mTU34s9UbY6TB4ZRCDEho3yM1s';
  }

  Future<void> _saveLoc(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyBnrGGY4mTU34s9UbY6TB4ZRCDEho3yM1s');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        if (resData['results'] != null && resData['results'].isNotEmpty) {
          final address = resData['results'][0]['formatted_address'];
          setState(() {
            _pickedLocation = yourLocation(
                latitude: latitude, longitude: longitude, address: address);
            _isGettingLocation = false;
          });
          widget.onSelectLocation(_pickedLocation!);
        } else {
          print('No address found for the given coordinates.');
          setState(() {
            _isGettingLocation = false;
          });
        }
      } else {
        // Handle the case where the server did not return a 200 OK response
        print('Server error: ${response.statusCode}');
        print('Server response: ${response.body}');
        setState(() {
          _isGettingLocation = false;
        });
      }
    } catch (e, stackTrace) {
      // Handle any exceptions that occur during the HTTP request
      print('Error fetching location: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _getCurrentLocation() async {
    Location location = new Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    LocationData locationData = await location.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      _saveLoc(locationData.latitude!, locationData.longitude!);
    }
  }

  void _selectOnMap() async {
    final pickedLocation =
        await Navigator.of(context).push<LatLng>(MaterialPageRoute(
      builder: (ctx) => const MapScreen(
          // Pass any initial location or selection flag to the MapScreen if needed.
          ),
    ));

    if (pickedLocation != null) {
      _saveLoc(pickedLocation.latitude, pickedLocation.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent;

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    } else if (_pickedLocation != null) {
      // Ensure the URL is correct by printing it to the console for debugging.
      // You can remove this line once you confirm the URL is correct.
      print('Loading image from URL: ${locImage}');

      previewContent = Image.network(
        locImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          // Log the error to the console or use a platform to capture your logs in production.
          // This is critical to understanding why the image failed to load.
          print('Error loading image: $exception');

          // Display an error message in place of the image.
          return Center(
            child: Text(
              'Failed to load image',
              style: TextStyle(
                color: Theme.of(context).errorColor,
              ),
            ),
          );
        },
      );
    } else {
      previewContent = const Text(
        'No location chosen',
        textAlign: TextAlign.center,
      );
    }

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    } else if (_pickedLocation != null) {
      previewContent = Image.network(
        locImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      previewContent = Text('No location chosen',
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ));
    }
    return Column(children: [
      Container(
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: previewContent,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.location_on),
            label: const Text('Get Current Location'),
            onPressed: _getCurrentLocation,
          ),
          TextButton.icon(
            icon: const Icon(Icons.map_rounded),
            label: const Text('Select on map'),
            onPressed: _selectOnMap,
          ),
        ],
      )
    ]);
  }
}
