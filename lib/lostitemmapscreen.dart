import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LostItemsMapScreen extends StatefulWidget {
  @override
  _LostItemsMapScreenState createState() => _LostItemsMapScreenState();
}

class _LostItemsMapScreenState extends State<LostItemsMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  LatLng _initialPosition = LatLng(-1.286389, 36.817223); // Default to Nairobi

  @override
  void initState() {
    super.initState();
    _fetchLostItems();
  }

  // Fetch lost items from Firestore
  Future<void> _fetchLostItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('lost_items').get();

      Set<Marker> markers = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(
            title: data['name'],
            snippet: 'Tap for details',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }).toSet();

      setState(() {
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching lost items: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get current location and move map
  Future<void> _goToCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLocation = LatLng(position.latitude, position.longitude);

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLocation, zoom: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Items Map'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),

          // Loading Indicator
          if (_isLoading)
            Center(
              child: SpinKitFadingCircle(
                color: Colors.deepPurple,
                size: 50.0,
              ),
            ),

          // Floating Buttons
          Positioned(
            top: 10,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "refresh",
                  backgroundColor: Colors.deepPurple,
                  onPressed: _fetchLostItems,
                  child: Icon(Icons.refresh, color: Colors.white),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "location",
                  backgroundColor: Colors.green,
                  onPressed: _goToCurrentLocation,
                  child: Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}