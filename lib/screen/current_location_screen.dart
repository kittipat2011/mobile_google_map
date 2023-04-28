import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_google_map/model/nearby_response.dart';
import 'Location_details_screen.dart';

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({Key? key}) : super(key: key);

  @override
  State<CurrentLocation> createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  late GoogleMapController googleMapController;
  static const String kGoogleApiKey = 'YOUR_GOOGLE_API_KEY';
  String radius = "300";

  Set<Marker> markers = {};
  late Position currentPosition;
  NearbyPlacesResponse nearbyPlacesResponse = NearbyPlacesResponse();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _updateCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("User Current Location"),
          centerTitle: true,
          backgroundColor: Color(0xFF0A182B),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                        target: LatLng(15.425709086101342, 100.87169109829972),
                        zoom: 7),
                    markers: markers,
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    onMapCreated: (GoogleMapController controller) {
                      googleMapController = controller;
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: ListView.builder(
                      itemCount: nearbyPlacesResponse.results?.length ?? 0,
                      itemBuilder: (context, index) {
                        return nearbyPlacesWidget(
                            nearbyPlacesResponse.results![index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 300.0,
              right: 5.0,
              child: FloatingActionButton.extended(
                onPressed: () {
                  _updateCurrentLocation();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Update Location !'),
                      backgroundColor: Color(0xFF5F5BDC),
                    ),
                  );
                },
                label: const Text("Update Location"),
                icon: const Icon(Icons.location_history),
                backgroundColor: Color(0xFF5F5BDC),
              ),
            ),
          ],
        ));
  }

  Future<void> _updateCurrentLocation() async {
    try {
      currentPosition = await _determinePosition();
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target:
                  LatLng(currentPosition.latitude, currentPosition.longitude),
              zoom: 14)));
      markers.clear();
      markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position:
              LatLng(currentPosition.latitude, currentPosition.longitude)));
      setState(() {});

      // Fetch nearby locations
      await getNearbyPlaces(
          currentPosition.latitude, currentPosition.longitude);
    } catch (e) {
      // You can show a Snackbar or a dialog with the error message here
      print("Error while getting user's current location: $e");
    }
  }

  Future<void> getNearbyPlaces(double latitude, double longitude) async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&key=$kGoogleApiKey');
    var response = await http.get(url);
    nearbyPlacesResponse =
        NearbyPlacesResponse.fromJson(jsonDecode(response.body));
    setState(() {});
  }

  Widget nearbyPlacesWidget(Results results) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationDetailsScreen(
              location: results,
              onMarkLocation: (location) {
                double lat = location.geometry!.location!.lat ?? 0.0;
                double lng = location.geometry!.location!.lng ?? 0.0;
                LatLng latLng = LatLng(lat, lng);
                markers.clear();
                markers.add(Marker(
                  markerId: MarkerId(location.placeId!),
                  position: latLng,
                  infoWindow: InfoWindow(title: location.name),
                ));
                setState(() {});
                googleMapController
                    .animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: latLng, zoom: 25),
                ));
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Name: ${results.name!}"),
              Text(
                  "Location: ${results.geometry!.location!.lat}, ${results.geometry!.location!.lng}"),
            ],
          ),
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled == false) {
      return Future.error("Location services are disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return Future.error("Location permission denied");
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permission is permanently denied, please enable it in settings");
    }

    Position position = await Geolocator.getCurrentPosition();
    return position;
  }
}
