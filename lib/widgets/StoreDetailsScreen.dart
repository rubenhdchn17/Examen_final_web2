import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../screens/ReviewsScreen.dart';
import '../screens/RouteScreend.dart';

class StoreDetailsScreen extends StatefulWidget {
  final Position? currentPosition;
  final List<dynamic>? searchResults;
  final int storeIndex;
  final String storeName;
  final String storeAddress;
  final String photoReference;
  final double rating;
  final String description;

  StoreDetailsScreen({
    required this.currentPosition,
    required this.searchResults,
    required this.storeIndex,
    required this.storeName,
    required this.storeAddress,
    required this.photoReference,
    required this.rating,
    required this.description,
  });

  @override
  _StoreDetailsScreenState createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  late String _placeDescription;
  late bool _isOpen = false;
  late String _closingTime = '';

  @override
  void initState() {
    super.initState();
    _placeDescription = "";
    _getPlaceDescription();
    _getStoreStatus();
  }

  Future<void> _getPlaceDescription() async {
    if (widget.searchResults != null) {
      String url =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.searchResults![widget.storeIndex]['place_id']}&fields=name,formatted_address,photo,place_id,rating,geometry&key=AIzaSyCPDGGEbtO-NPHekghNoaWdfz2PMuFPI4E";
      var response = await http.get(Uri.parse(url));
      var data = json.decode(response.body);
      setState(() {
        _placeDescription = data['result']['formatted_address'];
      });
    }
  }

  Future<void> _getStoreStatus() async {
    if (widget.searchResults != null) {
      String url =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.searchResults![widget.storeIndex]['place_id']}&fields=opening_hours&key=AIzaSyCPDGGEbtO-NPHekghNoaWdfz2PMuFPI4E";
      var response = await http.get(Uri.parse(url));
      var data = json.decode(response.body);
      setState(() {
        if (data['result']['opening_hours'] != null) {
          _isOpen = data['result']['opening_hours']['open_now'];
          if (_isOpen) {
            if (data['result']['opening_hours']['periods'][0]['close'] != null) {
              _closingTime = _formatTime(data['result']['opening_hours']['periods'][0]['close']['time']);
            } else {
              _closingTime = '';
            }
          }
        }
      });
    }
  }

  String _formatTime(String time) {
    String hour = time.substring(0, 2);
    String minute = time.substring(2, 4);
    int hourInt = int.parse(hour);
    String suffix = "AM";
    if (hourInt >= 12) {
      suffix = "PM";
      if (hourInt != 12) {
        hourInt -= 12;
      }
    }
    return '$hourInt:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Tienda'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Image.network(
                'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${widget.photoReference}&key=AIzaSyCPDGGEbtO-NPHekghNoaWdfz2PMuFPI4E',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calificación: ${widget.rating}'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _navigateToReviews(context, widget.searchResults![widget.storeIndex]['place_id']);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Opiniones'),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Descripción:'),
                        SizedBox(height: 5),
                        _placeDescription.isNotEmpty
                            ? Text(_placeDescription)
                            : CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text(
                          'Estado de la tienda:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        _isOpen
                            ? Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Abierto${_closingTime.isNotEmpty ? " hasta $_closingTime" : ""}',
                              style: TextStyle(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        )
                            : Row(
                          children: [
                            Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Cerrado',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateToRoute(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('Ir'),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _navigateToRoute(BuildContext context) {
    if (widget.currentPosition != null && widget.searchResults != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RouteScreen(
            startLocation: LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude),
            endLocation: LatLng(
              widget.searchResults![widget.storeIndex]['geometry']['location']['lat'],
              widget.searchResults![widget.storeIndex]['geometry']['location']['lng'],
            ),
          ),
        ),
      );
    }
  }

  void _navigateToReviews(BuildContext context, String placeId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReviewsScreen(placeId: placeId)),
    );
  }
}