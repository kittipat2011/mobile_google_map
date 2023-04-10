import 'package:flutter/material.dart';
import 'package:mobile_google_map/screen/current_location_screen.dart';
import 'package:mobile_google_map/screen/search_places_screen.dart';
import 'package:mobile_google_map/screen/simple_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NaviGo"),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(children: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const SimpleMapScreen();
                }));
              },
              child: const Text("Simple Map")),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const CurrentLocation();
                }));
              },
              child: const Text("User current location")),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const SearchPlacesScreen();
                }));
              },
              child: const Text("Search Place")),
        ]),
      ),
    );
  }
}
