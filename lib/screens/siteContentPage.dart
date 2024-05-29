import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'ReviewsScreen.dart';
import 'RouteScreend.dart';
import '../services/review_service.dart';

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
  late String _commentAuthorName = '';
  late double _commentAuthorRating = 0.0;
  late String _commentText = '';
  late GoogleMapController _mapController;
  late double _apiRating;

  @override
  void initState() {
    super.initState();
    _placeDescription = "";
    _getPlaceDescription();
    _getStoreStatus();
    _getComment();
    _apiRating = widget.rating;
  }

  Future<void> _getPlaceDescription() async {
    if (widget.searchResults != null) {
      String url =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.searchResults![widget.storeIndex]['place_id']}&fields=name,formatted_address,photo,place_id,rating,geometry&key=AIzaSyBPrefTD6ElQbwhnQV0c2oVEw7A1kmEFd8";
      var response = await http.get(Uri.parse(url));
      var data = json.decode(response.body);
      setState(() {
        _placeDescription = data['result']['formatted_address'];
        _apiRating = data['result']['rating'];
      });
    }
  }

  Future<void> _getStoreStatus() async {
    if (widget.searchResults != null) {
      String url =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.searchResults![widget.storeIndex]['place_id']}&fields=opening_hours&key=AIzaSyBPrefTD6ElQbwhnQV0c2oVEw7A1kmEFd8";
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

  Future<void> _getComment() async {
    if (widget.searchResults != null) {
      String url =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.searchResults![widget.storeIndex]['place_id']}&fields=reviews&key=AIzaSyBPrefTD6ElQbwhnQV0c2oVEw7A1kmEFd8";
      var response = await http.get(Uri.parse(url));
      var data = json.decode(response.body);
      setState(() {
        if (data['result']['reviews'] != null && data['result']['reviews'].length > 0) {
          _commentText = data['result']['reviews'][0]['text'];
          _commentAuthorName = data['result']['reviews'][0]['author_name'];
          _commentAuthorRating = data['result']['reviews'][0]['rating'] != null ? data['result']['reviews'][0]['rating'].toDouble() : 0.0;
        } else {
          _commentText = "No hay comentarios disponibles.";
          _commentAuthorName = "Anónimo";
          _commentAuthorRating = 0.0;
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(''),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${widget.photoReference}&key=AIzaSyBPrefTD6ElQbwhnQV0c2oVEw7A1kmEFd8',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.storeName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 20,
                              ),
                              SizedBox(width: 5),
                              Text(
                                '$_apiRating',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dirección:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            _placeDescription.isNotEmpty
                                ? Text(_placeDescription)
                                : CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text(
                              'Estado:',
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
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                                      ),
                                      SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _commentAuthorName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                                size: 14,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                '$_commentAuthorRating',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _navigateToReviews(context, widget.searchResults![widget.storeIndex]['place_id']);
                                  },
                                  child: Text(
                                    'Ver más',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Comentario:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              _commentText,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 200,
                        child: GoogleMap(
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              widget.searchResults![widget.storeIndex]['geometry']['location']['lat'],
                              widget.searchResults![widget.storeIndex]['geometry']['location']['lng'],
                            ),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId('storeLocation'),
                              position: LatLng(
                                widget.searchResults![widget.storeIndex]['geometry']['location']['lat'],
                                widget.searchResults![widget.storeIndex]['geometry']['location']['lng'],
                              ),
                            ),
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                )
              ],
            ),
          ),
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