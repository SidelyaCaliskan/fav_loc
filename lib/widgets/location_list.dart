import 'package:flutter/material.dart';
import 'package:fav_loc/model/Location.dart';
import '../screens/location_detail.dart';

class LocationList extends StatelessWidget {
  const LocationList({super.key, required this.location});

  final List<modelLocation> location;

  @override
  Widget build(BuildContext context) {
    // Japanese-style color palette and pattern
    const Color primaryColor = Color(0xFF424242); // A color akin to ink
    const Color secondaryColor =
        Color(0xFFE0E0E0); // A light grey that complements the pattern
    const patternColor = Colors.white; // For pattern details

    // Assuming you have an asset that is a Japanese pattern
    final patternDecoration = BoxDecoration(
      color: secondaryColor,
      image: DecorationImage(
        image: AssetImage('assets/patterns/japanese_pattern.png'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          patternColor.withOpacity(0.07),
          BlendMode.dstATop,
        ),
      ),
    );

    return location.isEmpty
        ? Center(
            child: Text(
              'No locations added yet',
              style: TextStyle(
                color: primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        : ListView.builder(
            itemCount: location.length,
            itemBuilder: (ctx, index) {
              return Container(
                decoration: patternDecoration,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: FileImage(location[index].image),
                  ),
                  title: Text(
                    location[index].title,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    location[index].location.address,
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.6),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) =>
                            LocationDetailScreen(location: location[index]),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }
}
