import 'package:flutter/material.dart';
import 'package:mobile_google_map/model/nearby_response.dart';
import 'package:lottie/lottie.dart';

class LocationDetailsScreen extends StatelessWidget {
  final Results location;
  final Function(Results) onMarkLocation;

  const LocationDetailsScreen({
    Key? key,
    required this.location,
    required this.onMarkLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location.name ?? 'Location Details'),
      ),
      body: Padding(
    padding: const EdgeInsets.all(55.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    // crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Lottie.network('https://assets2.lottiefiles.com/packages/lf20_sj0skmmg.json'), 
      Text(
        'Name: ${location.name}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Color(0xFF5F5BDC)),
      ),
      const SizedBox(height: 10),
      Text(
        'Address: ${location.vicinity}',
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: () {
          onMarkLocation(location);
          Navigator.pop(context);
        },
          icon: const Icon(Icons.add_location),
          label: const Text('Mark Location on Map'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // sets the button's border radius
            ),
            backgroundColor: Color(0xFF5F5BDC), 
          ),  
      ),
    ],
  ),
),
    );
  }
}
