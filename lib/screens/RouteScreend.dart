import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class RouteScreen extends StatefulWidget {
  final LatLng startLocation;
  final LatLng endLocation;

  RouteScreen({required this.startLocation, required this.endLocation});

  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final apiKey = 'AIzaSyDvHKkhASC3maDc9F6miCClE0h8c3qBgDc';
    final apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${widget.startLocation.latitude},${widget.startLocation.longitude}&destination=${widget.endLocation.latitude},${widget.endLocation.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<LatLng> points = [];

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0]['overview_polyline']['points'];
          points.addAll(_decodePoly(route));
        }

        setState(() {
          polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              color: Colors.blue,
              points: points,
              width: 5,
            ),
          );
        });
      } else {
        print('Error en la solicitud HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
    }
  }

  List<LatLng> _decodePoly(String poly) {
    var list = poly.codeUnits;
    var index = 0;
    var len = poly.length;
    int lat = 0, lng = 0;
    List<LatLng> result = [];

    while (index < len) {
      int b, shift = 0, result1 = 0;
      do {
        b = list[index++] - 63;
        result1 |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result1 & 1) != 0 ? ~(result1 >> 1) : (result1 >> 1));
      lat += dlat;

      shift = 0;
      result1 = 0;
      do {
        b = list[index++] - 63;
        result1 |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result1 & 1) != 0 ? ~(result1 >> 1) : (result1 >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;
      result.add(LatLng(latitude, longitude));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ruta'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            (widget.startLocation.latitude + widget.endLocation.latitude) / 2,
            (widget.startLocation.longitude + widget.endLocation.longitude) / 2,
          ),
          zoom: 12.0,
        ),
        polylines: polylines,
        markers: {
          Marker(
            markerId: MarkerId('startMarker'),
            position: widget.startLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
          Marker(
            markerId: MarkerId('endMarker'),
            position: widget.endLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        },
      ),
    );
  }
}

void _navigateToRoute(BuildContext context, LatLng? currentPosition, LatLng endLocation) {
  if (currentPosition != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteScreen(
          startLocation: LatLng(currentPosition.latitude, currentPosition.longitude),
          endLocation: endLocation,
        ),
      ),
    );
  }
}

