import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'MapScreen.dart';
import 'StoreDetailsScreen.dart';

class HomeScreen extends StatefulWidget {
  final Position? currentPosition;
  final List<dynamic>? searchResults;

  HomeScreen({Key? key, this.currentPosition, this.searchResults}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<dynamic>? searchResults;

  @override
  void initState() {
    super.initState();
    _searchNearbyPlaces("restaurantes");
    searchResults = widget.searchResults;
  }

  void _navigateToSearchScreen(String query) {
    _searchNearbyPlaces(query);
  }

  void _searchNearbyPlaces(String searchQuery) async {
    final apiKey = 'AIzaSyCPDGGEbtO-NPHekghNoaWdfz2PMuFPI4E';
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.grey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextFormField(
                  onChanged: (query) {
                    _navigateToSearchScreen(query);
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search',
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: searchResults?.length ?? 0,
                  itemBuilder: (context, index) {
                    final place = searchResults?[index];
                    if (place == null) return Container();

                    return GestureDetector(
                      onTap: () {
                        _showStoreDetails(context, place, index, widget.currentPosition);
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
                                  image: NetworkImage(
                                    'https://maps.googleapis.com/maps/api/place/photo?maxwidth=100&photoreference=${place['photos']?[0]['photo_reference']}&key=AIzaSyCPDGGEbtO-NPHekghNoaWdfz2PMuFPI4E',
                                  ),
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
                                    place['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(place['formatted_address']),
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
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
            },
            child: Text('Go to Map Screen'),
          ),
        ],
      ),
    );
  }

  void _showStoreDetails(BuildContext context, dynamic place, int index, Position? currentPosition) {
    if (searchResults != null && searchResults!.isNotEmpty) {
      try {
        final storeIndex = index.clamp(0, (searchResults?.length ?? 1) - 1);
        final selectedStore = searchResults?[storeIndex];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreDetailsScreen(
              currentPosition: currentPosition,
              searchResults: searchResults,
              storeIndex: index,
              storeName: place['name'],
              storeAddress: place['formatted_address'],
              photoReference: place['photos'][0]['photo_reference'],
              rating: place['rating'] ?? 0.0,
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
}
