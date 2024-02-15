import 'package:fav_loc/providers/location_of_user.dart';
import 'package:fav_loc/screens/add_location.dart';
import 'package:fav_loc/widgets/location_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  late Future<void> _locFuture;

  @override
  void initState() {
    super.initState();
    _locFuture = ref.read(userLocationProvider.notifier).loadLocs();
  }

  @override
  Widget build(BuildContext context) {
    final userLocations = ref.watch(userLocationProvider);

    // Define the color scheme based on the previous screenshot provided
    const Color appBarColor = Color(0xFF6A82FB); // Soft purple
    const Color buttonColor = Color(0xFFFDA085); // Soft orange
    const Color iconColor =
        Colors.white; // Icon color for AppBar and Floating Action Button
    const Color backgroundColor = Color(0xFFF8F8F8); // Light background color

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text('Your Places', style: TextStyle(color: iconColor)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: buttonColor),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AddLocationScreen(),
                ),
              );
            },
          ),
        ],
        elevation: 0, // Removes the shadow from the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _locFuture,
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : LocationList(location: userLocations),
        ),
      ),

      backgroundColor: backgroundColor, // Set the background color
    );
  }
}
