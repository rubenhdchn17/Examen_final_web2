import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../services/auth_service.dart';

class ReviewsScreen extends StatefulWidget {
  final String placeId;

  ReviewsScreen({required this.placeId});

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<dynamic>? apiReviews;
  List<Review> appReviews = [];
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  final ReviewService _reviewService = ReviewService();
  late SharedPreferences _prefs;
  int? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _initializeUserId();
    _getUserId();
    _fetchReviews();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadRating();
  }

  void _loadRating() {
    setState(() {
      _rating = _prefs.getDouble('userRating') ?? 0;
    });
  }
  Future<void> _getUserId() async {
    try {
      _userId = await AuthService().getUserId();
      print("Initializing User ID... $_userId" );
    } catch (e) {
      print('Error getting user ID: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeUserId() async {
    print("Initializing User ID...");
    await _getUserId().then((_){
      setState(() {
      _submitReview();
    });
    });
  }




  Future<void> _fetchReviews() async {
    await _fetchApiReviews();
    await _fetchAppReviews();
  }

  Future<void> _fetchApiReviews() async {
    final apiKey = 'AIzaSyBPrefTD6ElQbwhnQV0c2oVEw7A1kmEFd8';
    final apiUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.placeId}&fields=name,rating,reviews&key=$apiKey';

    try {
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'];
        final reviewsData = result['reviews'];

        setState(() {
          if (reviewsData != null) {
            apiReviews = reviewsData;
          }
        });
      } else {
        print('Error in HTTP request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in HTTP request: $e');
    }
  }

  Future<void> _fetchAppReviews() async {
    try {
      final List<Review> appOpinions = await _reviewService.fetchReviews(int.parse(widget.placeId));
      setState(() {
        appReviews = appOpinions;
      });
    } catch (e) {
      print('Error getting reviews: $e');
    }
  }

  void _submitReview() {
    if (_userId == null) {
      print('User ID is not yet initialized');
      return;
    }

    final String comment = _commentController.text;
    if (comment.isNotEmpty) {
      final newReview = Review(
        id: _userId!.toInt(),
        contenido: comment,
        calificacion: _rating.toInt(),
        idUsuario: _userId!,
        idSitio: int.parse(widget.placeId),
      );

      print('Submitting new review to the backend: $newReview');
      print('Data sent to backend: ${newReview.toJson()}');


      _reviewService.createReview(newReview).then((_) {
        setState(() {
          appReviews.add(newReview);
        });
        _commentController.clear();
        setState(() {
          _rating = 0;
        });
      }).catchError((error) {
        print('Error adding review: $error');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to add comment.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter a comment.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _saveRating(double rating) {
    _prefs.setDouble('userRating', rating);
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> allReviews = [];
    final List<dynamic> apiReviewsList = [];
    final List<dynamic> appReviewsList = [];

    if (apiReviews != null) {
      apiReviewsList.addAll(apiReviews!);
    }
    appReviewsList.addAll(appReviews);
    allReviews.addAll(apiReviewsList);
    allReviews.addAll(appReviewsList);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: allReviews.length + 1,
              itemBuilder: (context, index) {
                if (index == allReviews.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Column(
                                      children: [
                                        RatingBar.builder(
                                          initialRating: _rating,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 20,
                                          itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (rating) {
                                            setState(() {
                                              _rating = rating;
                                              _saveRating(rating);
                                            });
                                          },
                                        ),
                                        SizedBox(height: 10),
                                        TextField(
                                          controller: _commentController,
                                          decoration: InputDecoration(
                                            hintText: 'Add a comment',
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _submitReview,
                                  child: Text('Submit'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final review = allReviews[index];
                if (review == null) return Container();

                if (review is Map<String, dynamic>) {
                  if (apiReviewsList.contains(review)) {
                    return _buildApiReview(review);
                  }
                } else if (review is Review) {
                  if (appReviewsList.contains(review)) {
                    return _buildAppReview(review);
                  }
                }

                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiReview(Map<String, dynamic> review) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              review['profile_photo_url'] ?? '',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey),
              ),
              child: ListTile(
                title: Text(review['author_name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        Text('${review['rating']}'),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(review['text']),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppReview(Review review) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            child: Icon(Icons.person),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey),
              ),
              child: ListTile(
                title: Text('Usuario'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Row(
                      children: [
                        RatingBar.builder(
                          initialRating: review.calificacion.toDouble(),
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 20,
                          itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _rating = rating;
                              _saveRating(rating);
                            });
                          },
                        ),
                        Text('${review.calificacion}'),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(review.contenido),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
