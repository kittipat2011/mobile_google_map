// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_google_map/model/nearby_response.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

const kGoogleApiKey = '';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  static const CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(15.425709086101342, 100.87169109829972), zoom: 5.0);

  Set<Marker> markersList = {};

  late GoogleMapController googleMapController;

  final Mode _mode = Mode.overlay;
  LatLng currentLatLng = const LatLng(15.425709086101342, 100.87169109829972);
  String radius = "300";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: const Text("Search Places"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            markers: markersList,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
          ),
          Positioned(
            left: 70,
            bottom: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  color: const Color(0xFF5F5BDC),
                  child: InkWell(
                    onTap: _handlePressButton,
                    child: const SizedBox(
                      width: 250,
                      height: 50,
                      child: Center(
                        child: Text(
                          "Search Places",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // SizedBox(height: 5),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  color: const Color(0xFF5F5BDC),
                  child: InkWell(
                    // ignore: unnecessary_null_comparison
                    onTap: currentLatLng == null
                        ? null
                        : () {
                            _listNearbyPlaces(currentLatLng!);
                          },
                    child: const SizedBox(
                      width: 250,
                      height: 50,
                      child: Center(
                        child: Text(
                          "List Nearby Places",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: 'en',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
            hintText: 'Search',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white))),
        components: []);

    displayPrediction(p!, homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Message',
        message: response.errorMessage!,
        contentType: ContentType.failure,
      ),
    ));
  }

  Future<void> displayPrediction(
      Prediction p, ScaffoldState? currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    currentLatLng = LatLng(lat, lng);

    markersList.clear();
    markersList.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {});

    googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }

  void _listNearbyPlaces(LatLng latLng) async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude},${latLng.longitude}&radius=$radius&key=$kGoogleApiKey');
    var response = await http.get(url);
    NearbyPlacesResponse nearbyPlacesResponse =
        NearbyPlacesResponse.fromJson(jsonDecode(response.body));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nearby Places',
              style: TextStyle(color: Color(0xFF5F5BDC))),
          backgroundColor: const Color.fromARGB(255, 246, 246, 247),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: nearbyPlacesResponse.results!.length,
              itemBuilder: (BuildContext context, int index) {
                final result = nearbyPlacesResponse.results![index];
                return Card(
                  child: ListTile(
                    title: Text(result.name ?? 'Unknown'),
                    subtitle: Text(result.vicinity ?? 'Unknown'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pop(context);
                      double? lat = result.geometry?.location?.lat;
                      double? lng = result.geometry?.location?.lng;
                      if (lat != null && lng != null) {
                        markersList.clear();
                        markersList.add(Marker(
                            markerId: MarkerId(result.placeId!),
                            position: LatLng(lat, lng),
                            infoWindow: InfoWindow(title: result.name)));
                        setState(() {});
                        googleMapController.animateCamera(
                            CameraUpdate.newLatLngZoom(LatLng(lat, lng), 25.0));
                      }
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFF5F5BDC)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(color: Color.fromARGB(255, 250, 250, 250)),
              ),
            ),
          ],
        );
      },
    );
  }
}
