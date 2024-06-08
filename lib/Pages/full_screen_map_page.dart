import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FullScreenMapPage extends StatefulWidget {
  final double lat;
  final double long;
  const FullScreenMapPage({super.key, required this.lat, required this.long});

  @override
  State<FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<FullScreenMapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        markers: {
          Marker(
            markerId: MarkerId('current'),
            position: LatLng(widget.lat, widget.long),
          ),
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.lat, widget.long),
          zoom: 16.0,
        ),
      ),
    );
  }
}
