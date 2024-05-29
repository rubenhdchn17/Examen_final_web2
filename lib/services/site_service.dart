import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/review.dart';
import '../utils/secure_storage.dart';

class ReviewService {
  final String baseUrl = 'http://criticasapp.pythonanywhere.com';

  Future<List<Review>> fetchReviews(int siteId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/sites/$siteId/reviews'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Review> reviews = body.map((dynamic item) => Review.fromJson(item)).toList();
      return reviews;
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<Review> fetchReview(int siteId, int reviewId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/sites/$siteId/reviews/$reviewId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Review.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load review');
    }
  }

  Future<void> createReview(Review review) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/reviews'),
      headers: await _getHeaders(contentType: true),
      body: jsonEncode({
        'contenido': review.contenido,
        'calificacion': review.calificacion,
        'id_usuario': review.idUsuario,
        'id_sitio': review.idSitio,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create review');
    }
  }

  Future<void> updateReview(Review review) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/reviews/${review.id}'),
      headers: await _getHeaders(contentType: true),
      body: jsonEncode({
        'contenido': review.contenido,
        'calificacion': review.calificacion,
        'id_usuario': review.idUsuario,
        'id_sitio': review.idSitio,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update review');
    }
  }

  Future<void> deleteReview(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/reviews/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete review');
    }
  }

  Future<Map<String, String>> _getHeaders({bool contentType = false}) async {
    String? token = await SecureStorage.readToken();
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    if (contentType) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
    }
}
