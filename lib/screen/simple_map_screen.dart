import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleMapScreen extends StatefulWidget {
  const SimpleMapScreen({Key? key}) : super(key: key);

  @override
  State<SimpleMapScreen> createState() => _SimpleMapScreen();
}

class _SimpleMapScreen extends State<SimpleMapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  bool _addingMarker = false;
  final TextEditingController _markerNameController = TextEditingController();

  // ignore: constant_identifier_names
  static const CameraPosition Thailand = CameraPosition(
    target: LatLng(15.425709086101342, 100.87169109829972),
    zoom: 7,
  );

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _toggleAddMarker() {
    setState(() {
      _addingMarker = !_addingMarker;
    });
  }

  Future<void> _saveMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final markersJson = _markers
        .map((marker) => {
              'id': marker.markerId.value,
              'position': {
                'latitude': marker.position.latitude,
                'longitude': marker.position.longitude,
              },
              'title': marker.infoWindow.title,
            })
        .toList();
    prefs.setString('markers', jsonEncode(markersJson));
  }

  Future<void> _loadMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final markersJsonString = prefs.getString('markers');
    if (markersJsonString != null) {
      final markersJson = jsonDecode(markersJsonString);
      setState(() {
        _markers = {
          for (final markerJson in markersJson)
            Marker(
              markerId: MarkerId(markerJson['id']),
              position: LatLng(
                markerJson['position']['latitude'],
                markerJson['position']['longitude'],
              ),
              infoWindow: InfoWindow(
                title: markerJson['title'],
                onTap: () {
                  _onMarkerTapped(MarkerId(markerJson['id']));
                },
              ),
            ),
        };
      });
    }
  }

  void _onMapTapped(LatLng position) {
    if (_addingMarker) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Add Marker",
                style: TextStyle(color: Color(0xFF5F5BDC))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _markerNameController,
                  decoration: const InputDecoration(hintText: "Marker Name"),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _markers.add(
                      Marker(
                        markerId: MarkerId(position.toString()),
                        position: position,
                        infoWindow: InfoWindow(
                          title: _markerNameController.text.isNotEmpty
                              ? _markerNameController.text
                              : "Unnamed Marker",
                          onTap: () {
                            _onMarkerTapped(MarkerId(position.toString()));
                          },
                        ),
                      ),
                    );
                    _addingMarker = false;
                  });
                  _saveMarkers();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5F5BDC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                child: const Text('Add'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _addingMarker = false;
                  });
                },
                child: const Text("Cancel",
                    style: TextStyle(color: Color(0xFF5F5BDC))),
              ),
            ],
          );
        },
      );
    }
  }

  void _onMarkerTapped(MarkerId markerId) {
    setState(() {
      _markers =
          _markers.where((marker) => marker.markerId != markerId).toSet();
    });
    _saveMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Simple Map"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: Thailand,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: _onMapTapped,
              markers: _markers,
            ),
            Positioned(
              left: 20,
              bottom: 55,
              child: FloatingActionButton(
                onPressed: () {
                  _toggleAddMarker();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You can now add markers!'),
                      backgroundColor: Color(0xFF5F5BDC),
                      //  shape: RoundedRectangleBorder(
                      //  borderRadius: BorderRadius.circular(10),
                      // ),
                    ),
                  );
                },
                child: const Icon(Icons.add),
                // backgroundColor: Color(0xFF5F5BDC),
              ),
            ),
          ],
        ));
  }
}
