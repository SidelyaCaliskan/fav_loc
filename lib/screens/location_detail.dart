import 'package:fav_loc/model/Location.dart';
import 'package:fav_loc/screens/MapScreen.dart';
import 'package:flutter/material.dart';

class LocationDetailScreen extends StatelessWidget {
  const LocationDetailScreen({super.key, required this.location});

  final modelLocation location;

  String get locImage {
    final lat = location.location.latitude;
    final lng = location.location.longitude;

    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=13&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&markers=color:purple%7Clabel:G%7A$lat,$lng&key=AIzaSyBnrGGY4mTU34s9UbY6TB4ZRCDEho3yM1s';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(
          title: Text(location.title),
          backgroundColor: colorScheme.primary,
        ),
        body: Stack(
          children: [
            Image.file(location.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => MapScreen(
                            location: location.location,
                            isSelecting: false,
                          ),
                        ));
                      },
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(locImage),
                      ),
                    ),
                    Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black45,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Text(
                          location.location.address,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                        ))
                  ],
                )),
          ],
        ));
  }
}
