import 'package:flutter/material.dart';
import 'package:mobile_google_map/screen/current_location_screen.dart';
import 'package:mobile_google_map/screen/search_places_screen.dart';
import 'package:mobile_google_map/screen/simple_map_screen.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        //   leading: Image.asset(
        //     'assets/images/my_logo.png',
        //     width: 30,
        //     height: 30,
        //  ),
        title: const Text("NaviGo"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(children: [
            SizedBox(
              width: 300,
              height: 280,
              child: Lottie.network(
                  'https://assets8.lottiefiles.com/packages/lf20_q2yqh3wf.json'),
            ),
            const SizedBox(
              width: 20,
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const SimpleMapScreen();
                }));
              },
              text: 'Simple Map',
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const CurrentLocation();
                }));
              },
              text: 'User current location',
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const SearchPlacesScreen();
                }));
              },
              text: 'Search Place',
            ),
          ]),
        ),
      ),
    );
  }
}

class ElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  const ElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0), // Add 16.0 padding on all sides
      child: SizedBox(
        width: 350,
        height: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: Text(text),
            ),
          ),
        ),
      ),
    );
  }
}
