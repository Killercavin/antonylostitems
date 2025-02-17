import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';




class LostItemsApp extends StatelessWidget {
  const LostItemsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost Items Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        sliderTheme: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
        ),
      ),
      home: const LostItemsMap(),
    );
  }
}

/// Reference to the Firestore collection where lost items are stored.
final _collectionReference = FirebaseFirestore.instance.collection('lost_items');

/// Geo query condition for filtering nearby lost items.
class _GeoQueryCondition {
  _GeoQueryCondition({required this.radiusInKm, required this.cameraPosition});

  final double radiusInKm;
  final CameraPosition cameraPosition;
}

class LostItemsMap extends StatefulWidget {
  const LostItemsMap({super.key});

  @override
  LostItemsMapState createState() => LostItemsMapState();
}

class LostItemsMapState extends State<LostItemsMap> {
  Set<Marker> _markers = {};
  final _geoQueryCondition = BehaviorSubject<_GeoQueryCondition>.seeded(
    _GeoQueryCondition(radiusInKm: 1, cameraPosition: _initialCameraPosition),
  );

  late final Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _stream =
  _geoQueryCondition.switchMap(
        (geoQueryCondition) => GeoCollectionReference(_collectionReference).subscribeWithin(
      center: GeoFirePoint(
        GeoPoint(
          _cameraPosition.target.latitude,
          _cameraPosition.target.longitude,
        ),
      ),
      radiusInKm: geoQueryCondition.radiusInKm,
      field: 'last_seen_location',
      geopointFrom: (data) => (data['last_seen_location'] as GeoPoint),
      strictMode: true,
    ),
  );

  void _updateMarkers(List<DocumentSnapshot<Map<String, dynamic>>> documents) {
    final markers = <Marker>{};
    for (final doc in documents) {
      final data = doc.data();
      if (data == null) continue;
      final itemName = data['item_name'] as String;
      final geoPoint = data['last_seen_location'] as GeoPoint;
      markers.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(geoPoint.latitude, geoPoint.longitude),
          infoWindow: InfoWindow(title: itemName, snippet: "Last seen here"),
        ),
      );
    }
    setState(() {
      _markers = markers;
    });
  }

  double get _radiusInKm => _geoQueryCondition.value.radiusInKm;
  CameraPosition get _cameraPosition => _geoQueryCondition.value.cameraPosition;

  static final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-1.286389, 36.817223),
    zoom: 12,
  );

  @override
  void dispose() {
    _geoQueryCondition.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lost Items Map")),
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            myLocationButtonEnabled: true,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (_) => _stream.listen(_updateMarkers),
            markers: _markers,
            onCameraMove: (cameraPosition) {
              _geoQueryCondition.add(
                _GeoQueryCondition(radiusInKm: _radiusInKm, cameraPosition: cameraPosition),
              );
            },
          ),
        ],
      ),
    );
  }
}
