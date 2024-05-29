import 'package:flutter/material.dart';
import 'dart:math';

class SearchFunctions {
  static void search(BuildContext context) {
    showSearch(
      context: context,
      delegate: _SearchDelegate(),
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> _suggestions = [
    {'label': 'Beach', 'icon': Icons.beach_access},
    {'label': 'Mountain', 'icon': Icons.local_airport},
    {'label': 'Cafe', 'icon': Icons.local_cafe},
    {'label': 'Pizza', 'icon': Icons.local_pizza},
    {'label': 'Mall', 'icon': Icons.shopping_cart},
    {'label': 'Cinema', 'icon': Icons.local_movies},
    {'label': 'Bar', 'icon': Icons.local_bar},
    {'label': 'Pool', 'icon': Icons.pool},
    {'label': 'Pharmacy', 'icon': Icons.local_pharmacy},
    {'label': 'Airport', 'icon': Icons.airport_shuttle},
    {'label': 'Gas Station', 'icon': Icons.local_gas_station},
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Scaffold(
      body: _buildSuggestions(context),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final List<Map<String, dynamic>> filteredSuggestions = query.isEmpty
        ? _suggestions
        : _suggestions
        .where((suggestion) =>
        suggestion['label'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    final List<Map<String, dynamic>> suggestionsToShow =
    filteredSuggestions.sublist(0, min(10, filteredSuggestions.length));
    final List<Map<String, dynamic>> historyToShow =
    filteredSuggestions.sublist(0, min(3, filteredSuggestions.length));

    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              "Suggestions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            height: 6,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 4, // Espacio entre elementos
              children: suggestionsToShow
                  .map(
                    (suggestion) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4),
                  child: PlaceButton(
                      icon: suggestion['icon'], label: suggestion['label']),
                ),
              )
                  .toList(),
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              "History",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 4, // Espacio entre elementos
              children: historyToShow
                  .map(
                    (suggestion) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4),
                  child: PlaceButton(
                      icon: suggestion['icon'], label: suggestion['label']),
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceButton extends StatefulWidget {
  final IconData icon;
  final String label;

  const PlaceButton({
    required this.icon,
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  _PlaceButtonState createState() => _PlaceButtonState();
}

class _PlaceButtonState extends State<PlaceButton> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    Color textColor = _isSelected
        ? Color.fromRGBO(223, 32, 34, 1)
        : Colors.black;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
        });
      },
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label,
                style: TextStyle(
                    fontSize: 12, color: textColor)),
            SizedBox(width: 4),
            Icon(widget.icon, size: 18, color: textColor),
          ],
        ),
      ),
    );
  }
}