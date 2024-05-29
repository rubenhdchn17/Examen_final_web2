import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController? mapController;
  Position? currentPosition;
  Set<Marker> markers = {};
  late Marker draggableMarker;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (await Permission.locationWhenInUse.request().isGranted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentPosition = position;
        _setDraggableMarker();
        _updateMapCamera();
      });
    } catch (e) {
      print(e);
    }
  }

  void _setDraggableMarker() {
    if (currentPosition != null) {
      draggableMarker = Marker(
        markerId: MarkerId('draggableMarker'),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        draggable: true,
        onDragEnd: (newPosition) {
          updateMarkerPosition(newPosition);
        },
      );
      markers.add(draggableMarker);
    }
  }

  void _updateMapCamera() {
    if (mapController != null && currentPosition != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(currentPosition!.latitude, currentPosition!.longitude),
          14.0,
        ),
      );
    }
  }

  void updateMarkerPosition(LatLng newPosition) {
    setState(() {
      markers = {
        draggableMarker.copyWith(positionParam: newPosition),
      };
    });
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  CameraPosition _getInitialCameraPosition() {
    if (currentPosition != null &&
        currentPosition!.latitude != 0.0 &&
        currentPosition!.longitude != 0.0) {
      return CameraPosition(
        target: LatLng(
          currentPosition!.latitude,
          currentPosition!.longitude,
        ),
        zoom: 14.0,
      );
    }
    return CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        markers: markers,
        initialCameraPosition: _getInitialCameraPosition(),
        myLocationEnabled: true,
      ),
    );
  }

  void _showStoreDetailsOnMap(LatLng location) {
    mapController?.animateCamera(CameraUpdate.newLatLng(location));}
}
