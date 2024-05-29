import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' show cos, sqrt, asin;
import 'siteContentPage.dart';

class HomePage extends StatefulWidget {
  final Position? currentPosition;

  HomePage({Key? key, this.currentPosition}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<dynamic> searchResults = [];
  late String query = '';
  late TextEditingController _searchController;
  late SharedPreferences _prefs;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _initSharedPreferences();
    _currentPosition = widget.currentPosition;
  }

  void _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    // Retrieve saved search query
    String savedQuery = _prefs.getString('searchQuery') ?? '';
    setState(() {
      query = savedQuery;
      _searchController.text = query;
      _searchNearbyPlaces(savedQuery);
    });
  }

  void _saveSearchQuery(String query) {
    _prefs.setString('searchQuery', query);
  }

  void _navigateToSearchScreen(String query) {
    _searchNearbyPlaces(query);
    _saveSearchQuery(query);
  }

  void _searchNearbyPlaces(String searchQuery) async {
    const apiKey = 'AIzaSyBPrefTD6ElQbwhnQV0c2oVEw7A1kmEFd8';
    if (searchQuery.isEmpty) {
      searchQuery = '';
    }
    try {
      final encodedQuery = Uri.encodeQueryComponent(searchQuery);
      final apiUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedQuery&radius=5000&key=$apiKey';

      List<dynamic> allResults = [];
      String nextPageToken = '';

      do {
        var response = await http.get(Uri.parse(apiUrl + '&pagetoken=$nextPageToken'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'];
          nextPageToken = data['next_page_token'] ?? '';

          if (results != null && results.isNotEmpty) {
            allResults.addAll(results);
          }
        } else {
          print('Error en la solicitud HTTP: ${response.statusCode}');
        }
      } while (nextPageToken.isNotEmpty && allResults.length < 50);

      _updateSearchResults(allResults);
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
    }
  }

  void _updateSearchResults(List<dynamic> results) {
    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 0.97),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromRGBO(184, 184, 184, 1),
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (query) {
                              _navigateToSearchScreen(query);
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search',
                            ),
                          ),
                        ),
                        Theme(
                          data: Theme.of(context).copyWith(
                            iconTheme: IconThemeData(
                              color: Color.fromRGBO(223, 32, 34, 1),
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              _navigateToSearchScreen(query);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      PlaceButton(
                        icon: Icons.beach_access,
                        label: 'Beach',
                        searchTerm: 'Beach',
                        onTap: _navigateToSearchScreen,
                      ),
                      SizedBox(width: 10),
                      PlaceButton(
                        icon: Icons.airport_shuttle,
                        label: 'Mountain',
                        searchTerm: 'Mountain',
                        onTap: _navigateToSearchScreen,
                      ),
                      SizedBox(width: 10),
                      PlaceButton(
                        icon: Icons.local_cafe,
                        label: 'Cafe',
                        searchTerm: 'Cafe',
                        onTap: _navigateToSearchScreen,
                      ),
                      SizedBox(width: 10),
                      PlaceButton(
                        icon: Icons.local_pizza,
                        label: 'Pizza',
                        searchTerm: 'Pizza',
                        onTap: _navigateToSearchScreen,
                      ),
                      SizedBox(width: 10),
                      PlaceButton(
                        icon: Icons.shopping_cart,
                        label: 'Mall',
                        searchTerm: 'Mall',
                        onTap: _navigateToSearchScreen,
                      ),
                      SizedBox(width: 10),
                      PlaceButton(
                        icon: Icons.local_movies,
                        label: 'Cinema',
                        searchTerm: 'Cinema',
                        onTap: _navigateToSearchScreen,
                      ),
                      SizedBox(width: 10),
                      PlaceButton(
                        icon: Icons.local_bar,
                        label: 'Bar',
                        searchTerm: 'Bar',
                        onTap: _navigateToSearchScreen,
                      ),
                      SizedBox(width: 10),
                      PlaceButton(
                        icon: Icons.pool,
                        label: 'Pool',
                        searchTerm: 'Pool',
                        onTap: _navigateToSearchScreen,
                      ),
                      SizedBox(width: 10),
                      PlaceButton(
                        icon: Icons.local_pharmacy,
                        label: 'Pharmacy',
                        searchTerm: 'Pharmacy',
                        onTap: _navigateToSearchScreen,
                      ),
                      SizedBox(width: 10),
                      PlaceButton(
                        icon: Icons.local_airport,
                        label: 'Airport',
                        searchTerm: 'Airport',
                        onTap: _navigateToSearchScreen,
                      ),
                      SizedBox(width: 10),
                      PlaceButton(
                        icon: Icons.local_gas_station,
                        label: 'Gas Station',
                        searchTerm: 'Gas Station',
                        onTap: _navigateToSearchScreen,
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final place = searchResults[index];
                      if (place == null) return Container();

                      return GestureDetector(
                        onTap: () {
                          _showStoreDetails(context, place, index, _currentPosition);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 80.0,
                                height: 80.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: DecorationImage(
                                    image: place['photos'] != null &&
                                        place['photos'].isNotEmpty &&
                                        place['photos'][0]['photo_reference'] != null
                                        ? NetworkImage(
                                      'https://maps.googleapis.com/maps/api/place/photo?maxwidth=100&photoreference=${place['photos']?[0]['photo_reference']}&key=AIzaSyBPrefTD6ElQbwhnQV0c2oVEw7A1kmEFd8',
                                    )
                                        : AssetImage('assets/placeholder_image.png') as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place['name'] ?? 'Unnamed Place',
                                      style: TextStyle(
                                        color: Color.fromRGBO(223, 32, 34, 100),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Row(
                                      children: [
                                        Text(
                                          ' ${place['types'] != null && place['types'].isNotEmpty ? place['types'][0].toString() : 'No type available'}',
                                          style: TextStyle(
                                            color: Color.fromRGBO(106, 106, 106, 100),
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Icon(
                                          Icons.star,
                                          color: Color.fromRGBO(106, 106, 106, 100),
                                          size: 16,
                                        ),
                                        Text(
                                          '${place['rating'] ?? 0.0}',
                                          style: TextStyle(
                                            color: Color.fromRGBO(106, 106, 106, 100),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.0),
                                    Row(
                                      children: [
                                        Icon(
                                          _isOpenNow(place['opening_hours']) ? Icons.check_circle : Icons.cancel,
                                          color: _isOpenNow(place['opening_hours']) ? Colors.green : Colors.red,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4.0),
                                        Text(
                                          _isOpenNow(place['opening_hours']) ? 'Open' : 'Closed',
                                          style: TextStyle(
                                            color: _isOpenNow(place['opening_hours']) ? Colors.green : Color.fromRGBO(106, 106, 106, 100),
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          _currentPosition != null ? _calculateDistance(place) : '',
                                          style: TextStyle(
                                            color: Color.fromRGBO(106, 106, 106, 100),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _calculateDistance(dynamic place) {
    if (_currentPosition != null && place['geometry'] != null && place['geometry']['location'] != null) {
      double lat1 = _currentPosition!.latitude;
      double lon1 = _currentPosition!.longitude;
      double lat2 = place['geometry']['location']['lat'];
      double lon2 = place['geometry']['location']['lng'];
      double distance = calculateDistance(lat1, lon1, lat2, lon2);
      return "${distance.toStringAsFixed(2)} km away";
    }
    return '';
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  bool _isOpenNow(Map<String, dynamic>? openingHours) {
    if (openingHours != null && openingHours['open_now'] != null) {
      return openingHours['open_now'];
    }
    return false;
  }

  void _showStoreDetails(BuildContext context, dynamic place, int index, Position? currentPosition) {
    if (searchResults != null && searchResults.isNotEmpty) {
      try {
        final storeIndex = index.clamp(0, (searchResults.length ?? 1) - 1);
        final selectedStore = searchResults[storeIndex];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreDetailsScreen(
              currentPosition: currentPosition,
              searchResults: searchResults,
              storeIndex: index,
              storeName: place['name'] ?? 'Unnamed Place',
              storeAddress: place['formatted_address'] ?? 'No Address',
              photoReference: place['photos'] != null &&
                  place['photos'].isNotEmpty &&
                  place['photos'][0]['photo_reference'] != null
                  ? place['photos'][0]['photo_reference']
                  : null,
              rating: (place['rating'] ?? 0).toDouble(),
              description: 'Agregar descripción aquí',
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener información del sitio'),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Text('Actualmente no se tiene información de este sitio'),
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _refresh() async {
    _searchNearbyPlaces("restaurantes");
  }
}

class PlaceButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String searchTerm;
  final Function(String) onTap;

  const PlaceButton({
    required this.icon,
    required this.label,
    required this.searchTerm,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  _PlaceButtonState createState() => _PlaceButtonState();
}

class _PlaceButtonState extends State<PlaceButton> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _initStateFromPreferences();
  }

  void _initStateFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSelected = prefs.getBool(widget.searchTerm) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color textColor =
    _isSelected ? Color.fromRGBO(223, 32, 34, 1) : Color.fromRGBO(54, 54, 54, 1);

    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
          if (_isSelected) {
            // Guarda el estado seleccionado en SharedPreferences
            SharedPreferences.getInstance().then((prefs) {
              prefs.setBool(widget.searchTerm, true);
            });
          } else {
            // Elimina el estado no seleccionado de SharedPreferences
            SharedPreferences.getInstance().then((prefs) {
              prefs.remove(widget.searchTerm);
            });
          }
          widget.onTap(_isSelected ? widget.searchTerm : 'restaurantes');
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromRGBO(184, 184, 184, 1),
          ),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 20, color: textColor),
            SizedBox(width: 4),
            Text(widget.label, style: TextStyle(fontSize: 14, color: textColor)),
          ],
        ),
      ),
    );
  }
}
