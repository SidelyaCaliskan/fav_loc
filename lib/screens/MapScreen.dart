import 'dart:convert';
import 'package:fav_loc/model/Location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const softPurple = Color(0xFFB39DDB);
const softOrange = Color.fromARGB(255, 236, 96, 53);

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const yourLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: '',
    ),
    this.isSelecting = true,
  });

  final yourLocation location;
  final bool isSelecting;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};
  LatLng? _pickedLocation;
  TextEditingController _searchController = TextEditingController();

  GoogleMapController? _mapController;
  void _searchAndNavigate() async {
    final address = _searchController.text;
    final coordinates = await getCoordinatesFromAddress(address);
    if (coordinates != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(coordinates),
      );
      setState(() {
        _pickedLocation =
            coordinates; // Update the picked location with the search result
        // Update the markers with a new marker at the searched location
        _markers
            .clear(); // Clear existing markers if you want only the latest search result to be marked
        _markers.add(
          Marker(
            markerId: MarkerId('searchedLocation'),
            position: coordinates,
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location not found")),
      );
    }
  }

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=AIzaSyBnrGGY4mTU34s9UbY6TB4ZRCDEho3yM1s', // Ensure your API key is correctly inserted here
    );

    try {
      final response = await http.get(url);
      print(
          'Geocoding API Response: ${response.body}'); // Debugging: Print the API response

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['results'].isNotEmpty) {
          final lat = json['results'][0]['geometry']['location']['lat'];
          final lng = json['results'][0]['geometry']['location']['lng'];
          return LatLng(lat, lng);
        } else {
          print('No results found'); // Debugging: No results case
        }
      } else {
        print(
            'API request failed with status: ${response.statusCode}'); // Debugging: API request failure
      }
    } catch (e) {
      print(
          "Error fetching location: $e"); // Debugging: Catch and print any errors
    }
    return null; // Return null if no results or an error occurs
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _saveLocation(LatLng location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', location.latitude);
    await prefs.setDouble('longitude', location.longitude);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final double? lat = prefs.getDouble('latitude');
    final double? lng = prefs.getDouble('longitude');

    if (lat != null && lng != null) {
      setState(() {
        _pickedLocation = LatLng(lat, lng);
        _markers.add(
          Marker(
            markerId: MarkerId('savedLocation'),
            position: _pickedLocation!,
          ),
        );
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(_pickedLocation!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSelecting ? 'Pick your Location' : 'Your Location'),
        backgroundColor: softPurple,
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _pickedLocation != null
                  ? () async {
                      await _saveLocation(
                          _pickedLocation!); // Save the location
                      Navigator.of(context)
                          .pop(_pickedLocation); // Pop with the picked location
                    }
                  : null,
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onTap: widget.isSelecting
                ? (position) {
                    setState(() {
                      _pickedLocation = position;
                      _markers.add(
                        Marker(
                          markerId: MarkerId('pickedLocation'),
                          position: position,
                        ),
                      );
                    });
                  }
                : null,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.location.latitude,
                widget.location.longitude,
              ),
              zoom: 16,
            ),
            markers: _markers, // Use the _markers set here
          ),
          Positioned(
            top: 10,
            right: 15,
            left: 15,
            child: Container(
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Enter location',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _searchAndNavigate,
                  ),
                ),
                onSubmitted: (value) => _searchAndNavigate(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
